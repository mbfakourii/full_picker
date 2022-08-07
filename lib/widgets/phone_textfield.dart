import 'package:ahille/dialogs/country_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PhoneTextField extends StatelessWidget {
  const PhoneTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        style: TextStyle(fontSize: 18.sp),
        keyboardType:TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              Padding(
                padding: const EdgeInsets.only(left: 5,right: 5),
                child: TextButton(onPressed: () {
                  showDialog(
                      context: context, builder: (context) =>  CountryCodeDialog());
                },
                child:  Text("+98",style: TextStyle(fontSize: 18.sp))),
              ),
            ],
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
