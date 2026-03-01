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

    return Obx(
      () => GetMaterialApp(
        title: 'MotoMileage',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode:
            settingsController.settings.value.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const StartupGateView(),
      ),
    );
  }
}
