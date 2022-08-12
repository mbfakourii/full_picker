import 'package:ahille/dialogs/country_code/model/country.dart';
import 'package:ahille/dialogs/country_code/view/update_country_code.dart';
import 'package:ahille/utils/common_utils.dart';
import 'package:ahille/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../generated/l10n.dart';
import '../../../utils/border_radius_m3.dart';
import '../bloc/country_code_bloc.dart';

//ignore: must_be_immutable
class CountryCodeDialog extends StatelessWidget {
  late DateTime lastDateTime;
  final PagingController<int, Country> _pagingController = PagingController(firstPageKey: 0);
  String lastStringSearch = "";
  int lastPageKey = 0;
  late BuildContext holdContext;
  late final CountryCodeBloc countryCodeBloc;

  CountryCodeDialog({Key? key}) : super(key: key) {
    // init bloc and first request
    countryCodeBloc = CountryCodeBloc();
    countryCodeBloc.add(CountryCodeSearch(name: lastStringSearch, skip: 0));

    // init listen bloc
    countryCodeBloc.stream.listen((state) {
      if (state is CountryCodeLoaded) {
        // for ignore old search in real time search
        if (state.dateTime != null) {
          if (state.dateTime != lastDateTime) return;
        }

        // send Update To provider class
        getUpdateNavigation(holdContext, listen: false)
            .updateListview(state.country, holdContext, lastPageKey, _pagingController);
      }

      getUpdateNavigation(holdContext, listen: false).backState = state;
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pagingController.addPageRequestListener((pageKey) {
        lastPageKey = pageKey;

        _fetchPage(pageKey);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CountryCodeBloc(),
        ),
      ],
      child: BlocProvider(
        create: (context) => countryCodeBloc,
        child: AlertDialog(
          content: Column(
            children: [
              Searchbar(
                onPressed: (value) {
                  closeKeyboard(context, false);
                  lastStringSearch = value;
                  _pagingController.refresh();
                },
                onChanged: (value) {
                  lastStringSearch = value;
                  _pagingController.refresh();
                },
                onClose: () {
                  closeKeyboard(context, true);
                  lastStringSearch = "";
                  _pagingController.refresh();
                },
              ),
              Expanded(
                child: SizedBox(
                    width: double.maxFinite,
                    child: Consumer<UpdateCountryCode>(builder: (context, value, child) {
                      holdContext = context;

                      if (value.backState is CountryCodeError) {
                        _pagingController.error = value.backState.error;
                      }

                      return PagedListView<int, Country>(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<Country>(
                            animateTransitions: true,
                            firstPageProgressIndicatorBuilder: (context) => _buildProgressWidget(),
                            newPageProgressIndicatorBuilder: (context) => _buildProgressWidget(),
                            firstPageErrorIndicatorBuilder: (context) => _buildNotFoundWidget(),
                            newPageErrorIndicatorBuilder: (context) => _buildNotFoundWidget(),
                            noItemsFoundIndicatorBuilder: (context) => _buildNotFoundWidget(),
                            itemBuilder: (context, item, index) => Card(
                                    child: InkWell(
                                  borderRadius: BorderRadiusM3.medium,
                                  onTap: () {
                                    countryCodeBloc.close();
                                    Navigator.of(context).pop(item);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 8, child: Text(item.name)),
                                        Expanded(
                                            flex: 2,
                                            child: Align(
                                                alignment: AlignmentDirectional.topEnd,
                                                child: Text(item.dialCode, maxLines: 1))),
                                      ],
                                    ),
                                  ),
                                ))),
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
      padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
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

  void _fetchPage(int pageKey) {
    if (pageKey == 0) {
      getUpdateNavigation(holdContext, listen: false).skip = 0;
    }

    int skip = getUpdateNavigation(holdContext).skip;

    lastDateTime = DateTime.now();
    countryCodeBloc.add(CountryCodeSearch(name: lastStringSearch, skip: skip, dateTime: lastDateTime));
  }
}
