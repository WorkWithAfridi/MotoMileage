import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/bike_controller.dart';
import '../../controllers/maintenance_controller.dart';
import 'app_dropdown_form_field.dart';

class MaintenanceFormSheet extends StatefulWidget {
  const MaintenanceFormSheet({super.key});

  @override
  State<MaintenanceFormSheet> createState() => _MaintenanceFormSheetState();
}

class _MaintenanceFormSheetState extends State<MaintenanceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nextDueController = TextEditingController();
  final TextEditingController _customTypeController = TextEditingController();

  MaintenanceType _type = MaintenanceType.oilChange;

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    _nextDueController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MaintenanceController>();
    final bikeController = Get.find<BikeController>();
    final distanceUnit = _distanceUnitLabel(
      bikeController.activeBike?.distanceUnit,
    );

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Maintenance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<MaintenanceType>(
                          initialValue: _type,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: MaintenanceType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _type = value);
                          },
                        ),
                        if (_type == MaintenanceType.custom) ...[
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _customTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Type',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule & Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _odometerController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Odometer',
                            suffixText: distanceUnit,
                          ),
                          validator: (value) =>
                              (double.tryParse(value ?? '') == null)
                              ? 'Invalid'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nextDueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Next Due Odometer',
                            suffixText: distanceUnit,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _notesController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              await controller.addEntry(
                                type: _type,
                                customType: _type == MaintenanceType.custom
                                    ? _customTypeController.text.trim()
                                    : null,
                                odometer: double.parse(
                                  _odometerController.text.trim(),
                                ),
                                notes: _notesController.text.trim(),
                                nextDueOdometer:
                                    _nextDueController.text.trim().isEmpty
                                    ? null
                                    : double.parse(
                                        _nextDueController.text.trim(),
                                      ),
                              );

                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save Maintenance'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _distanceUnitLabel(DistanceUnit? unit) {
    return unit == DistanceUnit.miles ? 'MILES' : 'KM';
  }
}
