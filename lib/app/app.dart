import 'package:flutter/material.dart';
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
      return GetMaterialApp(
        title: 'Moto Mileage',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: theme,
        themeMode: ThemeMode.light,
        home: const StartupGateView(),
      );
    });
  }
}
