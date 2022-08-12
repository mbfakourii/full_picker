part of 'country_code_bloc.dart';

abstract class CountryCodeEvent extends Equatable {
  const CountryCodeEvent();
}

class CountryCodeStarted extends CountryCodeEvent {
  final int skip;

  const CountryCodeStarted({required this.skip});

  @override
  List<Object> get props => [];
}

class CountryCodeSearch extends CountryCodeEvent {
  final String name;
  final bool searchClick;
  final int skip;
  final DateTime dateTime;

  const CountryCodeSearch({required this.name,required this.searchClick,required this.skip,required this.dateTime});

  @override
  List<Object> get props => [name,searchClick,skip,dateTime];
}
