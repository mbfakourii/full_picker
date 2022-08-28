import 'dart:async';
import 'package:flutter/material.dart';
import 'base_dialog.dart';

class ProgressIndicatorDialog extends BaseDialog {
  ProgressIndicatorDialog(context) : super(context, width: double.infinity, autoHeight: true);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Card(child: LinearProgressIndicator(minHeight: 8)));
  }
}
