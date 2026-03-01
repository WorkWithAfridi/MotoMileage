import '../constants.dart';

class FuelLogEntry {
  FuelLogEntry({
    required this.id,
    required this.bikeId,
    required this.odometer,
    required this.fuelQuantity,
    required this.totalCost,
    required this.date,
    this.fuelType,
    this.stationName,
    this.notes,
    this.tripDistance,
    this.mileage,
    this.pricePerUnit,
    this.costPerDistance,
  });

  final String id;
  final String bikeId;
  final double odometer;
  final double fuelQuantity;
  final double totalCost;
  final DateTime date;
  final FuelType? fuelType;
  final String? stationName;
  final String? notes;
  final double? tripDistance;
  final double? mileage;
  final double? pricePerUnit;
  final double? costPerDistance;

  FuelLogEntry copyWith({
    String? id,
    String? bikeId,
    double? odometer,
    double? fuelQuantity,
    double? totalCost,
    DateTime? date,
    FuelType? fuelType,
    bool clearFuelType = false,
    String? stationName,
    bool clearStationName = false,
    String? notes,
    bool clearNotes = false,
    double? tripDistance,
    bool clearTripDistance = false,
    double? mileage,
    bool clearMileage = false,
    double? pricePerUnit,
    bool clearPricePerUnit = false,
    double? costPerDistance,
    bool clearCostPerDistance = false,
  }) {
    return FuelLogEntry(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      odometer: odometer ?? this.odometer,
      fuelQuantity: fuelQuantity ?? this.fuelQuantity,
      totalCost: totalCost ?? this.totalCost,
      date: date ?? this.date,
      fuelType: clearFuelType ? null : fuelType ?? this.fuelType,
      stationName: clearStationName ? null : stationName ?? this.stationName,
      notes: clearNotes ? null : notes ?? this.notes,
      tripDistance: clearTripDistance ? null : tripDistance ?? this.tripDistance,
      mileage: clearMileage ? null : mileage ?? this.mileage,
      pricePerUnit: clearPricePerUnit ? null : pricePerUnit ?? this.pricePerUnit,
      costPerDistance: clearCostPerDistance ? null : costPerDistance ?? this.costPerDistance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bikeId': bikeId,
      'odometer': odometer,
      'fuelQuantity': fuelQuantity,
      'totalCost': totalCost,
      'date': date.toIso8601String(),
      'fuelType': fuelType?.name,
      'stationName': stationName,
      'notes': notes,
      'tripDistance': tripDistance,
      'mileage': mileage,
      'pricePerUnit': pricePerUnit,
      'costPerDistance': costPerDistance,
    };
  }

  factory FuelLogEntry.fromMap(Map<String, dynamic> map) {
    return FuelLogEntry(
      id: map['id'] as String,
      bikeId: map['bikeId'] as String,
      odometer: (map['odometer'] as num).toDouble(),
      fuelQuantity: (map['fuelQuantity'] as num).toDouble(),
      totalCost: (map['totalCost'] as num).toDouble(),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      fuelType: map['fuelType'] == null
          ? null
          : FuelType.values.firstWhere(
              (value) => value.name == map['fuelType'],
              orElse: () => FuelType.custom,
            ),
      stationName: map['stationName'] as String?,
      notes: map['notes'] as String?,
      tripDistance: (map['tripDistance'] as num?)?.toDouble(),
      mileage: (map['mileage'] as num?)?.toDouble(),
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble(),
      costPerDistance: (map['costPerDistance'] as num?)?.toDouble(),
    );
  }
}
