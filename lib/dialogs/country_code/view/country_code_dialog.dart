import 'package:ahille/dialogs/country_code/repository/country_code_repository.dart';
import 'package:ahille/utils/common_utils.dart';
import 'package:ahille/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../generated/l10n.dart';
import '../../../utils/border_radius_m3.dart';
import '../bloc/country_code_bloc.dart';

class CountryCodeDialog extends StatelessWidget  {
  CountryCodeDialog({Key? key}) : super(key: key) {
    countryCodeBloc = CountryCodeBloc(countryCodeRepository: repository);

    countryCodeBloc.add(CountryCodeStarted());
  }

  final CountryCodeRepository repository = CountryCodeRepository();
  late final CountryCodeBloc countryCodeBloc;

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CountryCodeBloc(
            countryCodeRepository: repository,
          )..add(CountryCodeStarted()),
        ),
      ],
      child: BlocProvider(
        create: (context) => countryCodeBloc,
        child: AlertDialog(
          content: Column(
            children: [
              Searchbar(
                onPressed: (value) {
                  countryCodeBloc.add(CountryCodeSearch(name: value, searchClick: true));
                  closeKeyboard(context, false);
                },
                onChanged: (value) {
                  countryCodeBloc.add(CountryCodeSearch(name: value, searchClick: false));
                },
                onClose: () {
                  closeKeyboard(context, true);
                  countryCodeBloc.add(CountryCodeStarted());
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 0.5.h),
                      children: [
                        BlocBuilder<CountryCodeBloc, CountryCodeState>(builder: (context, state) {
                          if (state is CountryCodeEmptySearch) {
                            // toastShow(S.current.no_amount_found);
                            return _buildNotFoundWidget();
                          }

                          if (state is CountryCodeError) {
                            if (state.searchClick) {
                              toastShow(state.error);
                            }
                            countryCodeBloc.add(CountryCodeStarted());
                          }

                          if (state is CountryCodeLoaded) {
                            List<Widget> listCountryWidget = [];
                            for (final country in state.country) {
                              listCountryWidget.add(Card(
                                  child: InkWell(
                                    borderRadius: BorderRadiusM3.medium,
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true).pop(country);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 8, child: Text(country.name)),
                                          Expanded(
                                              flex: 2,
                                              child: Align(
                                                  alignment: AlignmentDirectional.topEnd,
                                                  child: Text(country.dialCode, maxLines: 1))),
                                        ],
                                      ),
                                    ),
                                  )));
                            }
                            return Column(children: listCountryWidget);
                          }

                          return _buildProgressWidget();
                        })
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [CircularProgressIndicator()],
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 50),
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              S.current.not_found,
              style: const TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}
