import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_picker/full_picker.dart';
import 'package:full_picker/src/dialogs/url_input_dialog.dart';
import 'package:full_picker/src/sheets/voice_recorder_sheet.dart';
import 'package:full_picker/src/utils/pl.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';

/// show sheet
void showSheet(
  final Widget widget,
  final BuildContext context, {
  final bool isDismissible = true,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isDismissible: isDismissible,
    builder: (final BuildContext context) => widget,
  );
}

FileType extensionType(final String extension) {
  if (extension == '') {
    return FileType.any;
  } else if (extension == 'aac' ||
      extension == 'midi' ||
      extension == 'mp3' ||
      extension == 'ogg' ||
      extension == 'wav') {
    return FileType.audio;
  } else if (extension == 'bmp' ||
      extension == 'gif' ||
      extension == 'jpeg' ||
      extension == 'jpg' ||
      extension == 'png') {
    return FileType.image;
  } else if (extension == 'avi' ||
      extension == 'flv' ||
      extension == 'mkv' ||
      extension == 'mov' ||
      extension == 'mp4' ||
      extension == 'mpeg' ||
      extension == 'webm' ||
      extension == 'wmv') {
    return FileType.video;
  } else {
    return FileType.any;
  }
}

String generateRandomString() {
  const Uuid uuid = Uuid();
  return uuid.v4();
}

/// get files
Future<FullPickerOutput?> getFiles({
  required final BuildContext context,
  required final FileType fileType,
  required final FullPickerType pickerFileType,
  required final String prefixName,
  required final ValueSetter<bool> onIsUserChange,
  required final ValueSetter<int>? onError,
  required final bool inSheet,
  final List<String>? allowedExtensions,
  final bool videoCompressor = false,
  final bool imageCropper = false,
  final bool multiFile = false,
}) async {
  final ProgressIndicatorDialog progressDialog =
      ProgressIndicatorDialog(context);

  final FilePickerResult? result = await FilePicker.platform
      .pickFiles(
    allowMultiple: multiFile,
    withData: true,
    type: fileType,
    allowedExtensions: allowedExtensions,
    onFileLoading: (final FilePickerStatus value) {
      if (value == FilePickerStatus.picking) {
        progressDialog.show();
      } else {
        return null;
      }
    },
  )
      .catchError((final _, final __) {
    showFullPickerToast(globalFullPickerLanguage.denyAccessPermission, context);
    return null;
  });

  try {
    if (result != null) {
      final List<File?> files = <File?>[];
      final List<XFile?> xFiles = <XFile?>[];
      final List<String?> name = <String?>[];
      final List<Uint8List?> bytes = <Uint8List?>[];

      int numberVideo = 0;
      int numberPicture = 0;
      for (final PlatformFile file in result.files) {
        name.add(
          '${prefixName}_${generateRandomString()}_${name.length + 1}.${file.extension!}',
        );
        Uint8List byte;

        if (file.bytes == null) {
          byte = File(file.path!).readAsBytesSync();
        } else {
          byte = file.bytes!;
        }

        // for counter
        if (extensionType(file.extension!) == FileType.video) {
          numberVideo = numberVideo + 1;
        }

        if (extensionType(file.extension!) == FileType.image) {
          numberPicture = numberPicture + 1;
        }

        /// video compressor
        if (file.extension == 'mp4' && videoCompressor) {
          if (!context.mounted) {
            return null;
          }
          final Uint8List? byteCompress =
              await videoCompress(context: context, byte: byte, file: file);

          if (byteCompress == null) {
            return null;
          }

          byte = byteCompress;
        }

        /// image cropper
        if ((file.extension == 'jpg' ||
                file.extension == 'png' ||
                file.extension == 'jpeg') &&
            imageCropper) {
          try {
            if (!context.mounted) {
              return null;
            }
            final Uint8List? byteCrop = await cropImage(
              context: context,
              byte: byte,
              sourcePath: file.path!,
            );

            if (byteCrop == null) {
              return null;
            }

            byte = byteCrop;
          } catch (_) {}
        }

        if (!isWeb) {
          if (file.path != null) {
            final Directory appDir =
                await path_provider.getTemporaryDirectory();
            final File file = File('${appDir.path}/${name.last!}');
            await file.writeAsBytes(byte);
            files.add(file);
            xFiles.add(
              XFile(
                file.path,
                bytes: byte,
                name: name.last,
                mimeType: lookupMimeType(name.last!, headerBytes: byte),
              ),
            );
          }
        }

        bytes.add(byte);
        xFiles.add(
          XFile.fromData(
            byte,
            name: name.last,
            mimeType: lookupMimeType(name.last!, headerBytes: byte),
          ),
        );
      }

      if (!Pl.isWindows) {
        progressDialog.dismiss();
      }

      if (pickerFileType == FullPickerType.mixed) {
        if (numberPicture == 0 && numberVideo != 0) {
          return FullPickerOutput(
            bytes: bytes,
            fileType: FullPickerType.video,
            name: name,
            file: files,
            xFile: xFiles,
          );
        } else if (numberPicture != 0 && numberVideo == 0) {
          return FullPickerOutput(
            bytes: bytes,
            fileType: FullPickerType.image,
            name: name,
            file: files,
            xFile: xFiles,
          );
        } else {
          // mixed
          return FullPickerOutput(
            bytes: bytes,
            fileType: pickerFileType,
            name: name,
            file: files,
            xFile: xFiles,
          );
        }
      } else {
        return FullPickerOutput(
          bytes: bytes,
          fileType: pickerFileType,
          name: name,
          file: files,
          xFile: xFiles,
        );
      }
    } else {
      return null;
    }
  } catch (_) {
    progressDialog.dismiss();
  }
  return null;
}

Future<void> clearTemporaryFiles() async {
  try {
    await FilePicker.platform.clearTemporaryFiles();
  } catch (_) {}
}

/// re director for select file
/// 1 = Gallery
/// 2 = Camera
/// 3 = File
Future<void> getFullPicker({
  required final int id,
  required final BuildContext context,
  required final ValueSetter<bool> onIsUserChange,
  required final ValueSetter<FullPickerOutput> onSelected,
  required final ValueSetter<int>? onError,
  required final bool image,
  required final bool video,
  required final bool file,
  required final bool voiceRecorder,
  required final bool url,
  required final String bodyTextUrl,
  required final bool imageCamera,
  required final bool videoCamera,
  required final bool videoCompressor,
  required final bool imageCropper,
  required final bool multiFile,
  required final String prefixName,
  required final bool inSheet,
}) async {
  onIsUserChange.call(false);
  FullPickerOutput? value;

  if (id == 1) {
    /// gallery

    if (image && video) {
      value = await getFiles(
        context: context,
        videoCompressor: videoCompressor,
        fileType: FileType.custom,
        pickerFileType: FullPickerType.mixed,
        prefixName: prefixName,
        inSheet: inSheet,
        allowedExtensions: <String>[
          'mp4',
          'avi',
          'mkv',
          'jpg',
          'jpeg',
          'png',
          'bmp',
        ],
        multiFile: multiFile,
        onError: onError,
        imageCropper: imageCropper,
        onIsUserChange: onIsUserChange,
      );
    } else if (image) {
      value = await getFiles(
        context: context,
        videoCompressor: videoCompressor,
        fileType: FileType.image,
        pickerFileType: FullPickerType.image,
        prefixName: prefixName,
        multiFile: multiFile,
        inSheet: inSheet,
        imageCropper: imageCropper,
        onError: onError,
        onIsUserChange: onIsUserChange,
      );
    } else if (video) {
      value = await getFiles(
        context: context,
        videoCompressor: videoCompressor,
        fileType: FileType.video,
        pickerFileType: FullPickerType.video,
        prefixName: prefixName,
        imageCropper: imageCropper,
        inSheet: inSheet,
        multiFile: multiFile,
        onError: onError,
        onIsUserChange: onIsUserChange,
      );
    }

    if (value == null) {
      if (context.mounted) {
        checkError(
          inSheet: inSheet,
          onIsUserChange,
          context,
          isSelected: false,
        );
      }
      onError?.call(1);
    } else {
      if (context.mounted) {
        checkError(inSheet: inSheet, onIsUserChange, context, isSelected: true);
      }
      if (value.name.isNotEmpty) {
        onSelected.call(value);
      }
    }
  } else if (id == 2) {
    /// camera
    final dynamic value = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (final BuildContext context) => Camera(
          imageCamera: imageCamera,
          videoCamera: videoCamera,
          prefixName: prefixName,
        ),
      ),
    );

    if (value == 1 || value == null) {
      // Error
      if (context.mounted) {
        checkError(
          inSheet: inSheet,
          onIsUserChange,
          context,
          isSelected: false,
        );
      }
      onError?.call(1);
    } else {
      if (context.mounted) {
        checkError(inSheet: inSheet, onIsUserChange, context, isSelected: true);
      }
      onSelected.call(value as FullPickerOutput);
    }
  } else if (id == 3) {
    // File
    value = await getFiles(
      context: context,
      fileType: FileType.any,
      pickerFileType: FullPickerType.file,
      prefixName: prefixName,
      multiFile: multiFile,
      inSheet: inSheet,
      onError: onError,
      onIsUserChange: onIsUserChange,
    );

    if (value == null) {
      if (context.mounted) {
        checkError(
          inSheet: inSheet,
          onIsUserChange,
          context,
          isSelected: false,
        );
      }
      onError?.call(1);
    } else {
      if (context.mounted) {
        checkError(inSheet: inSheet, onIsUserChange, context, isSelected: true);
      }
      onSelected.call(value);
    }
  } else if (id == 4) {
    // Voice Recorder and isDismissible is false because recording may be closed unintentionally!
    showSheet(
      VoiceRecorderSheet(
        context: context,
        voiceFileName: '${prefixName}_1.m4a',
        onSelected: (final FullPickerOutput value) {
          checkError(
            inSheet: inSheet,
            onIsUserChange,
            context,
            isSelected: true,
          );
          onSelected.call(value);
          Navigator.of(context).pop();
        },
        onError: (final int value) {
          checkError(
            inSheet: inSheet,
            onIsUserChange,
            context,
            isSelected: true,
          );
          onError?.call(1);
        },
      ),
      context,
      isDismissible: false,
    );
  } else if (id == 5) {
    // get url from URLInputDialog and convert to FullOutput
    final String? url = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext context) =>
          URLInputDialog(body: bodyTextUrl),
    );

    if (url != null) {
      if (context.mounted) {
        checkError(inSheet: inSheet, onIsUserChange, context, isSelected: true);
        onSelected.call(FullPickerOutput.data(url, FullPickerType.url));
      }
    } else {
      if (context.mounted) {
        checkError(inSheet: inSheet, onIsUserChange, context, isSelected: true);
        onError?.call(1);
      }
    }
  }
}

/// Check for control close sheet
void checkError(
  final ValueSetter<bool> onIsUserChange,
  final BuildContext context, {
  required final bool isSelected,
  required final bool inSheet,
}) {
  if (inSheet) {
    onIsUserChange.call(false);

    if (isWeb) {
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
        if (!isSelected) {
          Navigator.of(context).pop();
        }
      }
    }
  }
}

/// Web does not support video compression
/// Video compressor
Future<Uint8List?> videoCompress({
  required final BuildContext context,
  required final Uint8List byte,
  required final PlatformFile file,
}) async {
  if (isWeb) {
    return byte;
  }

  final File mainFile = File(file.path!);
  final ValueNotifier<double> onProgress = ValueNotifier<double>(0);
  final LightCompressor lightCompressor = LightCompressor();

  final int size = int.parse(File(mainFile.path).lengthSync().toString());
  if (size < 50000000) {
    return byte;
  }

  final LightCompressor compressor = LightCompressor();

  final PercentProgressDialog progressDialog = PercentProgressDialog(
    context,
    (final void value) {
      if (onProgress.value.toString() != '1.0') {
        compressor.cancelCompression();
      }
    },
    onProgress,
    globalFullPickerLanguage.onCompressing,
  );

  LightCompressor().onProgressUpdated.listen((final double event) {
    onProgress.value = event / 100;
  });

  try {
    await progressDialog.show();
    final dynamic response = await lightCompressor.compressVideo(
      path: mainFile.path,
      videoQuality: VideoQuality.medium,
      android: AndroidConfig(isSharedStorage: false),
      ios: IOSConfig(saveInGallery: false),
      video: Video(
        videoName: '${DateTime.now().millisecondsSinceEpoch}."mp4"',
        videoBitrateInMbps: 24,
      ),
    );

    progressDialog.dismiss();

    if (response is OnSuccess) {
      final File outputFile = File(response.destinationPath);
      final Uint8List outputByte = outputFile.readAsBytesSync();

      /// delete cash file
      await outputFile.delete();
      return outputByte;
    } else if (response is OnFailure) {
      /// failure message
      return byte;
    } else if (response is OnCancelled) {
      return null;
    }
  } catch (_) {
    return byte;
  }

  return byte;
}

/// web does not support crop Image
/// crop image
Future<Uint8List?> cropImage({
  required final BuildContext context,
  required final Uint8List byte,
  required final String sourcePath,
}) async {
  if (isWeb) {
    return byte;
  }

  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: sourcePath,
    compressQuality: 20,
    aspectRatioPresets: Platform.isAndroid
        ? <CropAspectRatioPreset>[
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ]
        : <CropAspectRatioPreset>[
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9,
          ],
    uiSettings: <PlatformUiSettings>[
      AndroidUiSettings(
        toolbarTitle: globalFullPickerLanguage.cropper,
        toolbarColor: Theme.of(context).colorScheme.surface,
        statusBarColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarWidgetColor: Theme.of(context).colorScheme.primary,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: globalFullPickerLanguage.cropper,
      ),
    ],
  );

  try {
    return await croppedFile!.readAsBytes();
  } catch (_) {
    return null;
  }
}

/// show custom sheet
void showFullPickerToast(final String text, final BuildContext context) {
  final Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      color: const Color(0xFF656565),
    ),
    child: Text(text, style: const TextStyle(color: Color(0xfffefefe))),
  );

  FToast().init(context).showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
      );
}

XFile getFillXFile({
  required final String name,
  required final String mime,
  final Uint8List? bytes,
  final File? file,
}) {
  if (bytes != null) {
    return XFile.fromData(bytes, mimeType: mime, name: name);
  } else {
    return XFile(file!.path, mimeType: mime, name: name);
  }
}
