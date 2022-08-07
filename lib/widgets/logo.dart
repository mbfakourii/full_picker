import 'package:flutter/material.dart';

import 'image_show.dart';

class Logo extends StatelessWidget {
  const Logo(this.size, {Key? key}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageShow(
          "assets/images/ahille.png",
          width: size,
          height: size,
        ),
      ],
    );
  }
}
