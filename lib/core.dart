import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';

export 'core/theme/app_colors.dart';
export 'core/widgets/glass_container.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
