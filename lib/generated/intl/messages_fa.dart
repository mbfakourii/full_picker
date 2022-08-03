// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fa locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fa';

  static String m0(date, time) => "تاریخ: ${date} زمان: ${time}";

  static String m1(name) => "خوش آمدی ${name}";

  static String m2(firstName, lastName) =>
      "اسم من هست ${lastName}, ${firstName} ${lastName}";

  static String m3(howMany) =>
      "{howMany, plural, one{You have 1 message} دیگر{You have ${howMany} پیام ها}}";

  static String m4(total) => "جمع: ${total}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "pageHomeListTitle":
            MessageLookupByLibrary.simpleMessage("برخی از رشته های محلی:"),
        "pageHomeSampleCurrentDateTime": m0,
        "pageHomeSamplePlaceholder": m1,
        "pageHomeSamplePlaceholdersOrdered": m2,
        "pageHomeSamplePlural": m3,
        "pageHomeSampleTotalAmount": m4
      };
}
