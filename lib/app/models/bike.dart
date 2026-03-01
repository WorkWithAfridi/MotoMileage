import '../constants.dart';

class Bike {
  Bike({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.model,
    this.year,
    required this.distanceUnit,
    required this.fuelUnit,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String manufacturer;
  final String model;
  final int? year;
  final DistanceUnit distanceUnit;
  final FuelUnit fuelUnit;
  final DateTime createdAt;

  Bike copyWith({
    String? id,
    String? name,
    String? manufacturer,
    String? model,
    int? year,
    bool clearYear = false,
    DistanceUnit? distanceUnit,
    FuelUnit? fuelUnit,
    DateTime? createdAt,
  }) {
    return Bike(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      year: clearYear ? null : year ?? this.year,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      fuelUnit: fuelUnit ?? this.fuelUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'model': model,
      'year': year,
      'distanceUnit': distanceUnit.name,
      'fuelUnit': fuelUnit.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'] as String,
      name: map['name'] as String,
      manufacturer: map['manufacturer'] as String,
      model: map['model'] as String,
      year: map['year'] as int?,
      distanceUnit: DistanceUnit.values.firstWhere(
        (value) => value.name == map['distanceUnit'],
        orElse: () => DistanceUnit.km,
      ),
      fuelUnit: FuelUnit.values.firstWhere(
        (value) => value.name == map['fuelUnit'],
        orElse: () => FuelUnit.liters,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
