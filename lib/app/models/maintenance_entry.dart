import '../constants.dart';

class MaintenanceEntry {
  MaintenanceEntry({
    required this.id,
    required this.bikeId,
    required this.type,
    this.customType,
    required this.odometer,
    required this.date,
    this.notes,
    this.nextDueOdometer,
  });

  final String id;
  final String bikeId;
  final MaintenanceType type;
  final String? customType;
  final double odometer;
  final DateTime date;
  final String? notes;
  final double? nextDueOdometer;

  MaintenanceEntry copyWith({
    String? id,
    String? bikeId,
    MaintenanceType? type,
    String? customType,
    bool clearCustomType = false,
    double? odometer,
    DateTime? date,
    String? notes,
    bool clearNotes = false,
    double? nextDueOdometer,
    bool clearNextDueOdometer = false,
  }) {
    return MaintenanceEntry(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      type: type ?? this.type,
      customType: clearCustomType ? null : customType ?? this.customType,
      odometer: odometer ?? this.odometer,
      date: date ?? this.date,
      notes: clearNotes ? null : notes ?? this.notes,
      nextDueOdometer: clearNextDueOdometer
          ? null
          : nextDueOdometer ?? this.nextDueOdometer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bikeId': bikeId,
      'type': type.name,
      'customType': customType,
      'odometer': odometer,
      'date': date.toIso8601String(),
      'notes': notes,
      'nextDueOdometer': nextDueOdometer,
    };
  }

  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntry(
      id: map['id'] as String,
      bikeId: map['bikeId'] as String,
      type: MaintenanceType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => MaintenanceType.custom,
      ),
      customType: map['customType'] as String?,
      odometer: (map['odometer'] as num).toDouble(),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      notes: map['notes'] as String?,
      nextDueOdometer: (map['nextDueOdometer'] as num?)?.toDouble(),
    );
  }
}
