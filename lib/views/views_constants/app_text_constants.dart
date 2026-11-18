import 'package:flutter/material.dart';

class AppTextConstants {
  static String fontFamily(BuildContext context) {
    return Localizations.localeOf(context) == const Locale('ar')
        ? 'Tajawal'
        : 'Poppins';
  }

  static TextStyle headingStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily(context),
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  static TextStyle subheadingStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily(context),
    fontSize: 25,
    color: Colors.black54,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily(context),
    fontSize: 18,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  );
}
