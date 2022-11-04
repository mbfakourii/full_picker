import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../full_picker.dart';

/// for cheng language
Language globalLanguage = Language();

class FullPicker {
  final bool image;
  final bool video;
  final bool imageCamera;
  final bool videoCamera;
  final bool file;
  final bool voiceRecorder;
  final bool url;
  final String prefixName;
  final bool videoCompressor;
  final bool imageCropper;
  final bool multiFile;
  final ValueSetter<FullPickerOutput> onSelected;
  final ValueSetter<int>? onError;
  final BuildContext context;

  FullPicker(
      {required this.context,
      Language? language,
      this.image = true,
      this.video = false,
      this.file = false,
      this.url = false,
      this.voiceRecorder = false,
      this.imageCamera = false,
      this.videoCamera = false,
      this.prefixName = "File",
      this.videoCompressor = false,
      this.imageCropper = false,
      this.multiFile = false,
      required this.onSelected,
      this.onError}) {
    /// show or not show sheet for single item or multi item
    int countTrue = 0;
    if (image && video == false) {
      countTrue++;
    } else if (image == false && video) {
      countTrue++;
    } else if (image && video) {
      countTrue++;
    }

    if (language != null) {
      globalLanguage = language;
    }

    if (imageCamera && videoCamera == false) {
      countTrue++;
    } else if (imageCamera == false && videoCamera) {
      countTrue++;
    } else if (imageCamera && videoCamera) {
      countTrue++;
    }

    if (file) countTrue++;
    if (voiceRecorder) countTrue++;
    if (url) countTrue++;

    if (countTrue == 1) {
      /// if single item select
      if (image || video) {
        openAloneFullPicker(1);
      }

      if (file) {
        openAloneFullPicker(3);
      }

      if (voiceRecorder) {
        openAloneFullPicker(4);
      }
      if (url) {
        openAloneFullPicker(5);
      }

      if (imageCamera || videoCamera) {
        openAloneFullPicker(2);
      }
    } else if (countTrue == 0) {
      /// back error
      onError?.call(1);
    } else {
      /// show sheet
      showSheet(
          SelectSheet(
            video: video,
            file: file,
            voiceRecorder: voiceRecorder,
            url: url,
            image: image,
            imageCamera: imageCamera,
            videoCamera: videoCamera,
            context: context,
            videoCompressor: videoCompressor,
            onError: onError,
            onSelected: onSelected,
            prefixName: prefixName,
            imageCropper: imageCropper,
            multiFile: multiFile,
          ),
          context);
    }
  }

  /// show file picker for single item
  void openAloneFullPicker(id) {
    getFullPicker(
      id: id,
      context: context,
      onIsUserCheng: (value) {},
      video: video,
      file: file,
      voiceRecorder: voiceRecorder,
      url: url,
      image: image,
      imageCamera: imageCamera,
      videoCamera: videoCamera,
      videoCompressor: videoCompressor,
      onError: onError,
      onSelected: onSelected,
      prefixName: prefixName,
      imageCropper: imageCropper,
      multiFile: multiFile,
      inSheet: false,
    );
  }
}

/// main Output class
class FullPickerOutput {
  /// main bytes
  late List<Uint8List?> bytes;
  late List<String?> name;

  // datas like url
  late dynamic data;

  /// type file
  late FullPickerType fileType;

  FullPickerOutput(this.bytes, this.fileType, this.name);
  FullPickerOutput.data(this.data, this.fileType);
}

/// File Picker Types
enum FullPickerType { image, video, file, voiceRecorder, url, mixed }

/// item sheet model
class ItemSheet {
  late IconData icon;
  late String name;
  late int id;

  ItemSheet(this.name, this.icon, this.id);
}
