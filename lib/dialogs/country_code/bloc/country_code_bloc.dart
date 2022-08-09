import 'dart:async';
import 'package:ahille/dialogs/country_code/repository/country_code_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../generated/l10n.dart';
import '../../../validator/common_validator.dart';
import '../model/country.dart';

part 'country_code_event.dart';

part 'country_code_state.dart';

class CountryCodeBloc extends Bloc<CountryCodeEvent, CountryCodeState> {
  CountryCodeBloc({required this.countryCodeRepository}) : super(CountryCodeLoading()) {
    _validators = CommonValidator();

    on<CountryCodeStarted>(_onStarted);
    on<CountryCodeSearch>(_onSearch);
  }

  final CountryCodeRepository countryCodeRepository;
  late CommonValidator _validators;

  Future<void> _onStarted(
    CountryCodeStarted event,
    Emitter<CountryCodeState> emit,
  ) async {
    emit(CountryCodeLoading());
    try {
      final countryCode = await countryCodeRepository.loadCountryCode();
      emit(CountryCodeLoaded(countryCode));
    } catch (_) {
      emit(CountryCodeError(S.current.unknown_error, false));
    }
  }

  Future<void> _onSearch(
    CountryCodeSearch event,
    Emitter<CountryCodeState> emit,
  ) async {
    emit(CountryCodeLoading());
    try {
      String? validator = _validators.checkEmptyString(event.name);
      if (validator.isEmpty) {
        final countryCode = await countryCodeRepository.searchCountryName(event.name);
        if (countryCode.isEmpty) {
          emit(CountryCodeEmptySearch(event.searchClick));
        } else {
          emit(CountryCodeLoaded(countryCode));
        }
      } else {
        emit(CountryCodeError(validator, event.searchClick));
      }
    } catch (_) {
      emit(CountryCodeError(S.current.unknown_error, event.searchClick));
    }
  }
}
