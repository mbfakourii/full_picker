import 'package:ahille/widgets/h3.dart';
import 'package:ahille/widgets/info.dart';
import 'package:ahille/widgets/logo.dart';
import 'package:ahille/widgets/phone_textfield.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../generated/l10n.dart';
import '../settings/settingsmain.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(children: [
          Logo(40.w),
          H3(S.current.welcome),
          Info(S.current.login_text, Icons.info_outline),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Test"),
          ),
          // OutlinedButton(
          //   onPressed: () {},
          //   child: const Text("Test"),
          // )

          const PhoneTextField(),
          MaterialButton(onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyHomePage()));
          },child: const Text("settings"))
        ]),
      ),
    );
  }
}
