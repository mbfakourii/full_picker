import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:full_picker/src/sheets/sheet_select2.dart';
import 'package:full_picker/src/utils/language.dart';
import '../../full_picker.dart';

final Language language = Language();

class FullPicker {
  final bool? image;
  final bool? video;
  final bool? imageCamera;
  final bool? videoCamera;
  final bool? file;
  final String firstPartFileName;
  final bool videoCompressor;
  final bool imageCropper;
  final bool multiFile;
  final ValueSetter<OutputFile> onSelected;
  final ValueSetter<int> onError;
  final BuildContext context;

  FullPicker(
      {required this.context,
      Language? languageLocal,
      this.image,
      this.video,
      this.file,
      this.imageCamera,
      this.videoCamera,
      this.firstPartFileName = "File",
      this.videoCompressor = false,
      this.imageCropper = false,
      this.multiFile = false,
      required this.onSelected,
      required this.onError}) {
    int countTrue = 0;

    if (image!) countTrue++;
    if (video!) countTrue++;
    if (file!) countTrue++;

    if (countTrue == 1) {
      if (file!) {
        executedFilePicker(
            context: context,
            showAlone: true,
            onSelected: onSelected,
            onError: onError,
            fileType: PickerFileType.FILE,
            firstPartFileName: firstPartFileName,
            allowMultiple: multiFile);
      }

      if (video!) {
        executedVideoPicker(false, false, true, context, true, onSelected, onError, videoCompressor, firstPartFileName);
      }

      if (image!) {
        executedImagePicker(true, false, false, context, true, onSelected, onError, firstPartFileName);
      }
    } else {
      showSheet(
          SheetSelect2(
            video: video ?? false,
            file: file ?? false,
            image: image ?? false,
            imageCamera: imageCamera ?? false,
            videoCamera: videoCamera ?? false,
            context: context,
            videoCompressor: videoCompressor,
            onError: onError,
            onSelected: onSelected,
            firstPartFileName: firstPartFileName,
            imageCropper: imageCropper,
            multiFile: multiFile,
            allowMultiple: multiFile,
          ),
          context);
    }
  }
}

class OutputFile {
  //main bytes
  late List<Uint8List?> bytes;
  late List<String?> name;

  //type file
  late PickerFileType fileType;

  OutputFile(this.bytes, this.fileType, this.name);
}

enum PickerFileType { IMAGE, VIDEO, FILE, MIXED }

class ItemSheet {
  late IconData icon;
  late String name;
  late int id;

  ItemSheet(this.name, this.icon, this.id);
}
