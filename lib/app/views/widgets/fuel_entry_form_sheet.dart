import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/fuel_controller.dart';
import '../../models/fuel_log_entry.dart';
import 'app_dropdown_form_field.dart';

class FuelEntryFormSheet extends StatefulWidget {
  const FuelEntryFormSheet({super.key, this.entry});

  final FuelLogEntry? entry;

  @override
  State<FuelEntryFormSheet> createState() => _FuelEntryFormSheetState();
}

class _FuelEntryFormSheetState extends State<FuelEntryFormSheet> {
  late final TextEditingController _odometerController;
  late final TextEditingController _quantityController;
  late final TextEditingController _costController;
  late final TextEditingController _stationController;
  late final TextEditingController _notesController;
  bool _showOptional = false;
  FuelType? _fuelType;
  DateTime _date = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _odometerController = TextEditingController(text: widget.entry?.odometer.toString() ?? '');
    _quantityController = TextEditingController(text: widget.entry?.fuelQuantity.toString() ?? '');
    _costController = TextEditingController(text: widget.entry?.totalCost.toString() ?? '');
    _stationController = TextEditingController(text: widget.entry?.stationName ?? '');
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');

    _fuelType = widget.entry?.fuelType;
    _showOptional = widget.entry != null;
    _date = widget.entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.entry == null ? 'Quick Add Fuel' : 'Edit Fuel Entry', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 22),
              TextFormField(
                controller: _odometerController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Odometer'),
                validator: (value) => (double.tryParse(value ?? '') == null) ? 'Invalid' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Fuel Quantity'),
                validator: (value) => (double.tryParse(value ?? '') == null) ? 'Invalid' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Total Cost'),
                validator: (value) => (double.tryParse(value ?? '') == null) ? 'Invalid' : null,
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showOptional = !_showOptional),
                icon: Icon(_showOptional ? Icons.expand_less : Icons.expand_more),
                label: Text(_showOptional ? 'Hide Optional' : 'Show Optional'),
              ),
              if (_showOptional) ...[
                const SizedBox(height: 18),
                AppDropdownFormField<FuelType?>(
                  initialValue: _fuelType,
                  decoration: const InputDecoration(labelText: 'Fuel Type'),
                  items: [
                    const DropdownMenuItem<FuelType?>(value: null, child: Text('None')),
                    ...FuelType.values.map((type) => DropdownMenuItem<FuelType?>(value: type, child: Text(type.name))),
                  ],
                  onChanged: (value) => setState(() => _fuelType = value),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _stationController,
                  decoration: const InputDecoration(labelText: 'Station Name'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text('Date:'),
                    const SizedBox(width: 8),
                    Text(MaterialLocalizations.of(context).formatMediumDate(_date)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) {
                          setState(() => _date = picked);
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final odometer = double.parse(_odometerController.text.trim());
                    final quantity = double.parse(_quantityController.text.trim());
                    final cost = double.parse(_costController.text.trim());

                    if (widget.entry == null) {
                      await fuelController.addEntry(
                        odometer: odometer,
                        fuelQuantity: quantity,
                        totalCost: cost,
                        date: _date,
                        fuelType: _fuelType,
                        stationName: _stationController.text,
                        notes: _notesController.text,
                      );
                    } else {
                      await fuelController.updateEntry(
                        id: widget.entry!.id,
                        odometer: odometer,
                        fuelQuantity: quantity,
                        totalCost: cost,
                        date: _date,
                        fuelType: _fuelType,
                        stationName: _stationController.text,
                        notes: _notesController.text,
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Text(widget.entry == null ? 'Save Entry' : 'Update Entry'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
