import 'package:flutter/material.dart';

/// Widget icon
///
/// ```dart
/// fullPickerWidgetIcon: FullPickerWidgetIcon.copy(
/// 	gallery: Icon(Icons.gamepad, size: 30),
/// ),
/// ```
class FullPickerWidgetIcon {
  FullPickerWidgetIcon();

  /// help for cheng widget icons
  FullPickerWidgetIcon.copy({
    this.gallery,
    this.camera,
    this.file,
    this.voice,
    this.url,
  });

  Widget? gallery;
  Widget? camera;
  Widget? file;
  Widget? voice;
  Widget? url;
}
