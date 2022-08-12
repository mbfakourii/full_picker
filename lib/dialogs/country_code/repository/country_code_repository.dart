import '../model/country.dart';
import 'country_codes_data.dart';

class CountryCodeRepository {
  static final CountryCodeRepository _shared = CountryCodeRepository._internal();

  CountryCodeRepository._internal();
  factory CountryCodeRepository() {
    return _shared;
  }

  Future<List<Country>> searchCountryName(String name, skip) async {
    List<Country> listSearch = [];
    name = name.toLowerCase();
    if (name == "") {
      listSearch = countries;
    } else {
      for (var element in countries) {
        if (element.name.toLowerCase().contains(name)) {
          listSearch.add(element);
        }
      }
    }

    return _getSkipData(listSearch, skip);
  }

  Future<List<Country>> _getSkipData(List<Country> data, int skip) async {
    return data.skip(20 * skip).take(20).toList();
  }
}
