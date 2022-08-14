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
          child: Column(children: [
            Logo(40.w),
            Heading(S.current.welcome, Headings.h3),
            Info(S.current.login_text, Icons.info_outline),
            Heading(S.current.phone_number, Headings.h4),
            PhoneTextField(phoneTextFieldController, countryController),
            enter(),
          ]),
        ),
      ),
    );
  }

  enter() {
    return ElevatedButton(
      onPressed: () {
        print(phoneTextFieldController.text);
        print(countryController.country.name);
        print(countryController.country.dialCode);
      },
      child: Text(S.current.enter),
    );
  }
}
