import 'dart:async';

import 'package:flutter/material.dart';
import 'package:full_picker/src/dialogs/base_dialog.dart';

/// Progress Indicator Dialog for keep waiting
class ProgressIndicatorDialog extends BaseDialog {
  ProgressIndicatorDialog(super.context)
      : super(width: double.infinity, autoHeight: true);

  @override
  Widget build(final BuildContext context) => WillPopScope(
        onWillPop: () => Future<bool>.value(false),
        child: const Card(child: LinearProgressIndicator(minHeight: 8)),
      );
}
