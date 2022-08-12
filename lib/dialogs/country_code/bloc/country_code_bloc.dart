import 'dart:async';
import 'package:ahille/dialogs/country_code/repository/country_code_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../generated/l10n.dart';
import '../model/country.dart';

part 'country_code_event.dart';

part 'country_code_state.dart';

class CountryCodeBloc extends Bloc<CountryCodeEvent, CountryCodeState> {
  CountryCodeBloc() : super(CountryCodeLoading()) {
    on<CountryCodeSearch>(_onSearch);
  }

  Future<void> _onSearch(
    CountryCodeSearch event,
    Emitter<CountryCodeState> emit,
  ) async {
    emit(CountryCodeLoading());
    try {
      final countryCode = await CountryCodeRepository().searchCountryName(event.name, event.skip);
      if (countryCode.isEmpty) {
        emit(CountryCodeError(S.current.no_value_found));
      } else {
        emit(CountryCodeLoaded(countryCode, event.skip, event.dateTime));
      }
    } catch (_) {
      emit(CountryCodeError(S.current.unknown_error));
    }
  }
}
