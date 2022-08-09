import '../model/country.dart';
import 'country_codes_data.dart';

class CountryCodeRepository {
  Future<List<Country>> loadCountryCode() async {
    return countries;
  }

  Future<List<Country>> searchCountryName(String name) async {
    List<Country> listSearch=[];
    name=name.toLowerCase();
    for (var element in countries) {
      if(element.name.toLowerCase().contains(name)){
        listSearch.add(element);
      }
    }

    return listSearch;
  }
}
