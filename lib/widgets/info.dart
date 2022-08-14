import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Info extends StatelessWidget {
  const Info(this.text, this.icon, {Key? key, this.useCard = true}) : super(key: key);

  final IconData icon;
  final String text;
  final bool useCard;

  getMainWidget(icon, text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Icon(icon),
          ),
          Expanded(
            flex: 8,
            child: Text(text, style: TextStyle(fontSize: 17.sp)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return useCard ? Card(child: getMainWidget(icon, text)) : getMainWidget(icon, text);
  }
}
