import 'package:flutter/material.dart';

import '../../localization/localized_text.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/bike_controller.dart';
import '../../controllers/maintenance_controller.dart';
import '../../models/maintenance_entry.dart';
import 'app_dropdown_form_field.dart';

class MaintenanceFormSheet extends StatefulWidget {
  const MaintenanceFormSheet({super.key, this.entry});

  final MaintenanceEntry? entry;

  @override
  State<MaintenanceFormSheet> createState() => _MaintenanceFormSheetState();
}

class _MaintenanceFormSheetState extends State<MaintenanceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _odometerController;
  late final TextEditingController _notesController;
  late final TextEditingController _nextDueController;
  late final TextEditingController _customTypeController;

  MaintenanceType _type = MaintenanceType.oilChange;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _odometerController = TextEditingController(
      text: entry?.odometer.toString() ?? '',
    );
    _notesController = TextEditingController(text: entry?.notes ?? '');
    _nextDueController = TextEditingController(
      text: entry?.nextDueOdometer?.toString() ?? '',
    );
    _customTypeController = TextEditingController(
      text: entry?.customType ?? '',
    );
    _type = entry?.type ?? MaintenanceType.oilChange;
    _date = entry?.date ?? DateTime.now();
  }

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
                TrText(
                  widget.entry == null ? 'Add Maintenance' : 'Edit Maintenance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TrText(
                          'Service Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<MaintenanceType>(
                          initialValue: _type,
                          decoration: InputDecoration(labelText: 'Type'.tx),
                          items: MaintenanceType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: TrText(type.label),
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
                            decoration: InputDecoration(
                              labelText: 'Custom Type'.tx,
                            ),
                            validator: (value) {
                              if (_type != MaintenanceType.custom) {
                                return null;
                              }
                              return value == null || value.trim().isEmpty
                                  ? 'Required'.tx
                                  : null;
                            },
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
                        TrText(
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
                            labelText: 'Odometer'.tx,
                            suffixText: distanceUnit,
                          ),
                          validator: (value) =>
                              (double.tryParse(value ?? '') == null)
                              ? 'Invalid'.tx
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nextDueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Next Due Odometer'.tx,
                            suffixText: distanceUnit,
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return null;
                            }
                            return double.tryParse(text) == null
                                ? 'Invalid'.tx
                                : null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _notesController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(labelText: 'Notes'.tx),
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
                        TrText(
                          'Date & Actions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const TrText('Date:'),
                            const SizedBox(width: 8),
                            TrText(
                              MaterialLocalizations.of(
                                context,
                              ).formatMediumDate(_date),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() => _date = picked);
                                }
                              },
                              child: const TrText('Pick Date'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              final customType = _type == MaintenanceType.custom
                                  ? _customTypeController.text.trim()
                                  : null;
                              final odometer = double.parse(
                                _odometerController.text.trim(),
                              );
                              final notes = _notesController.text.trim();
                              final nextDueText = _nextDueController.text
                                  .trim();
                              final nextDueOdometer = nextDueText.isEmpty
                                  ? null
                                  : double.parse(nextDueText);

                              if (widget.entry == null) {
                                await controller.addEntry(
                                  type: _type,
                                  customType: customType,
                                  odometer: odometer,
                                  date: _date,
                                  notes: notes,
                                  nextDueOdometer: nextDueOdometer,
                                );
                              } else {
                                await controller.updateEntry(
                                  id: widget.entry!.id,
                                  type: _type,
                                  customType: customType,
                                  odometer: odometer,
                                  date: _date,
                                  notes: notes,
                                  nextDueOdometer: nextDueOdometer,
                                );
                              }

                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            child: TrText(
                              widget.entry == null
                                  ? 'Save Maintenance'
                                  : 'Update Maintenance',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const TrText('Close'),
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
