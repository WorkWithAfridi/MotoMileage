import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../services/local_storage_service.dart';
import 'home_shell_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Manage Your Bikes',
      description:
          'Add multiple bikes, set distance and fuel units, and switch active bike instantly.',
      icon: Icons.two_wheeler,
      color: Color(0xFF0A7E8C),
    ),
    _OnboardingPageData(
      title: 'Log Fuel In Seconds',
      description:
          'Use quick add to log odometer, quantity, and cost. Mileage and trip stats are calculated automatically.',
      icon: Icons.local_gas_station,
      color: Color(0xFF1B998B),
    ),
    _OnboardingPageData(
      title: 'Dashboard Insights',
      description:
          'View mileage trends, monthly expenses, refill behavior, and fuel split charts at a glance.',
      icon: Icons.query_stats,
      color: Color(0xFF2D6A4F),
    ),
    _OnboardingPageData(
      title: 'Maintenance & Backup',
      description:
          'Track service history, get due reminders, and export or backup your data locally.',
      icon: Icons.build_circle,
      color: Color(0xFF22577A),
    ),
    _OnboardingPageData(
      title: 'Try Demo Data',
      description:
          'From Settings, you can load a demo dataset to explore the app quickly. You can also reset all local data anytime.',
      icon: Icons.dataset_outlined,
      color: Color(0xFFB85C38),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final storage = Get.find<LocalStorageService>();
    await storage.setBool(StorageKeys.onboardingSeen, true);
    if (!mounted) return;
    Get.offAll(() => const HomeShellView());
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _pageIndex = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, size: 70, color: item.color),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade700,
                                height: 1.35,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _pageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (isLastPage) {
                      _finishOnboarding();
                      return;
                    }
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text(isLastPage ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
