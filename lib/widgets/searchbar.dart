import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../dialogs/country_code_dialog.dart';
import '../generated/l10n.dart';

class Searchbar extends StatelessWidget {
  Searchbar({Key? key}) : super(key: key);
  final InputBorder border = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(30),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: S.current.search,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: TextButton(
            child: Icon(
              Icons.search,
              size: 6.w,
            ),
            onPressed: () {
              print(":D");
            },
          ),
        ),
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
