import 'package:ahille/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../generated/l10n.dart';
import '../utils/countrie_codes.dart';

class CountryCodeDialog extends StatelessWidget {
  CountryCodeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Searchbar(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100.h,
                ),
                child: ListView.builder(
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(11.0),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(flex: 6, child: Text(countries[index].name)),
                                  Expanded(flex: 1, child: Text(countries[index].dialCode)),
                                ],
                              ),
                            ),
                          ));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
