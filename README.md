# MotoMileage (Offline-Only)

MotoMileage is a fully offline bike fuel tracker built with Flutter, GetX, and SharedPreferences.

## Architecture

- Offline-only operation (no API, no cloud sync, no auth)
- Local persistence with `SharedPreferences`
- All records stored as JSON strings / JSON lists
- GetX used for:
  - State management
  - Navigation shell
  - Dependency injection

## Storage Keys

- `bikes` -> JSON list of bikes
- `active_bike_id` -> selected bike id
- `fuel_logs_{bikeId}` -> JSON list of fuel logs for a bike
- `maintenance_{bikeId}` -> JSON list of maintenance items for a bike
- `settings` -> JSON object for app settings

## Implemented Phase 1 Baseline

- Bike Management
  - Add, edit, delete bike
  - Active bike switching
  - Bike-scoped data cleanup on delete

- Fuel Logging
  - Quick add form (odometer, quantity, cost + optional fields)
  - Edit and delete entries
  - Automatic calculations persisted per entry:
    - Trip distance
    - Mileage
    - Price per unit
    - Cost per distance
  - Full recalculation after edit/delete

- Dashboard
  - Summary cards:
    - Average mileage
    - Total distance
    - Total fuel consumed
    - Total fuel cost
    - This month expense
    - Best/worst mileage
  - Charts:
    - Mileage trend (line)
    - Monthly expense (bar)

- Maintenance
  - Add/delete maintenance entries
  - Optional next due odometer
  - In-app due reminder indicator

- Refill Reminder
  - Uses reminder interval from settings
  - Triggers in-app alert when threshold is crossed

- Data Export
  - CSV export for current bike fuel logs (share sheet)

- Local Backup & Restore
  - Backup all keys into one JSON file (share sheet)
  - Restore from JSON text input
  - Debug action to replace local data with realistic demo dataset

- Settings
  - Currency symbol
  - Decimal precision
  - Default distance unit
  - Default fuel unit
  - Refill reminder interval
  - Dark/light theme toggle

## Main Project Structure

- `lib/app/models` -> JSON-serializable domain models
- `lib/app/repositories` -> SharedPreferences repositories
- `lib/app/services` -> storage, backup, export services
- `lib/app/controllers` -> GetX business logic and calculations
- `lib/app/views` -> UI screens and forms
- `lib/app/bindings` -> dependency graph

## Run

```bash
flutter pub get
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```

Both are currently passing.
