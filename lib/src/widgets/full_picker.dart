import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:full_picker/full_picker.dart';

/// for cheng language
FullPickerLanguage globalFullPickerLanguage = FullPickerLanguage();

class FullPicker {
  FullPicker({
    required this.context,
    required this.onSelected,
    final FullPickerLanguage? language,
    this.image = true,
    this.video = false,
    this.file = false,
    this.url = false,
    this.bodyTextUrl = '',
    this.voiceRecorder = false,
    this.imageCamera = false,
    this.videoCamera = false,
    this.prefixName = '',
    this.videoCompressor = false,
    this.imageCropper = false,
    this.multiFile = false,
    this.onError,
  }) {
    /// show or not show sheet for single item or multi item
    int countTrue = 0;
    if (image && !video) {
      countTrue++;
    } else if (!image && video) {
      countTrue++;
    } else if (image && video) {
      countTrue++;
    }

    if (language != null) {
      globalFullPickerLanguage = language;
    }

    if (imageCamera && !videoCamera) {
      countTrue++;
    } else if (!imageCamera && videoCamera) {
      countTrue++;
    } else if (imageCamera && videoCamera) {
      countTrue++;
    }

    if (file) {
      countTrue++;
    }
    if (voiceRecorder) {
      countTrue++;
    }
    if (url) {
      countTrue++;
    }

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
          bodyTextUrl: bodyTextUrl,
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
        context,
      );
    }
  }
  final bool image;
  final bool video;
  final bool imageCamera;
  final bool videoCamera;
  final bool file;
  final bool voiceRecorder;
  final bool url;
  final String bodyTextUrl;
  final String prefixName;
  final bool videoCompressor;
  final bool imageCropper;
  final bool multiFile;
  final ValueSetter<FullPickerOutput> onSelected;
  final ValueSetter<int>? onError;
  final BuildContext context;

  /// show file picker for single item
  void openAloneFullPicker(final int id) {
    getFullPicker(
      id: id,
      context: context,
      onIsUserChange: (final bool value) {},
      video: video,
      file: file,
      voiceRecorder: voiceRecorder,
      url: url,
      bodyTextUrl: bodyTextUrl,
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
  FullPickerOutput(this.bytes, this.fileType, this.name, this.file);

  FullPickerOutput.data(this.data, this.fileType);

  /// main bytes
  late List<Uint8List?> bytes;
  late List<File?> file;
  late List<String?> name;

  // datas like url
  late dynamic data;

  /// type file
  late FullPickerType fileType;
}

/// File Picker Types
enum FullPickerType { image, video, file, voiceRecorder, url, mixed }

/// item sheet model
class ItemSheet {
  ItemSheet(this.name, this.icon, this.id);
  late IconData icon;
  late String name;
  late int id;
}
