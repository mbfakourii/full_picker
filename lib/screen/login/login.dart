import 'package:ahille/dialogs/country_code/repository/country_codes_data.dart';
import 'package:ahille/utils/country_controller.dart';
import 'package:ahille/widgets/logo.dart';
import 'package:ahille/widgets/phone_textfield.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../generated/l10n.dart';
import '../../widgets/heading.dart';
import '../../widgets/info.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController phoneTextFieldController = TextEditingController();
  CountryController countryController = CountryController(country: searchCountryByName(S.current.united_states));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(children: [
              Expanded(flex: 9, child: Logo(40.w)),
              Expanded(flex: 5, child: Heading(S.current.welcome, Headings.h3)),
              Expanded(flex: 5, child: Info(S.current.login_text, Icons.info_outline)),
              Expanded(flex: 3, child: Heading(S.current.phone_number, Headings.h4)),
              Expanded(flex: 4, child: PhoneTextField(phoneTextFieldController, countryController)),
              Expanded(flex: 1, child: SizedBox(height: 1.h)),
              Expanded(flex: 4, child: enter()),
              Expanded(flex: 3, child: SizedBox(height: 1.h)),
              Expanded(flex: 3, child: copyRight()),
              Expanded(flex: 2, child: SizedBox(height: 1.h)),
              // MaterialButton(onPressed: () {
              //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyHomePage()));
              // },child: const Text("settings"))
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
            print(phoneTextFieldController.text);
            print(countryController.country.name);
            print(countryController.country.dialCode);
          },
          child: Text(S.current.enter),
        ),
      ),
    );
  }

  copyRight() {
    TextStyle style = TextStyle(
      fontSize: 19.sp,
      color: Theme.of(context).colorScheme.primary,
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
