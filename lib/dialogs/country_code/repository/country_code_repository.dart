import '../model/country.dart';
import 'country_codes_data.dart';

class CountryCodeRepository {
  Future<List<Country>> loadCountryCode(skip) async {
    return _getSkipData(countries, skip);
  }

  Future<List<Country>> searchCountryName(String name, skip) async {
    List<Country> listSearch = [];
    name = name.toLowerCase();
    for (var element in countries) {
      if (element.name.toLowerCase().contains(name)) {
        listSearch.add(element);
      }
    }

    return _getSkipData(listSearch, skip);
  }

  Future<List<Country>> _getSkipData(List<Country> data, int skip) async {
    await new Future.delayed(new Duration(seconds: 2));
    return data.skip(20 * skip).take(20).toList();
  }
}
