import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../dialogs/base_dialog.dart';

class PercentProgressDialog extends BaseDialog {
  late ValueNotifier<double> onProgress;
  StreamController streamController = StreamController<double>();
  late int percent;
  late String title;

  PercentProgressDialog(context, ValueSetter<void> onClose, ValueNotifier<double> onProgress, String title)
      : super(context, width: 0.6.w, autoHeight: true, onClose: onClose) {
    this.onProgress = onProgress;
    this.title = title;

    this.onProgress.addListener(() {
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
              style: TextStyle(fontSize: 20),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                        SizedBox(
                          height: 1.h,
                        ),
                        Text(
                          percent.toString() + "%",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 2.h,
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
