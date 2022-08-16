import 'package:flutter/material.dart';

class TimerController extends ValueNotifier<TimerValue> {
  TimerController({bool finish = false}) : super(TimerValue(finish: finish));

  bool get finish => value.finish;

  void Function() get reset => value.reset!;

  set finish(bool newFinish) {
    value = value.copyWith(
      finish: newFinish,
      reset: value.reset,
    );
  }

  set reset(void Function()? newReset) {
    value = value.copyWith(
      finish: value.finish,
      reset: newReset,
    );

    notifyListeners();
  }
}

@immutable
class TimerValue {
  const TimerValue({
    required this.finish,
    this.reset,
  });

  final bool finish;
  final void Function()? reset;

  TimerValue copyWith({
    required bool finish,
    void Function()? reset,
  }) {
    return TimerValue(
      finish: finish,
      reset: reset,
    );
  }
}
