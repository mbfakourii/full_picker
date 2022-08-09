part of 'country_code_bloc.dart';

abstract class CountryCodeEvent extends Equatable {
  const CountryCodeEvent();
}

class CountryCodeStarted extends CountryCodeEvent {
  @override
  List<Object> get props => [];
}

class CountryCodeSearch extends CountryCodeEvent {
  final String name;
  final bool searchClick;

  const CountryCodeSearch({required this.name,required this.searchClick});

  @override
  List<Object> get props => [name];
}
