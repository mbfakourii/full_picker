import 'package:ahille/dialogs/country_code/model/country.dart';
import 'package:flutter/material.dart';

class CountryController extends ValueNotifier<CountryValue> {
  CountryController({required Country country}) : super(CountryValue(country: country));

  Country get country => value.country;

  set country(Country newCountry) {
    value = value.copyWith(
      country: newCountry,
    );
  }
}

@immutable
class CountryValue {
  const CountryValue({
    required this.country,
  });

  final Country country;

  CountryValue copyWith({
    required Country country,
  }) {
    return CountryValue(
      country: country,
    );
  }
}
