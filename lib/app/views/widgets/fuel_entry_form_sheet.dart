import 'package:flutter/material.dart';

import '../../localization/localized_text.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/bike_controller.dart';
import '../../controllers/fuel_controller.dart';
import '../../controllers/settings_controller.dart';
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
  final FocusNode _stationFocusNode = FocusNode();
  bool _showOptional = false;
  FuelType? _fuelType;
  DateTime _date = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _odometerController = TextEditingController(
      text: widget.entry?.odometer.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.entry?.fuelQuantity.toString() ?? '',
    );
    _costController = TextEditingController(
      text: widget.entry?.totalCost.toString() ?? '',
    );
    _stationController = TextEditingController(
      text: widget.entry?.stationName ?? '',
    );
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
    _stationFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final bikeController = Get.find<BikeController>();
    final settingsController = Get.find<SettingsController>();
    final activeBike = bikeController.activeBike;
    final distanceUnit = _distanceUnitLabel(activeBike?.distanceUnit);
    final fuelUnit = _fuelUnitLabel(activeBike?.fuelUnit);
    final currency = settingsController.settings.value.currencySymbol
        .toUpperCase();
    final stationHistory = _stationHistory(fuelController.entries);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  widget.entry == null ? 'Quick Add Fuel' : 'Edit Fuel Entry',
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
                          'Core Details',
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
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Fuel Quantity'.tx,
                            suffixText: fuelUnit,
                          ),
                          validator: (value) =>
                              (double.tryParse(value ?? '') == null)
                              ? 'Invalid'.tx
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _costController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Total Cost'.tx,
                            suffixText: currency,
                          ),
                          validator: (value) =>
                              (double.tryParse(value ?? '') == null)
                              ? 'Invalid'.tx
                              : null,
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
                        Row(
                          children: [
                            Expanded(
                              child: TrText(
                                'Optional Details',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => setState(
                                () => _showOptional = !_showOptional,
                              ),
                              icon: Icon(
                                _showOptional
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              label: TrText(
                                _showOptional
                                    ? 'Hide Optional'
                                    : 'Show Optional',
                              ),
                            ),
                          ],
                        ),
                        if (_showOptional) ...[
                          const SizedBox(height: 12),
                          AppDropdownFormField<FuelType?>(
                            initialValue: _fuelType,
                            decoration: InputDecoration(
                              labelText: 'Fuel Type'.tx,
                            ),
                            items: [
                              const DropdownMenuItem<FuelType?>(
                                value: null,
                                child: TrText('None'),
                              ),
                              ...FuelType.values.map(
                                (type) => DropdownMenuItem<FuelType?>(
                                  value: type,
                                  child: TrText(type.name.toUpperCase()),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _fuelType = value),
                          ),
                          const SizedBox(height: 18),
                          RawAutocomplete<String>(
                            textEditingController: _stationController,
                            focusNode: _stationFocusNode,
                            optionsBuilder: (textEditingValue) {
                              final query = textEditingValue.text
                                  .trim()
                                  .toLowerCase();
                              if (query.isEmpty) {
                                return stationHistory.take(6);
                              }

                              final startsWith = stationHistory.where(
                                (item) => item.toLowerCase().startsWith(query),
                              );
                              final contains = stationHistory.where(
                                (item) =>
                                    !item.toLowerCase().startsWith(query) &&
                                    item.toLowerCase().contains(query),
                              );
                              return [...startsWith, ...contains].take(6);
                            },
                            onSelected: (selection) =>
                                _stationController.text = selection,
                            fieldViewBuilder:
                                (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Station Name'.tx,
                                      prefixIcon: const Icon(Icons.search),
                                      helperText: stationHistory.isEmpty
                                          ? null
                                          : 'Suggestions from past entries',
                                    ),
                                  );
                                },
                            optionsViewBuilder: (context, onSelected, options) {
                              if (options.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 220,
                                      minWidth: 240,
                                    ),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.local_gas_station_outlined,
                                            size: 18,
                                          ),
                                          title: TrText(option),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _notesController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: InputDecoration(labelText: 'Notes'.tx),
                          ),
                        ] else
                          TrText(
                            'Tap "Show Optional" to add fuel type, station, and notes.',
                            style: Theme.of(context).textTheme.bodySmall,
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

                              final odometer = double.parse(
                                _odometerController.text.trim(),
                              );
                              final quantity = double.parse(
                                _quantityController.text.trim(),
                              );
                              final cost = double.parse(
                                _costController.text.trim(),
                              );

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
                            child: TrText(
                              widget.entry == null
                                  ? 'Save Entry'
                                  : 'Update Entry',
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

  String _fuelUnitLabel(FuelUnit? unit) {
    return unit == FuelUnit.gallons ? 'GALLONS' : 'LITERS';
  }

  List<String> _stationHistory(List<FuelLogEntry> entries) {
    final frequency = <String, int>{};
    for (final entry in entries) {
      final station = entry.stationName?.trim() ?? '';
      if (station.isEmpty) {
        continue;
      }
      frequency[station] = (frequency[station] ?? 0) + 1;
    }

    final names = frequency.keys.toList();
    names.sort((a, b) {
      final byFrequency = (frequency[b] ?? 0).compareTo(frequency[a] ?? 0);
      if (byFrequency != 0) {
        return byFrequency;
      }
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return names;
  }
}
