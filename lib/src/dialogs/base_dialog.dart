import 'package:flutter/material.dart';

abstract class BaseDialog {
  late var context;
  late Dialog _dialog;
  late bool touchOutside;
  late double height;
  late double width;
  late bool autoHeight;
  ValueSetter<void>? onClose;

  late bool _isOpen;

  BaseDialog(context,
      {bool? touchOutside,
      double? width,
      double? height,
      Color? backgroundColor,
      ValueSetter<void>? onClose,
      required bool autoHeight}) {
    this.context = context;
    this.onClose = onClose;
    this.autoHeight = autoHeight;
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

  void dismiss() {
    if (_isOpen == false) return;
    _isOpen = false;
    Navigator.of(context).pop();
  }

  Future<void> show() async {
    Widget child;
    if (autoHeight) {
      child = Container(
          width: width,
          child: Column(
              mainAxisSize: MainAxisSize.min, children: [build(context)]));
    } else {
      child = Container(
          height: height,
          width: width,
          child: Column(
              mainAxisSize: MainAxisSize.min, children: [build(context)]));
    }
    _dialog = Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        //this right here
        child: child);

    await showDialog(
            barrierDismissible: touchOutside, context: context, builder: (BuildContext context) => _dialog)
        .then((value) => {
              if (onClose != null)
                {onClose!.call(null), _isOpen = false, dismiss()}
            });
  }

  Dialog get dialog => _dialog;

  bool get isOpenDialog => _isOpen;

  @protected
  Widget build(BuildContext context);
}
