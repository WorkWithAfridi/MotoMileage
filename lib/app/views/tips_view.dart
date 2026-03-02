import 'package:flutter/material.dart';

import '../data/app_tips_database.dart';

class TipsView extends StatefulWidget {
  const TipsView({super.key});

  @override
  State<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends State<TipsView> {
  bool _showFuel = true;

  @override
  Widget build(BuildContext context) {
    final tips = _showFuel ? AppTipsDatabase.fuelTips : AppTipsDatabase.maintenanceTips;
    final label = _showFuel ? 'Fuel Tips' : 'Maintenance Tips';

    return Scaffold(
      appBar: AppBar(title: const Text('Tips Library')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Local knowledge base with practical riding and upkeep guidance.', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(value: true, icon: Icon(Icons.local_gas_station_outlined), label: Text('Fuel DB')),
                      ButtonSegment<bool>(value: false, icon: Icon(Icons.build_outlined), label: Text('Maintenance DB')),
                    ],
                    selected: {_showFuel},
                    onSelectionChanged: (selected) {
                      setState(() => _showFuel = selected.first);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('$label (${tips.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tips.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tip = tips[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. ${tip.title}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(tip.description, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
