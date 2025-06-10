import 'package:flutter/material.dart';

enum ThemeType {
  light,
  dark,
}

class AppTheme {
  static ThemeType defaultTheme = ThemeType.light;

  //Theme Colors
  bool isDark;
  Color txt;
  Color primary;
  Color secondary;
  Color accentTxt;
  Color bg1;
  Color surface;
  Color error;
  Color main;
  Color darkText;
  Color lightText;
  Color icon;
  Color clickableText;
  Color boxBg;
  Color mainBg;
  Color white;
  Color linerGradiant;
  Color indicator;
  Color mainLight;
  Color dash;
  Color divider;
  Color trans;
  Color black;
  Color yellow;
  Color sameWhite;
  Color sameBlack;
  Color darkRound;
  Color dotted;
  Color distance;
  Color border;
  Color themeGradient;
  Color price;
  Color toggleSwitch;
  Color trackActive;

  /// Default constructor
  AppTheme({
    required this.isDark,
    required this.txt,
    required this.primary,
    required this.secondary,
    required this.accentTxt,
    required this.bg1,
    required this.surface,
    required this.error,
    required this.main,
    required this.darkText,
    required this.lightText,
    required this.icon,
    required this.clickableText,
    required this.boxBg,
    required this.mainBg,
    required this.white,
    required this.linerGradiant,
    required this.indicator,
    required this.mainLight,
    required this.dash,
    required this.divider,
    required this.black,
    required this.trans,
    required this.yellow,
    required this.sameWhite,
    required this.sameBlack,
    required this.darkRound,
    required this.dotted,
    required this.distance,
    required this.border,
    required this.themeGradient,
    required this.price,
    required this.toggleSwitch,
    required this.trackActive,
  });

  /// fromType factory constructor
  factory AppTheme.fromType(ThemeType t) {
    switch (t) {
      case ThemeType.light:
        return AppTheme(
          isDark: false,
          txt: const Color(0xFF001928),
          primary: const Color(0xffac1e57),
          secondary: const Color(0xFF6EBAE7),
          accentTxt: const Color(0xFF001928),
          bg1: Colors.white,
          surface: Colors.white,
          error: const Color(0xFFd32f2f),
          icon: const Color(0xff3E9B0E),
          main: const Color(0xffac1e57),
          darkText: const Color(0xff414449),
          lightText: const Color(0xff8D8F91),
          clickableText: const Color(0xff4D66FF),
          mainBg: const Color(0x00fff0e3),
          boxBg: const Color(0xffF5F5F5),
          white: Colors.white,
          linerGradiant: const Color(0xff848485),
          indicator: const Color(0xffDFDFDF),
          mainLight: const Color(0xffFFF0E3),
          dash: const Color(0xffD6D6D6),
          divider: const Color(0xffEBEBEB),
          trans: Colors.transparent,
          black: Colors.black,
          yellow: const Color(0xffFFB931),
          sameWhite: Colors.white,
          sameBlack: Colors.black,
          darkRound: const Color(0xff414449),
          dotted: const Color(0xffEBEBEB),
          distance: const Color(0xff414449),
          border: const Color(0xff414449).withOpacity(0.5),
          themeGradient: const Color(0xffFFD3B0),
          price: const Color(0xff414449),
          toggleSwitch: const Color(0xffF5F5F5),
          trackActive: const Color(0xffFFF0E3)
        );

      case ThemeType.dark:
        return AppTheme(
          isDark: true,
          txt: Colors.white,
          primary: const Color(0xffac1e57),
          secondary: const Color(0xFF6EBAE7),
          accentTxt: const Color(0xFF001928),
          bg1: const Color(0xFF151A1E),
          surface: const Color(0xFF151A1E),
          error: const Color(0xFFd32f2f),
          icon: const Color(0xff3E9B0E),
          main: const Color(0xffac1e57),
          darkText: const Color(0xffF5F5F5),
          lightText: const Color(0xff8D8F91),
          clickableText: const Color(0xff4D66FF),
          mainBg: const Color(0x00fff0e3),
          boxBg: const Color(0xff3C3C3C),
          white: const Color(0xff2A2A2A),
          linerGradiant: const Color(0xff848485),
          indicator: const Color(0xffDFDFDF),
          mainLight: const Color(0xffFFF0E3),
          dash: const Color(0xffD6D6D6),
          divider: const Color(0xffEBEBEB),
          trans: Colors.transparent,
          black: Colors.white,
          yellow: const Color(0xffFFB931),
          sameWhite: Colors.white,
          sameBlack: Colors.black,
          darkRound: const Color(0xff414449),
          dotted: const Color(0xff414449),
          distance: const Color(0xff8D8F91),
          border: const Color(0xff414449).withOpacity(0.5),
          themeGradient: const Color(0xffFFD3B0),
          price: const Color(0xffac1e57),
          toggleSwitch: const Color(0xff2A2A2A),
          trackActive: const Color(0xff4E3B2B)
        );
    }
  }

  ThemeData get themeData {
    var t = ThemeData.from(
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        secondary: secondary,
        background: bg1,
        surface: surface,
        onBackground: txt,
        onSurface: txt,
        onError: txt,
        onPrimary: accentTxt,
        onSecondary: accentTxt,
        error: error,
      ),
    );
    return t.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.transparent, cursorColor: primary),
      buttonTheme: ButtonThemeData(buttonColor: primary),
      highlightColor: primary,
    );
  }
}
