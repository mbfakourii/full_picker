import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../full_picker.dart';

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

class Cropper {
  final ValueSetter<OutputFile> onSelected;
  final ValueSetter<int> onError;

  final String imageName;

  Cropper(this.context, {Key? key, required this.onSelected, required this.onError, required this.imageName}) {
    cropImage();
  }

  BuildContext context;
  bool userClose = true;
  bool firstCropSelected = true;

  void cropImage() async {
    if (firstCropSelected == false) {
      return;
    }
    firstCropSelected = false;

    CroppedFile? croppedFile = await await ImageCropper().cropImage(
      sourcePath: imageName,
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

    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      var byteData = await croppedFile!.readAsBytes();
      var buffer = byteData.buffer.asUint8List();
      Directory extDir;
      if (io.Platform.isIOS) {
        extDir = await getApplicationDocumentsDirectory();
      } else {
        extDir = (await getExternalStorageDirectory())!;
      }
      String dirPAth = "${extDir.path}/Pictures";
      await Directory(dirPAth).create(recursive: true);
      File file = File('$dirPAth/${timestamp()}.jpg');
      await file.writeAsBytes(buffer);
      userClose = false;
      onSelected.call(OutputFile([file.readAsBytesSync()], PickerFileType.IMAGE, [file.path]));
    }
  }

  void dispose() {
    if (userClose) {
      //44 for bug
      onError.call(44);
    }
  }
}
