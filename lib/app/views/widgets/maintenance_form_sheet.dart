import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/maintenance_controller.dart';

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

    return Padding(
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
              const SizedBox(height: 12),
              DropdownButtonFormField<MaintenanceType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: MaintenanceType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _type = value);
                },
              ),
              if (_type == MaintenanceType.custom) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customTypeController,
                  decoration: const InputDecoration(labelText: 'Custom Type'),
                ),
              ],
              const SizedBox(height: 8),
              TextFormField(
                controller: _odometerController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Odometer'),
                validator: (value) =>
                    (double.tryParse(value ?? '') == null) ? 'Invalid' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nextDueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Next Due Odometer'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
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
                      odometer: double.parse(_odometerController.text.trim()),
                      notes: _notesController.text.trim(),
                      nextDueOdometer: _nextDueController.text.trim().isEmpty
                          ? null
                          : double.parse(_nextDueController.text.trim()),
                    );

                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Maintenance'),
                ),
              ),
              const SizedBox(height: 8),
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
    );
  }
}
