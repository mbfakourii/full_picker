part of 'country_code_bloc.dart';

abstract class CountryCodeState extends Equatable {
  const CountryCodeState();

  @override
  List<Object> get props => [];
}

class CountryCodeLoaded extends CountryCodeState {
  const CountryCodeLoaded(this.country,this.skip,this.dateTime, this.searchClick);
  final int skip;
  final List<Country> country;
  final DateTime dateTime;
  final bool searchClick;

  @override
  List<Object> get props => [country,dateTime,skip,searchClick];
}

class CountryCodeLoading extends CountryCodeState {}

class CountryCodeError extends CountryCodeState {
  const CountryCodeError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

class CountryCodeEmptySearch extends CountryCodeState {
  const CountryCodeEmptySearch();

  @override
  List<Object> get props => [];
}
