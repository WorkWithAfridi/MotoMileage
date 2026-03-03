import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/bike_controller.dart';
import '../../models/bike.dart';
import 'app_dropdown_form_field.dart';

class BikeFormSheet extends StatefulWidget {
  const BikeFormSheet({super.key, this.bike});

  final Bike? bike;

  @override
  State<BikeFormSheet> createState() => _BikeFormSheetState();
}

class _BikeFormSheetState extends State<BikeFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;

  DistanceUnit _distanceUnit = DistanceUnit.km;
  FuelUnit _fuelUnit = FuelUnit.liters;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bike?.name ?? '');
    _manufacturerController = TextEditingController(text: widget.bike?.manufacturer ?? '');
    _modelController = TextEditingController(text: widget.bike?.model ?? '');
    _yearController = TextEditingController(text: widget.bike?.year?.toString() ?? '');

    _distanceUnit = widget.bike?.distanceUnit ?? DistanceUnit.km;
    _fuelUnit = widget.bike?.fuelUnit ?? FuelUnit.liters;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bikeController = Get.find<BikeController>();

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
                  widget.bike == null ? 'Add Bike' : 'Edit Bike',
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
                          'Bike Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Bike Name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _manufacturerController,
                          decoration: const InputDecoration(
                            labelText: 'Manufacturer',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(labelText: 'Model'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Year (optional)',
                          ),
                        ),
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
                          'Unit Preferences',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppDropdownFormField<DistanceUnit>(
                                initialValue: _distanceUnit,
                                decoration: const InputDecoration(
                                  labelText: 'Distance',
                                ),
                                items: DistanceUnit.values
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit.name.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _distanceUnit = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppDropdownFormField<FuelUnit>(
                                initialValue: _fuelUnit,
                                decoration: const InputDecoration(
                                  labelText: 'Fuel',
                                ),
                                items: FuelUnit.values
                                    .map(
                                      (unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit.name.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _fuelUnit = value);
                                },
                              ),
                            ),
                          ],
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

                              final year = int.tryParse(
                                _yearController.text.trim(),
                              );

                              if (widget.bike == null) {
                                await bikeController.addBike(
                                  name: _nameController.text.trim(),
                                  manufacturer: _manufacturerController.text
                                      .trim(),
                                  model: _modelController.text.trim(),
                                  year: year,
                                  distanceUnit: _distanceUnit,
                                  fuelUnit: _fuelUnit,
                                );
                              } else {
                                await bikeController.updateBike(
                                  widget.bike!.copyWith(
                                    name: _nameController.text.trim(),
                                    manufacturer: _manufacturerController.text
                                        .trim(),
                                    model: _modelController.text.trim(),
                                    year: year,
                                    clearYear: year == null,
                                    distanceUnit: _distanceUnit,
                                    fuelUnit: _fuelUnit,
                                  ),
                                );
                              }

                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              widget.bike == null
                                  ? 'Save Bike'
                                  : 'Update Bike',
                            ),
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
}
