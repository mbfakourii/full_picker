part of 'country_code_bloc.dart';

abstract class CountryCodeState extends Equatable {
  const CountryCodeState();

  @override
  List<Object> get props => [];
}

class CountryCodeLoaded extends CountryCodeState {
  const CountryCodeLoaded(this.country);

  final List<Country> country;

  @override
  List<Object> get props => [country];
}

class CountryCodeLoading extends CountryCodeState {}

class CountryCodeError extends CountryCodeState {
  const CountryCodeError(this.error, this.searchClick);

  final bool searchClick;
  final String error;

  @override
  List<Object> get props => [error, searchClick];
}

class CountryCodeEmptySearch extends CountryCodeState {
  const CountryCodeEmptySearch(this.searchClick);

  final bool searchClick;

  @override
  List<Object> get props => [searchClick];
}
