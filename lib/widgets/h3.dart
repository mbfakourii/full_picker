import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// H3 Text
class H3 extends StatelessWidget {
  const H3(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(text, style: TextStyle(fontSize: 22.sp))),
      ],
    );
  }
}
