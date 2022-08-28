import 'package:flutter/material.dart';

abstract class BaseDialog {
  late BuildContext context;
  late Dialog _dialog;
  late bool touchOutside;
  late double height;
  late double width;
  late bool autoHeight;
  ValueSetter<void>? onClose;

  late bool _isOpen;

  BaseDialog(this.context,
      {bool? touchOutside,
      double? width,
      double? height,
      Color? backgroundColor,
      this.onClose,
      required this.autoHeight}) {
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
      child = SizedBox(
          width: width,
          child: Column(
              mainAxisSize: MainAxisSize.min, children: [build(context)]));
    } else {
      child = SizedBox(
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
