import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'base_dialog.dart';

class ProgressDialog extends BaseDialog {
  late ValueNotifier<double> onProgress;
  StreamController streamController = StreamController<double>();
  late int percent;
  late String title;

  ProgressDialog(context, ValueSetter<void> onClose,
      ValueNotifier<double> onProgress, String title)
      : super(context,
      backgroundColor: Color(0xfff2f6ff),
      width: 0.6.w,
      autoHeight: true,
      onClose: onClose) {
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
        color: Color(0xfff2f6ff),
        child: Column(
          children: [
            SizedBox(
              height:0.01.h,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                title,
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                height: 0.08.h,
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
                            height: 0.01.h,
                          ),
                          Text(
                            percent.toString() + "%",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            height: 0.02.h,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: LinearProgressIndicator(
                              value: snapshot.data,
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            )
          ],
        ));
  }
}
