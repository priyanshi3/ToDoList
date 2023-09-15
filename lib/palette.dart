import 'package:flutter/material.dart';
class Palette {
  static const MaterialColor Dark = const MaterialColor(
    0xff64ffda, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xff5ae6c4),//10%
      100: const Color(0xff50ccae),//20%
      200: const Color(0xff46b399),//30%
      300: const Color(0xff3c9983),//40%
      400: const Color(0xff32806d),//50%
      500: const Color(0xff286657),//60%
      600: const Color(0xff1e4c41),//70%
      700: const Color(0xff14332c),//80%
      800: const Color(0xff0a1916),//90%
      900: const Color(0xff000000),//100%
    },
  );
}