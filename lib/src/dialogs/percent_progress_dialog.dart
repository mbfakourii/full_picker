import 'dart:async';

import 'package:flutter/material.dart';
import '../dialogs/base_dialog.dart';

/// Percent Progress Dialog help for show Progress
class PercentProgressDialog extends BaseDialog {
  late ValueNotifier<double> onProgress;
  StreamController streamController = StreamController<double>();
  late int percent;
  late String title;

  PercentProgressDialog(
      context, ValueSetter<void> onClose, this.onProgress, this.title)
      : super(context, width: 2, autoHeight: true, onClose: onClose) {
    onProgress.addListener(() {
      if (isOpenDialog) {
        streamController.sink.add(onProgress.value);
      }
    });
  }

  @override
  void dismiss() {
    super.dismiss();
    streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: StreamBuilder<double>(
              stream: streamController.stream as Stream<double>,
              builder: (context, snapshot) {
                try {
                  percent = (snapshot.data! * 100).toInt();
                } catch (error) {
                  percent = 0;
                }

                return Column(
                  children: [
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                      "$percent%",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: LinearProgressIndicator(
                        value: snapshot.data,
                        minHeight: 8,
                      ),
                    ),
                  ],
                );
              }),
        )
      ],
    ));
  }
}
