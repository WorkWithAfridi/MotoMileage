import 'package:flutter/material.dart';

import '../localization/localized_text.dart';
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
      kicker: 'Get Started Fast',
      title: 'Manage Your Bikes',
      description:
          'Add your bikes with custom units and switch between them instantly from the top bar.',
      icon: Icons.two_wheeler,
      color: Color(0xFF0A7E8C),
      highlights: [
        'Multi-bike support',
        'Per-bike distance & fuel unit',
        'Instant active bike switching',
      ],
    ),
    _OnboardingPageData(
      kicker: 'Daily Logging',
      title: 'Log Fuel In Seconds',
      description:
          'Use quick add for odometer, quantity, and cost. Mileage metrics are auto-calculated on every refill.',
      icon: Icons.local_gas_station,
      color: Color(0xFF1B998B),
      highlights: [
        'Quick Add form',
        'Station suggestions from history',
        'Auto trip, mileage, and cost-per-distance',
      ],
    ),
    _OnboardingPageData(
      kicker: 'Insightful Dashboard',
      title: 'Dashboard Insights',
      description:
          'Track fuel economy, spending, refill behavior, and trends with summary cards and charts.',
      icon: Icons.query_stats,
      color: Color(0xFF2D6A4F),
      highlights: [
        'Mileage and expense trends',
        'Fuel type cost split',
        'Tip of the Day and quick insights',
      ],
    ),
    _OnboardingPageData(
      kicker: 'Station Intelligence',
      title: 'Fuel Station Report',
      description:
          'Compare stations by total spend, fuel volume, refill count, and average mileage performance.',
      icon: Icons.local_gas_station_outlined,
      color: Color(0xFF0F6C7B),
      highlights: [
        'Top stations by spend',
        'Avg price per unit',
        'Most used and best mileage station',
      ],
    ),
    _OnboardingPageData(
      kicker: 'Bike Care',
      title: 'Maintenance & Backup',
      description:
          'Log service entries, get due reminders, export CSV, and create local JSON backups.',
      icon: Icons.build_circle,
      color: Color(0xFF22577A),
      highlights: [
        'Maintenance reminders',
        'CSV export and JSON backup',
        'Offline restore anytime',
      ],
    ),
    _OnboardingPageData(
      kicker: 'Explore Confidently',
      title: 'Try Demo Data',
      description:
          'Load a rich demo dataset from Settings to explore features quickly. Reset data whenever needed.',
      icon: Icons.dataset_outlined,
      color: Color(0xFFB85C38),
      highlights: [
        'Bangladesh-based sample dataset',
        'Great for first-time walkthrough',
        'One-tap reset from Settings',
      ],
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
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.arrow_forward_rounded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const TrText('Skip'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _pageIndex = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: TrText(
                              item.kicker.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: item.color,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                          TrText(
                            item.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 14),
                          TrText(
                            item.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.35),
                          ),
                          const SizedBox(height: 18),
                          ...item.highlights.map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: item.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TrText(
                                      point,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.kicker,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.highlights,
  });

  final String kicker;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> highlights;
}
