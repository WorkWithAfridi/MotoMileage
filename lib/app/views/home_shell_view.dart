import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bike_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/demo_data_service.dart';
import 'dashboard_view.dart';
import 'fuel_logs_view.dart';
import 'maintenance_view.dart';
import 'settings_view.dart';
import 'widgets/bike_form_sheet.dart';
import 'widgets/fuel_entry_form_sheet.dart';
import 'widgets/maintenance_form_sheet.dart';

class HomeShellView extends StatefulWidget {
  const HomeShellView({super.key});

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  int _index = 0;
  final GlobalKey _bikeSelectorKey = GlobalKey();

  static const _tabs = [DashboardView(), FuelLogsView(), MaintenanceView(), SettingsView()];

  Future<void> _showBikeSelectorMenu(
    BuildContext context, {
    required BikeController bikeController,
    required String? activeBikeId,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final anchor = _bikeSelectorKey.currentContext?.findRenderObject() as RenderBox?;
    if (anchor == null) return;

    final topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = anchor.localToGlobal(
      anchor.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final position = RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight).translate(0, 4),
      Offset.zero & overlay.size,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBikeId = await showMenu<String>(
      context: context,
      position: position,
      elevation: isDark ? 6 : 10,
      color: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: BoxConstraints(
        minWidth: anchor.size.width,
        maxWidth: anchor.size.width,
        maxHeight: 340,
      ),
      items: bikeController.bikes
          .map(
            (bike) => PopupMenuItem<String>(
              value: bike.id,
              child: Row(
                children: [
                  Expanded(child: Text('${bike.name} (${bike.model})')),
                  if (bike.id == activeBikeId)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );

    if (selectedBikeId == null) return;
    bikeController.setActiveBike(selectedBikeId);
  }

  @override
  Widget build(BuildContext context) {
    final bikeController = Get.find<BikeController>();
    final settingsController = Get.find<SettingsController>();
    final fuelController = Get.find<FuelController>();
    final maintenanceController = Get.find<MaintenanceController>();
    final demoDataService = Get.find<DemoDataService>();

    return Obx(() {
      final activeBike = bikeController.activeBike;
      final hasBikes = bikeController.bikes.isNotEmpty;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Scaffold(
        appBar: AppBar(
          title: hasBikes
              ? InkWell(
                  key: _bikeSelectorKey,
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showBikeSelectorMenu(
                    context,
                    bikeController: bikeController,
                    activeBikeId: activeBike?.id,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            activeBike == null ? 'Select Bike' : '${activeBike.name} (${activeBike.model})',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.expand_more_rounded, color: colorScheme.primary),
                      ],
                    ),
                  ),
                )
              : const Text('Moto Mileage', style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              tooltip: 'Add Bike',
              onPressed: () =>
                  showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const BikeFormSheet()),
              icon: const Icon(Icons.add_circle_outline),
            ),
            if (activeBike != null)
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                offset: const Offset(0, 4),
                onSelected: (value) async {
                  if (value == 'edit') {
                    await showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) => BikeFormSheet(bike: activeBike),
                    );
                  }

                  if (value == 'delete') {
                    await bikeController.deleteBike(activeBike.id);
                  }
                },
                itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit Bike')), PopupMenuItem(value: 'delete', child: Text('Delete Bike'))],
              ),
          ],
        ),
        body: !hasBikes
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('No bikes added yet.', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first bike or load template data to explore the app quickly.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => showModalBottomSheet<void>(
                                  context: context,
                                  showDragHandle: true,
                                  isScrollControlled: true,
                                  builder: (_) => const BikeFormSheet(),
                                ),
                                child: const Text('Add Your First Bike'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await demoDataService.populateDemoData();
                                  settingsController.reload();
                                  await bikeController.reload();
                                  await fuelController.reloadActiveBike();
                                  await maintenanceController.reloadActiveBike();
                                  if (!context.mounted) return;
                                  Get.snackbar('Demo Loaded', 'Template dataset is ready. Explore the app.');
                                },
                                child: const Text('Load Template'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You can also load/reset data later from Settings.',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: KeyedSubtree(key: ValueKey(_index), child: _tabs[_index]),
              ),
        floatingActionButton: !hasBikes
            ? null
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _buildFabForIndex(context, index: _index),
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.local_gas_station_outlined), selectedIcon: Icon(Icons.local_gas_station), label: 'Fuel'),
            NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Maintenance'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    });
  }

  Widget _buildFabForIndex(BuildContext context, {required int index}) {
    if (index == 1) {
      return FloatingActionButton.extended(
        key: const ValueKey('fuelFab'),
        heroTag: 'fuelFab',
        onPressed: () =>
            showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const FuelEntryFormSheet()),
        icon: const Icon(Icons.local_gas_station_outlined),
        label: const Text('Quick Add'),
      );
    }

    if (index == 2) {
      return FloatingActionButton.extended(
        key: const ValueKey('maintenanceFab'),
        heroTag: 'maintenanceFab',
        onPressed: () =>
            showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const MaintenanceFormSheet()),
        icon: const Icon(Icons.build_circle_outlined),
        label: const Text('Add Maintenance'),
      );
    }

    return const SizedBox.shrink(key: ValueKey('noFab'));
  }
}
