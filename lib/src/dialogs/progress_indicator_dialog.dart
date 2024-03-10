import 'package:flutter/material.dart';
import 'package:full_picker/src/dialogs/base_dialog.dart';

/// Progress Indicator Dialog for keep waiting
class ProgressIndicatorDialog extends BaseDialog {
  ProgressIndicatorDialog(super.context)
      : super(width: double.infinity, autoHeight: true);

  @override
  Widget build(final BuildContext context) => const PopScope(
        canPop: false,
        child: Card(child: LinearProgressIndicator(minHeight: 8)),
      );
}
