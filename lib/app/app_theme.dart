import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  final Color _color = Colors.red;

  ThemeData get light => _themeBuilder(Brightness.light);

  ThemeData get dark => _themeBuilder(Brightness.dark);

  ThemeData _themeBuilder(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        brightness: brightness,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardTheme: const CardTheme(
        margin: EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: systemOverlayStyle(brightness),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
    );
  }

  SystemUiOverlayStyle systemOverlayStyle(Brightness brightness) {
    final theme = ColorScheme.fromSeed(
      seedColor: _color,
      brightness: brightness,
    );

    final systemIconBrightness = switch (brightness) {
      Brightness.dark => Brightness.light,
      Brightness.light => Brightness.dark,
    };

    return SystemUiOverlayStyle(
      statusBarIconBrightness: systemIconBrightness,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: systemIconBrightness,
      systemNavigationBarColor: theme.surface,
    );
  }

  static ScrollBehavior get scrollBehavior {
    return const MaterialScrollBehavior().copyWith(
      physics: const BouncingScrollPhysics(),
      dragDevices: PointerDeviceKind.values.toSet(),
    );
  }
}
