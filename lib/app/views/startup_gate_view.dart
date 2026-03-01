import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../services/local_storage_service.dart';
import 'home_shell_view.dart';
import 'onboarding_view.dart';
import 'splash_view.dart';

class StartupGateView extends StatefulWidget {
  const StartupGateView({super.key});

  @override
  State<StartupGateView> createState() => _StartupGateViewState();
}

class _StartupGateViewState extends State<StartupGateView> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final storage = Get.find<LocalStorageService>();
    final seen = storage.getBool(StorageKeys.onboardingSeen) ?? false;

    if (!mounted) return;

    if (seen) {
      Get.offAll(() => const HomeShellView());
      return;
    }

    Get.offAll(() => const OnboardingView());
  }

  @override
  Widget build(BuildContext context) {
    return const SplashView();
  }
}
