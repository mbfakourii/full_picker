part of 'country_code_bloc.dart';

abstract class CountryCodeEvent extends Equatable {
  const CountryCodeEvent();
}

class CountryCodeSearch extends CountryCodeEvent {
  final String name;
  final int skip;
  final DateTime? dateTime;

  const CountryCodeSearch({required this.name, required this.skip, this.dateTime});

  @override
  List<Object> get props => [name, skip];
}
