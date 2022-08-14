import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

enum Headings { h1, h2, h3, h4, h5, h6 }

// Heading Text
class Heading extends StatelessWidget {
  const Heading(this.text, this.type, {Key? key}) : super(key: key);
  final String text;
  final Headings type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(text, style: TextStyle(fontSize: () {
          switch (type) {
            case Headings.h1:
              return 29.sp;
            case Headings.h2:
              return 26.sp;
            case Headings.h3:
              return 22.sp;
            case Headings.h4:
              return 19.sp;
            case Headings.h5:
              return 17.sp;
            case Headings.h6:
              return 15.sp;
          }
        }()))),
      ],
    );
  }
}
