import 'package:ahille/dialogs/country_code/model/country.dart';
import 'package:ahille/dialogs/country_code/view/country_code_dialog.dart';
import 'package:ahille/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/country_controller.dart';

// ignore_for_file: use_build_context_synchronously
class PhoneTextField extends StatelessWidget {
  const PhoneTextField(this.controller, this.countryController, {Key? key}) : super(key: key);
  final TextEditingController controller;
  final CountryController countryController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 18.sp),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: TextButton(
                    onPressed: () async {
                      Country? country = await showDialog(context: context, builder: (context) => CountryCodeDialog());

                      if (country != null) {
                        countryController.country = country;
                        getUpdatePhoneTextField(context, listen: false).update(country.dialCode, country);
                      }

                      Provider.of<UpdateSearchbar>(context, listen: false).updateText("");
                    },
                    child: Text(getUpdatePhoneTextField(context).text, style: TextStyle(fontSize: 18.sp))),
              ),
            ],
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  UpdatePhoneTextField getUpdatePhoneTextField(context, {bool listen = true}) {
    return Provider.of<UpdatePhoneTextField>(context, listen: listen);
  }
}

class UpdatePhoneTextField extends ChangeNotifier {
  var _text = "+1";
  Country? _country;

  get text => _text;

  Country? get country => _country;

  void update(value, country) {
    _text = value;
    _country = country;
    notifyListeners();
  }
}
