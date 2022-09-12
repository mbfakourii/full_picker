import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:light_compressor/light_compressor.dart';

import '../../full_picker.dart';

/// show top sheet title and back button
topSheet(String title, BuildContext context) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: const EdgeInsets.only(top: 5, left: 5),
      child: ClipOval(
        child: Material(
          child: InkWell(
            child: const SizedBox(
                width: 55, height: 55, child: Icon(Icons.arrow_back)),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    ),
    Flexible(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    Padding(
        padding: const EdgeInsets.only(top: 5, right: 5),
        child: Container(
          width: 56,
        )),
  ]);
}

/// show sheet
void showSheet(Widget widget, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return widget;
      });
}

/// get files
Future<OutputFile?> getFiles(
    {required BuildContext context,
    required FileType fileType,
    required FilePickerType pickerFileType,
    required String prefixName,
    required ValueSetter<bool> onIsUserCheng,
    required ValueSetter<int> onError,
    List<String>? allowedExtensions,
    bool videoCompressor = false,
    required bool inSheet,
    bool imageCropper = false,
    bool multiFile = false}) async {
  ProgressIndicatorDialog progressDialog = ProgressIndicatorDialog(context);
  try {
    await FilePicker.platform.clearTemporaryFiles();
  } catch (_) {}

  FilePickerResult? result = await FilePicker.platform
      .pickFiles(
    allowMultiple: multiFile,
    type: fileType,
    allowedExtensions: allowedExtensions,
    onFileLoading: (value) {
      if (value == FilePickerStatus.picking) {
        progressDialog.show();
      } else {
        return null;
      }
    },
  )
      .catchError((error, stackTrace) {
    showFullPickerToast(globalLanguage.denyAccessPermission, context);
  });

  if (result != null) {
    progressDialog.dismiss();
    List<Uint8List?> bytes = [];
    List<String?> name = [];

    for (final file in result.files) {
      name.add("${prefixName}_${name.length + 1}.${file.extension!}");
      Uint8List byte;

      if (file.bytes == null) {
        byte = File(file.path!).readAsBytesSync();
      } else {
        byte = file.bytes!;
      }

      /// video compressor
      if (file.extension == "mp4" && videoCompressor) {
        Uint8List? byteCompress =
            await videoCompress(context: context, byte: byte, file: file);

        if (byteCompress == null) return null;
        byte = byteCompress;
      }

      /// image cropper
      if (file.extension == "jpg" && imageCropper) {
        try {
          Uint8List? byteCrop =
              await cropImage(context: context, byte: byte, file: file);

          if (byteCrop == null) return null;
          byte = byteCrop;
        } catch (_) {}
      }

      bytes.add(byte);
    }

    return OutputFile(bytes, pickerFileType, name);
  } else {
    return null;
  }
}

/// re director for select file
/// 1 = Gallery
/// 2 = Camera
/// 3 = File
void getFullPicker({
  required id,
  required context,
  required ValueSetter<bool> onIsUserCheng,
  required ValueSetter<OutputFile> onSelected,
  required ValueSetter<int> onError,
  required bool image,
  required bool video,
  required bool file,
  required bool imageCamera,
  required bool videoCamera,
  required bool videoCompressor,
  required bool imageCropper,
  required bool multiFile,
  required String prefixName,
  required bool inSheet,
}) async {
  onIsUserCheng.call(false);
  OutputFile? value;

  if (id == 1) {
    /// gallery

    if (image && video) {
      value = await getFiles(
          context: context,
          videoCompressor: videoCompressor,
          fileType: FileType.custom,
          pickerFileType: FilePickerType.mixed,
          prefixName: prefixName,
          inSheet: inSheet,
          allowedExtensions: ["mp4", "avi", "mkv", "jpg", "jpeg", "png", "bmp"],
          multiFile: multiFile,
          onError: onError,
          imageCropper: imageCropper,
          onIsUserCheng: onIsUserCheng);
    } else if (image) {
      value = await getFiles(
          context: context,
          videoCompressor: videoCompressor,
          fileType: FileType.image,
          pickerFileType: FilePickerType.image,
          prefixName: prefixName,
          multiFile: multiFile,
          inSheet: inSheet,
          imageCropper: imageCropper,
          onError: onError,
          onIsUserCheng: onIsUserCheng);
    } else if (video) {
      value = await getFiles(
          context: context,
          videoCompressor: videoCompressor,
          fileType: FileType.video,
          pickerFileType: FilePickerType.video,
          prefixName: prefixName,
          imageCropper: imageCropper,
          inSheet: inSheet,
          multiFile: multiFile,
          onError: onError,
          onIsUserCheng: onIsUserCheng);
    }

    if (value == null) {
      checkError(inSheet, onIsUserCheng, context, isSelected: false);
      onError.call(1);
    } else {
      checkError(inSheet, onIsUserCheng, context, isSelected: true);
      if (value.name.isNotEmpty) onSelected.call(value);
    }
  } else if (id == 2) {
    /// camera
    dynamic value = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return Camera(
          imageCamera: imageCamera,
          videoCamera: videoCamera,
          prefixName: prefixName,
        );
      },
    ));

    if (value == 1 || value == null) {
      // Error
      checkError(inSheet, onIsUserCheng, context, isSelected: false);
      onError.call(1);
    } else {
      checkError(inSheet, onIsUserCheng, context, isSelected: true);
      onSelected.call(value);
    }
  } else if (id == 3) {
    // file
    value = await getFiles(
        context: context,
        fileType: FileType.any,
        pickerFileType: FilePickerType.file,
        prefixName: prefixName,
        multiFile: multiFile,
        inSheet: inSheet,
        onError: onError,
        onIsUserCheng: onIsUserCheng);

    if (value == null) {
      checkError(inSheet, onIsUserCheng, context, isSelected: false);
      onError.call(1);
    } else {
      checkError(inSheet, onIsUserCheng, context, isSelected: true);
      onSelected.call(value);
    }
  }
}

/// check for control close sheet
checkError(inSheet, onIsUserCheng, context, {required bool isSelected}) {
  if (inSheet) {
    onIsUserCheng.call(false);

    if (kIsWeb) {
      if (isSelected) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        Navigator.of(context).pop();
      } else {
        if (isSelected == false) Navigator.of(context).pop();
      }
    }
  }
}

/// get destination File for save
Future<String> _destinationFile({required bool isImage}) async {
  String directory;
  final String fileName =
      '${DateTime.now().millisecondsSinceEpoch}.${isImage ? "jpg" : "mp4"}';
  if (Platform.isAndroid) {
    /// Handle this part the way you want to save it in any directory you wish.
    final List<Directory>? dir = await path.getExternalCacheDirectories();
    directory = dir!.first.path;
    return File('$directory/$fileName').path;
  } else {
    final Directory dir = await path.getLibraryDirectory();
    directory = dir.path;
    return File('$directory/$fileName').path;
  }
}

/// web does not support video compression
/// video compressor
Future<Uint8List?> videoCompress({
  required context,
  required Uint8List byte,
  required PlatformFile file,
}) async {
  if (isWeb) {
    return byte;
  }

  File mainFile = File(file.path!);
  ValueNotifier<double> onProgress = ValueNotifier<double>(0);
  final LightCompressor lightCompressor = LightCompressor();
  String destinationFile = await _destinationFile(isImage: false);

  int size = int.parse(File(mainFile.path).lengthSync().toString());
  if (size < 10000000) {
    return byte;
  }

  PercentProgressDialog progressDialog =
      PercentProgressDialog(context, (dynamic) {
    if (onProgress.value.toString() != "1.0") {
      LightCompressor.cancelCompression();
    }
  }, onProgress, globalLanguage.onCompressing);

  LightCompressor().onProgressUpdated.listen((event) {
    onProgress.value = event / 100;
  });

  try {
    progressDialog.show();
    final dynamic response = await lightCompressor.compressVideo(
        path: mainFile.path,
        destinationPath: destinationFile,
        videoQuality: VideoQuality.medium,
        frameRate: 24);

    progressDialog.dismiss();

    if (response is OnSuccess) {
      File outputFile = File(response.destinationPath);
      Uint8List outputByte = outputFile.readAsBytesSync();

      /// delete cash file
      await outputFile.delete();
      return outputByte;
    } else if (response is OnFailure) {
      /// failure message
      return byte;
    } else if (response is OnCancelled) {
      return null;
    }
  } catch (e) {
    return byte;
  }

  return byte;
}

/// web does not support crop Image
/// crop image
Future<Uint8List?> cropImage({
  required context,
  required Uint8List byte,
  required PlatformFile file,
}) async {
  if (isWeb) {
    return byte;
  }

  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: file.path!,
    compressQuality: 20,
    aspectRatioPresets: Platform.isAndroid
        ? [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ]
        : [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9
          ],
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: globalLanguage.cropper,
          toolbarColor: Theme.of(context).colorScheme.secondary,
          toolbarWidgetColor: Theme.of(context).colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: globalLanguage.cropper,
      )
    ],
  );

  try {
    return await croppedFile!.readAsBytes();
  } catch (e) {
    return null;
  }
}

/// show custom sheet
showFullPickerToast(String text, BuildContext context) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: const Color(0xFF656565),
    ),
    child: Text(text, style: const TextStyle(color: Color(0xfffefefe))),
  );

  FToast().init(context).showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
      );
}
