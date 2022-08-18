import 'package:flutter/material.dart';
import 'package:full_picker/src/utils/language.dart';
import 'dart:io';
import '../../full_picker.dart';

 final Language language=Language();

class FullPicker {
  final bool? image;
  final bool? audio;
  final bool? video;
  final bool? file;
  final bool? videoCompressor;
  final ValueSetter<OutputFile>? onSelected;
  final ValueSetter<int>? onError;
  final BuildContext? context;

  FullPicker(
      {required this.context,
      Language? languageLocal,
      this.image,
      this.audio,
      this.video,
      this.file,
      this.videoCompressor,
      required this.onSelected,
      required this.onError}) {
    int countTrue = 0;

    if (image!) countTrue++;
    if (audio!) countTrue++;
    if (video!) countTrue++;
    if (file!) countTrue++;

    // languageLocal == null ? language = Language() : language = languageLocal;

    if (countTrue == 1) {
      if (audio!) {
        executedAudioPicker(false, true, false, false, context!, true, onSelected!, onError!);
      }

      if (file!) {
        executedFilePicker(context!, true, onSelected!, onError!);
      }

      if (video!) {
        executedVideoPicker(false, false, true, false, context!, true, onSelected!, onError!, videoCompressor!);
      }

      if (image!) {
        executedImagePicker(true, false, false, false, context!, true, onSelected!, onError!);
      }
    } else {
      showSheet(
          SheetSelect(
            video: video,
            audio: audio,
            file: file,
            image: image,
            context: context,
            videoCompressor: videoCompressor,
            onError: onError,
            onSelected: onSelected,
          ),
          context!);
    }
  }
}

class OutputFile {
  //main file
  late File file;

  //type file
  late PickerFileType fileType;

  OutputFile(File file, PickerFileType fileType) {
    this.file = file;
    this.fileType = fileType;
  }
}

enum PickerFileType { IMAGE, VIDEO, AUDIO, FILE, OTHER }
