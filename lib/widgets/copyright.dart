import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../generated/l10n.dart';

class Copyright extends StatelessWidget {
  const Copyright({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      fontSize: 19.sp,
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold
    );
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: S.current.copyright_first_part,
          style: style,
        ),
        TextSpan(
          text: S.current.exon,
          style: style,
        ),
        TextSpan(
          text: S.current.copyright_second_part,
          style: style,
        ),
      ]),
    );
  }
}
