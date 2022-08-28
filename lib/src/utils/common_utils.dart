import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:light_compressor/light_compressor.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../full_picker.dart';

topSheet(String title, BuildContext context) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: EdgeInsets.only(top: 5, left: 5),
      child: ClipOval(
        child: Material(
          child: InkWell(
            child: SizedBox(width: 14.w, height: 15.h, child: Icon(Icons.arrow_back)),
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
        style: TextStyle(fontSize: 22.sp),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    Padding(
        padding: EdgeInsets.only(top: 5, right: 5),
        child: Container(
          width: 56,
        )),
  ]);
}

void showSheet(Widget widget, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return widget;
      });
}

newItem(String title, IconData icon, GestureTapCallback onTap) {
  return Material(
    child: Ink(
      color: Colors.transparent,
      child: new ListTile(
        leading: new Icon(icon),
        title: new Text(title),
        onTap: () => onTap.call(),
      ),
    ),
  );
}

Future<OutputFile?> getFiles(
    {required BuildContext context,
    required FileType fileType,
    required PickerFileType pickerFileType,
    required String firstPartFileName,
    required ValueSetter<bool> onIsUserCheng,
    required ValueSetter<int> onError,
    List<String>? allowedExtensions,
    bool videoCompressor = false,
    required bool inSheet,
    bool imageCropper = false,
    bool multiFile = false}) async {
  ProgressIndicatorDialog progressDialog = ProgressIndicatorDialog(context);
  await FilePicker.platform.clearTemporaryFiles();

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
    Fluttertoast.showToast(msg: language.deny_access_permission, toastLength: Toast.LENGTH_SHORT);
  });

  if (result != null) {
    progressDialog.dismiss();
    List<Uint8List?> bytes = [];
    List<String?> name = [];

    for (final file in result.files) {
      name.add(firstPartFileName + "_" + (name.length + 1).toString() + "." + file.extension!);
      Uint8List byte;

      if (file.bytes == null) {
        byte = File(file.path!).readAsBytesSync();
      } else {
        byte = file.bytes!;
      }

      // video compressor
      if (file.extension == "mp4" && videoCompressor) {
        Uint8List? byteCompress = await videoCompress(context: context, byte: byte, file: file);

        if (byteCompress == null) return null;
        byte = byteCompress;
      }

      // image cropper
      if (file.extension == "jpg" && imageCropper) {
        Uint8List? byteCrop = await cropImage(context: context, byte: byte, file: file);

        if (byteCrop == null) return null;
        byte = byteCrop;
      }

      bytes.add(byte);
    }

    return OutputFile(bytes, pickerFileType, name);
  } else {
    return null;
  }
}

Future<String> get destinationFile async {
  String directory;
  final String videoName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
  if (Platform.isAndroid) {
    Directory extDir;

    if (io.Platform.isIOS) {
      extDir = await getApplicationDocumentsDirectory();
    } else {
      extDir = (await getExternalStorageDirectory())!;
    }
    String dirPAth = "${extDir.path}/Video";
    await Directory(dirPAth).create(recursive: true);
    return File('$dirPAth/$videoName').path;
  } else {
    final Directory dir = await path.getLibraryDirectory();
    directory = dir.path;
    return File('$directory/$videoName').path;
  }
}

Uint8List? getByte(FilePickerResult result) {
  if (kIsWeb) {
    return result.files.first.bytes;
  } else {
    File file = File(result.files.first.path!);
    return file.readAsBytesSync();
  }
}

// 1 = Gallery
// 2 = Camera
// 3 = File
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
  required String firstPartFileName,
  required bool inSheet,
}) async {
  onIsUserCheng.call(false);
  OutputFile? value;

  if (id == 1) {
    // gallery

    if (image && video) {
      value = await getFiles(
          context: context,
          videoCompressor: videoCompressor,
          fileType: FileType.custom,
          pickerFileType: PickerFileType.MIXED,
          firstPartFileName: firstPartFileName,
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
          pickerFileType: PickerFileType.IMAGE,
          firstPartFileName: firstPartFileName,
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
          pickerFileType: PickerFileType.VIDEO,
          firstPartFileName: firstPartFileName,
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
      if (value.name.length != 0) onSelected.call(value);
    }
  } else if (id == 2) {
    // camera
    dynamic value = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return Camera(
          imageCamera: imageCamera,
          videoCamera: videoCamera,
          firstPartFileName: firstPartFileName,
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
        pickerFileType: PickerFileType.FILE,
        firstPartFileName: firstPartFileName,
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

// check for control close sheet
checkError(inSheet, onIsUserCheng, context, {required bool isSelected}) {
  if (inSheet) {
    onIsUserCheng.call(false);
    if (isSelected) Navigator.of(context).pop();
  }
}

Future<String> _destinationFile({required bool isImage}) async {
  String directory;
  final String fileName = '${DateTime.now().millisecondsSinceEpoch}.' + (isImage ? "jpg" : "mp4");
  if (Platform.isAndroid) {
    // Handle this part the way you want to save it in any directory you wish.
    final List<Directory>? dir = await path.getExternalCacheDirectories();
    directory = dir!.first.path;
    return File('$directory/$fileName').path;
  } else {
    final Directory dir = await path.getLibraryDirectory();
    directory = dir.path;
    return File('$directory/$fileName').path;
  }
}

// web does not support video compression
Future<Uint8List?> videoCompress({
  required context,
  required Uint8List byte,
  required PlatformFile file,
}) async {
  if (kIsWeb) {
    return byte;
  }

  File mainFile = await File(file.path!);
  ValueNotifier<double> onProgress = ValueNotifier<double>(0);
  final LightCompressor _lightCompressor = LightCompressor();
  String destinationFile = await _destinationFile(isImage: false);

  int _size = int.parse(File(mainFile.path).lengthSync().toString());
  if (_size < 10000000) {
    return byte;
  }

  PercentProgressDialog progressDialog = PercentProgressDialog(context, (dynamic) {
    if (onProgress.value.toString() != "1.0") {
      LightCompressor.cancelCompression();
    }
  }, onProgress, language.on_compressing);

  LightCompressor().onProgressUpdated.listen((event) {
    onProgress.value = event / 100;
  });

  try {
    progressDialog.show();
    final dynamic response = await _lightCompressor.compressVideo(
        path: mainFile.path, destinationPath: destinationFile, videoQuality: VideoQuality.medium, frameRate: 24);

    progressDialog.dismiss();

    if (response is OnSuccess) {
      File outputFile = File(response.destinationPath);
      Uint8List outputByte = outputFile.readAsBytesSync();
      // delete cash file
      await outputFile.delete();
      return outputByte;
    } else if (response is OnFailure) {
      // failure message
      print(response.message);
      return byte;
    } else if (response is OnCancelled) {
      return null;
    }
  } catch (e) {
    return byte;
  }

  return byte;
}

// web does not support crop Image
Future<Uint8List?> cropImage({
  required context,
  required Uint8List byte,
  required PlatformFile file,
}) async {
  if (kIsWeb) {
    return byte;
  }

  CroppedFile? croppedFile = await await ImageCropper().cropImage(
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
          toolbarTitle: language.cropper,
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: language.cropper,
      )
    ],
  );

  try {
    return await croppedFile!.readAsBytes();
  } catch (e) {
    return null;
  }
}
