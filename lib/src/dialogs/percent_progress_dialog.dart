import 'dart:async';

import 'package:flutter/material.dart';
import 'package:full_picker/src/dialogs/base_dialog.dart';

/// Percent Progress Dialog help for show Progress
class PercentProgressDialog extends BaseDialog {
  PercentProgressDialog(
    super.context,
    final ValueSetter<void> onClose,
    this.onProgress,
    this.title,
  ) : super(width: 2, autoHeight: true, onClose: onClose) {
    onProgress.addListener(() {
      if (isOpenDialog) {
        streamController.sink.add(onProgress.value);
      }
    });
  }
  late ValueNotifier<double> onProgress;
  StreamController<double> streamController = StreamController<double>();
  late int percent;
  late String title;

  @override
  void dismiss() {
    super.dismiss();
    streamController.close();
  }

  @override
  Widget build(final BuildContext context) => Card(
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<double>(
                stream: streamController.stream,
                builder: (
                  final BuildContext context,
                  final AsyncSnapshot<double> snapshot,
                ) {
                  try {
                    percent = (snapshot.data! * 100).toInt();
                  } catch (_) {
                    percent = 0;
                  }

                  return Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 1,
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: LinearProgressIndicator(
                          value: snapshot.data,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
}
