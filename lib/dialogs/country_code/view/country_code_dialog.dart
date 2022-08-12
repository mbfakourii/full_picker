import 'package:ahille/dialogs/country_code/repository/country_code_repository.dart';
import 'package:ahille/dialogs/country_code/view/update_country_code.dart';
import 'package:ahille/utils/common_utils.dart';
import 'package:ahille/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import '../../../generated/l10n.dart';
import '../../../utils/border_radius_m3.dart';
import '../bloc/country_code_bloc.dart';

class CountryCodeDialog extends StatelessWidget {
  late DateTime lastDateTime;

  CountryCodeDialog({Key? key}) : super(key: key) {
    countryCodeBloc = CountryCodeBloc(countryCodeRepository: repository);

    countryCodeBloc.add(const CountryCodeStarted(skip: 0));

    countryCodeBloc.stream.listen((state) {
      if (state is CountryCodeError) {
        countryCodeBloc.add(const CountryCodeStarted(skip: 0));
      }

      if (state is CountryCodeLoaded) {
        if (!state.searchClick) {
          if (state.dateTime != lastDateTime) return;
        }
        getUpdateNavigation(main, listen: false).updateListview(state.country, main);
        getUpdateNavigation(main, listen: false).skip = state.skip + 1;
      }

      getUpdateNavigation(main, listen: false).backState = state;
    });
  }

  late BuildContext main;
  final CountryCodeRepository repository = CountryCodeRepository();
  late final CountryCodeBloc countryCodeBloc;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CountryCodeBloc(
            countryCodeRepository: repository,
          )..add(const CountryCodeStarted(skip: 0)),
        ),
      ],
      child: BlocProvider(
        create: (context) => countryCodeBloc,
        child: AlertDialog(
          content: Column(
            children: [
              Searchbar(
                onPressed: (value) {
                  countryCodeBloc
                      .add(CountryCodeSearch(name: value, searchClick: true, skip: 0, dateTime: DateTime.now()));
                  closeKeyboard(context, false);
                  getUpdateNavigation(context, listen: false).nowSearch = true;
                  getUpdateNavigation(context, listen: false).lastTextSearch = value;
                  getUpdateNavigation(context, listen: false).clearData();
                },
                onChanged: (value) {
                  lastDateTime = DateTime.now();
                  countryCodeBloc
                      .add(CountryCodeSearch(name: value, searchClick: false, skip: 0, dateTime: lastDateTime));
                  getUpdateNavigation(context, listen: false).nowSearch = true;
                  getUpdateNavigation(context, listen: false).lastTextSearch = value;
                  getUpdateNavigation(context, listen: false).clearData();
                },
                onClose: () {
                  getUpdateNavigation(context, listen: false).nowSearch = false;
                  closeKeyboard(context, true);
                  getUpdateNavigation(context, listen: false).clearData();
                  countryCodeBloc.add(const CountryCodeStarted(skip: 0));
                },
              ),
              Expanded(
                child: SizedBox(
                    width: double.maxFinite,
                    child: Consumer<UpdateCountryCode>(builder: (context, value, child) {
                      main = context;

                      if (value.backState is CountryCodeEmptySearch) {
                        return _buildNotFoundWidget();
                      }

                      // if (value.backState is CountryCodeLoading) {
                      //   if(getUpdateNavigation(context, listen: true).getCountries.isEmpty) {
                      //     return _buildProgressWidget();
                      //   }
                      // }

                      return LazyLoadScrollView(
                        isLoading: getUpdateNavigation(context, listen: true).isLoading,
                        onEndOfPage: () {
                          bool isNowSearch = getUpdateNavigation(context).nowSearch;
                          int skip = getUpdateNavigation(context).skip;
                          String lastTextSearch = getUpdateNavigation(context).lastTextSearch;

                          if (isNowSearch) {
                            lastDateTime = DateTime.now();
                            countryCodeBloc.add(CountryCodeSearch(
                                name: lastTextSearch, searchClick: false, skip: skip, dateTime: lastDateTime));
                          } else {
                            countryCodeBloc.add(CountryCodeStarted(skip: skip));
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 0.5.h),
                                itemCount: value.getCountries.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                      child: InkWell(
                                    borderRadius: BorderRadiusM3.medium,
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true).pop(value.getCountries[index]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 8, child: Text(value.getCountries[index].name)),
                                          Expanded(
                                              flex: 2,
                                              child: Align(
                                                  alignment: AlignmentDirectional.topEnd,
                                                  child: Text(value.getCountries[index].dialCode, maxLines: 1))),
                                        ],
                                      ),
                                    ),
                                  ));
                                },
                              ),
                            ),
                            Visibility(visible: value.backState is CountryCodeLoading, child: _buildProgressWidget())
                          ],
                        ),
                      );
                    })),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UpdateCountryCode getUpdateNavigation(context, {bool listen = false}) {
    return Provider.of<UpdateCountryCode>(context, listen: listen);
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
