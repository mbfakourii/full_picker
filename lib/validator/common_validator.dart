import 'package:ahille/generated/l10n.dart';
import 'package:rules/rules.dart';

class CommonValidator {
  String checkEmptyString(String text) {
    final ruleText = Rule(
      text,
      name: 'text',
      customErrorText: S.current.enter_the_value,
      isRequired: true,
    );

    if (ruleText.hasError) {
      return ruleText.error ?? "";
    } else {
      return "";
    }
  }
}
