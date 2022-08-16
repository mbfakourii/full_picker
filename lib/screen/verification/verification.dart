// ignore_for_file: must_be_immutable
import 'package:ahille/screen/verification/widget/pincode.dart';
import 'package:ahille/screen/verification/widget/timer_show/timer_controller.dart';
import 'package:ahille/screen/verification/widget/timer_show/timer_show.dart';
import 'package:ahille/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../generated/l10n.dart';
import '../../utils/common_utils.dart';
import '../../widgets/copyright.dart';
import '../../widgets/heading.dart';
import '../../widgets/info.dart';

class Verification extends StatelessWidget {
  Verification({Key? key}) : super(key: key);

  TimerController timerController = TimerController();
  TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(children: [
              Expanded(flex: 11, child: Logo(40.w)),
              Expanded(flex: 3, child: Heading(S.current.verification_code, Headings.h3)),
              Expanded(flex: 5, child: Info(S.current.send_verification_code("989351714601"), Icons.info_outline)),
              Expanded(flex: 1, child: SizedBox(height: 1.h)),
              Expanded(flex: 4, child: Pincode(pinController,(value) {
               p(value);
              })),
              Expanded(flex: 1, child: SizedBox(height: 1.h)),
              Expanded(flex: 2, child: TimerShow(timerController)),
              Expanded(flex: 3, child: reSend()),
              Expanded(flex: 1, child: SizedBox(height: 1.h)),
              Expanded(flex: 4, child: enter()),
              Expanded(flex: 3, child: SizedBox(height: 1.h)),
              const Expanded(flex: 3, child: Copyright()),
              Expanded(flex: 2, child: SizedBox(height: 1.h)),
            ]),
          ),
        ),
      ),
    );
  }

  enter() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: SizedBox(
        width: 80.w,
        child: ElevatedButton(
          onPressed: () {

            print(pinController.text);
          },
          child: Text(S.current.confirm),
        ),
      ),
    );
  }


  reSend() {
    return Visibility(
      visible: true,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(S.current.no_send_verification_code, textAlign: TextAlign.end, style: TextStyle(fontSize: 17.sp)),
        TextButton(
            onPressed: () {
              timerController.reset();
            },
            child: Text(S.current.resend_verification_code,
                textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp))),
      ]),
    );
  }
}
