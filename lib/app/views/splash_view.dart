import 'package:flutter/material.dart';

import '../utils/app_assets.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: Image.asset(AppAssets.playstoreIcon, width: 76, height: 76, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Moto Mileage',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 32, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Track fuel. Ride smarter.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75), fontSize: 14)),
            const SizedBox(height: 28),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
