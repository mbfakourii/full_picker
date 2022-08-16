import 'package:ahille/utils/border_radius_m3.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Pincode extends StatefulWidget {
  const Pincode(this.pinController, this.onCompleted, {Key? key}) : super(key: key);
  final TextEditingController pinController;
  final ValueChanged<String>? onCompleted;

  @override
  State<Pincode> createState() => _PincodeState();
}

class _PincodeState extends State<Pincode> {
  @override
  void initState() {
    pinputFocusNode.requestFocus();
    super.initState();
  }

  final pinputFocusNode = FocusNode();

  @override
  void dispose() {
    widget.pinController.dispose();
    pinputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 15.w,
      height: 20.h,
      textStyle: TextStyle(fontSize: 19.sp, color: Theme.of(context).colorScheme.secondaryContainer),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadiusM3.medium,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        defaultPinTheme: defaultPinTheme,
        controller: widget.pinController,
        androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
        listenForMultipleSmsOnAndroid: true,
        focusNode: pinputFocusNode,
        onCompleted: widget.onCompleted,
        onClipboardFound: (value) => widget.pinController.setText(value),
      ),
    );
  }
}
