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

  static const _tabs = [DashboardView(), FuelLogsView(), MaintenanceView(), SettingsView()];

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

      return Scaffold(
        appBar: AppBar(
          title: hasBikes
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeBike?.id,
                    hint: const Text('Select Bike'),
                    items: bikeController.bikes.map((bike) => DropdownMenuItem(value: bike.id, child: Text('${bike.name} (${bike.model})'))).toList(),
                    onChanged: bikeController.setActiveBike,
                  ),
                )
              : const Text('Moto Mileage'),
          actions: [
            IconButton(
              tooltip: 'Add Bike',
              onPressed: () =>
                  showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const BikeFormSheet()),
              icon: const Icon(Icons.add_circle_outline),
            ),
            if (activeBike != null)
              PopupMenuButton<String>(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No bikes added yet.'),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: Get.width * 0.8,
                      child: FilledButton(
                        onPressed: () =>
                            showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const BikeFormSheet()),
                        child: const Text('Add Your First Bike'),
                      ),
                    ),
                    SizedBox(height: 6),
                    SizedBox(
                      width: Get.width * 0.8,
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
                    Text('You can also load/reset data later from Settings.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  ],
                ),
              )
            : _tabs[_index],
        floatingActionButton: !hasBikes
            ? null
            : _index == 1
            ? FloatingActionButton.extended(
                onPressed: () =>
                    showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const FuelEntryFormSheet()),
                icon: const Icon(Icons.local_gas_station_outlined),
                label: const Text('Quick Add'),
              )
            : _index == 2
            ? FloatingActionButton.extended(
                onPressed: () =>
                    showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => const MaintenanceFormSheet()),
                icon: const Icon(Icons.build_circle_outlined),
                label: const Text('Add Maintenance'),
              )
            : null,
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
}
