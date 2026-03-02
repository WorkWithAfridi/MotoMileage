import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controllers/settings_controller.dart';
import 'theme/app_theme.dart';
import 'views/startup_gate_view.dart';

class MotoMileageApp extends StatelessWidget {
  const MotoMileageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final theme = AppTheme.fromPreset(settingsController.settings.value.themePreset);
      final isDark = theme.brightness == Brightness.dark;
      final overlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );
      return GetMaterialApp(
        title: 'Moto Mileage',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: theme,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const StartupGateView(),
      );
    });
  }
}
