import 'package:flutter/material.dart';

// Base on https://m3.material.io/styles/shape/shape-scale-tokens
class BorderRadiusM3 {
  static BorderRadius none = BorderRadius.circular(0);

  static BorderRadius extraSmall = BorderRadius.circular(4);

  static BorderRadius extraSmallTop = const BorderRadius.only(
    bottomLeft: Radius.circular(0),
    bottomRight: Radius.circular(0),
    topLeft: Radius.circular(4),
    topRight: Radius.circular(4),
  );

  static BorderRadius small = BorderRadius.circular(8);

  static BorderRadius medium = BorderRadius.circular(12);

  static BorderRadius large = BorderRadius.circular(16);

  static BorderRadius largeEnd = const BorderRadius.only(
    bottomLeft: Radius.circular(0),
    bottomRight: Radius.circular(16),
    topLeft: Radius.circular(0),
    topRight: Radius.circular(16),
  );

  static BorderRadius largeTop = const BorderRadius.only(
    bottomLeft: Radius.circular(0),
    bottomRight: Radius.circular(0),
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  );

  static BorderRadius extraLarge = BorderRadius.circular(28);

  static BorderRadius extraLargeTop = const BorderRadius.only(
    bottomLeft: Radius.circular(0),
    bottomRight: Radius.circular(0),
    topLeft: Radius.circular(28),
    topRight: Radius.circular(28),
  );

  static BorderRadius full = BorderRadius.circular(30);
}
