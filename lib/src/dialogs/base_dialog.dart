import 'package:flutter/material.dart';

/// BaseDialog for help show dialog
abstract class BaseDialog {
  BaseDialog(
    this.context, {
    required this.autoHeight,
    final bool? touchOutside,
    final double? width,
    final double? height,
    this.onClose,
  }) {
    _isOpen = true;

    if (touchOutside == null) {
      this.touchOutside = true;
    } else {
      this.touchOutside = touchOutside;
    }

    if (width == null) {
      this.width = 300.0;
    } else {
      this.width = width;
    }

    if (height == null) {
      this.height = 300.0;
    } else {
      this.height = height;
    }
  }

  /// context help show dialog
  late BuildContext context;

  late Dialog _dialog;
  late bool touchOutside;
  late double height;
  late double width;
  late bool autoHeight;
  ValueSetter<void>? onClose;

  late bool _isOpen;

  /// dismiss dialog
  void dismiss() {
    if (!_isOpen) {
      return;
    }
    _isOpen = false;
    Navigator.of(context).pop();
  }

  /// show dialog
  Future<void> show() async {
    Widget child;
    if (autoHeight) {
      child = SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[build(context)],
        ),
      );
    } else {
      child = SizedBox(
        height: height,
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[build(context)],
        ),
      );
    }
    _dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      /// this right here
      child: child,
    );

    await showDialog<void>(
      barrierDismissible: touchOutside,
      context: context,
      builder: (final BuildContext context) => _dialog,
    ).then(
      (final _) => <Set<void>>{
        if (onClose != null)
          <void>{onClose!.call(null), _isOpen = false, dismiss()},
      },
    );
  }

  /// get dialog
  Dialog get dialog => _dialog;

  /// open dialog ?
  bool get isOpenDialog => _isOpen;

  @protected
  Widget build(final BuildContext context);
}
