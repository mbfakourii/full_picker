import 'dart:async';
import 'package:ahille/screen/verification/widget/timer_show/timer_controller.dart';
import 'package:flutter/material.dart';
import '../../../../config/config.dart';
import '../../../../widgets/heading.dart';

class TimerShow extends StatefulWidget {
  const TimerShow(this.timerController, {Key? key}) : super(key: key);

  final TimerController timerController;

  @override
  State<TimerShow> createState() => _TimerShowState();
}

class _TimerShowState extends State<TimerShow> {
  final interval = const Duration(seconds: 1);


  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSecondsVerification - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSecondsVerification - currentSeconds) % 60).toString().padLeft(2, '0')}';
  late Timer timer;


  startTimeout() {
    widget.timerController.finish = false;
    var duration = interval;

    timer = Timer.periodic(duration, (timer) {
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSecondsVerification) {
          timer.cancel();
          widget.timerController.finish = true;
        }
      });
    });
  }

  @override
  void initState() {
    startTimeout();
    widget.timerController.reset = () {
      setState(() {
        if (timer.isActive) {
          timer.cancel();
        }

        currentSeconds = 0;
        startTimeout();
      });
    };

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Heading(
        timerText,
        Headings.h4,
        center: true,
      ),
    );
  }
}
