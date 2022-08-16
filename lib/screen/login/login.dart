// ignore_for_file: must_be_immutable

import 'package:ahille/dialogs/country_code/repository/country_codes_data.dart';
import 'package:ahille/screen/verification/verification.dart';
import 'package:ahille/utils/country_controller.dart';
import 'package:ahille/widgets/logo.dart';
import 'package:ahille/widgets/phone_textfield.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../generated/l10n.dart';
import '../../utils/common_utils.dart';
import '../../widgets/copyright.dart';
import '../../widgets/heading.dart';
import '../../widgets/info.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

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
              Expanded(flex: 4, child: enter(context)),
              Expanded(flex: 3, child: SizedBox(height: 1.h)),
              const Expanded(flex: 3, child: Copyright()),
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

  enter(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: SizedBox(
        width: 80.w,
        child: ElevatedButton(
          onPressed: () {
            p(phoneTextFieldController.text);
            p(countryController.country.name);
            p(countryController.country.dialCode);

            go(context, Verification());
          },
          child: Text(S.current.enter),
        ),
      ),
    );
  }
}
