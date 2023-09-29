import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor Dark = const MaterialColor(
    0xffef4444, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xfffef2f2), //10%
      100: const Color(0xfffee2e2), //20%
      200: const Color(0xfffca5a5), //30%
      300: const Color(0xfffca5a5), //40%
      400: const Color(0xfff87171), //50%
      500: const Color(0xffef4444), //60%
      600: const Color(0xffdc2626), //70%
      700: const Color(0xffb91c1c), //80%
      800: const Color(0xff991b1b), //90%
      900: const Color(0xff000000), //100%
    },
  );
}
