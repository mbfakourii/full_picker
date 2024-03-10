// ignore_for_file: avoid_classes_with_only_static_members,prefer_const_constructors,do_not_use_environment,prefer_const_declarations
import 'dart:io';

import 'package:flutter/foundation.dart';

class Pl {
  static final bool isWeb = kIsWeb;

  static final bool isLinux = !isWeb && Platform.isLinux;

  static final bool isMacOS = !isWeb && Platform.isMacOS;

  static final bool isWindows = !isWeb && Platform.isWindows;

  static final bool isAndroid = !isWeb && Platform.isAndroid;

  static final bool isIOS = !isWeb && Platform.isIOS;

  static final bool isFuchsia = !isWeb && Platform.isFuchsia;
}
