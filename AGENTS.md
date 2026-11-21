# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Snapshot

Moto Mileage is an offline-first Flutter app for motorcycle fuel tracking, mileage analytics, maintenance logs, reminders, CSV export, and local JSON backup/restore. It intentionally avoids backend services, accounts, and cloud sync; all app state is local to the device.

Primary stack:

- Flutter with Material 3
- Dart SDK `^3.10.7`
- GetX for state management, navigation, and dependency injection
- `sqflite` as the local database engine
- JSON payloads stored in a SQLite-backed key/value table
- `fl_chart`, `flutter_staggered_grid_view`, `intl`, `uuid`, `path_provider`, and `share_plus`

## Repository Map

- `lib/main.dart` initializes Flutter, `LocalStorageService`, GetX bindings, and `MotoMileageApp`.
- `lib/app/app.dart` defines the root `GetMaterialApp`, theme wiring, and startup gate.
- `lib/app/bindings/initial_binding.dart` owns dependency registration. Add new repositories, services, and controllers here.
- `lib/app/constants.dart` contains storage keys and domain enums.
- `lib/app/models/` contains serializable domain models with `copyWith`, `toMap`, and `fromMap`.
- `lib/app/repositories/` provides persistence abstractions over `LocalStorageService`.
- `lib/app/services/` contains storage, backup, export, and demo-data utilities.
- `lib/app/controllers/` coordinates app state, business rules, and derived metrics.
- `lib/app/views/` contains screens, sheets, and reusable widgets.
- `lib/app/theme/` contains app theme presets.
- `lib/app/utils/` contains formatting and asset helpers.
- `test/` currently has a placeholder widget test; add targeted tests when business logic changes.
- Platform folders (`android`, `ios`, `macos`, `linux`, `windows`, `web`) are Flutter-generated unless explicitly changed for platform behavior.

## Architecture Rules

- Keep the existing layer boundaries:
  - Views render UI and call controller methods.
  - Controllers own business logic, reactive state, sorting, recalculation, and workflow coordination.
  - Repositories load and save domain data.
  - Services handle cross-cutting utilities such as storage, backup, CSV export, and demo data.
  - Models stay plain and serializable.
- Use GetX patterns already present in the codebase: `Rx`, `RxList`, `RxnString`, `Obx`, `Get.find`, `Get.put`, and `Get.lazyPut`.
- Register new dependencies in `InitialBinding`; avoid ad hoc instantiation in views.
- Preserve the offline-first/no-account product model unless the task explicitly changes that direction.
- Keep data scoped by bike ID. Fuel logs and maintenance entries use `StorageKeys.fuelLogs(bikeId)` and `StorageKeys.maintenance(bikeId)`.

## Persistence Conventions

`LocalStorageService` opens `motomileage.db` and stores values in the `kv_store` table. Although SQLite is used, most app data is serialized as JSON lists or maps.

When adding persistent data:

- Add constants to `StorageKeys` for shared keys.
- Prefer `setJsonMap`, `getJsonMap`, `setJsonList`, and `getJsonList`.
- Keep model `toMap`/`fromMap` backward tolerant where possible.
- Update backup and restore behavior in `BackupService` when new user data must survive export/import.
- Consider demo data if the new feature affects showcase flows.

## Domain Behavior To Preserve

- Fuel entries are recalculated as a chronological chain after add, edit, or delete.
- The first fuel entry has no trip distance or mileage because there is no prior odometer baseline.
- A valid trip requires the current odometer to be greater than the previous odometer.
- `pricePerUnit` is computed from `totalCost / fuelQuantity` when fuel quantity is positive.
- `costPerDistance` is computed only for valid positive trip distance.
- Maintenance due status depends on `nextDueOdometer` compared with current odometer.
- Deleting a bike must delete bike-scoped fuel and maintenance data.

## UI Guidance

- Match the existing Material 3/GetX style in `lib/app/views`.
- Reuse existing widgets from `lib/app/views/widgets` before adding new UI primitives.
- Keep forms in sheets when that matches the current flow.
- Use app theme colors and text styles instead of hard-coded visual systems.
- Make mobile layouts dense, readable, and practical for repeated logging.
- Promotional screenshots live under `assets/MotoMileage - Promotional Images/`; app store badges live under `assets/png/`.

## Quality Checks

Before handing off code changes, run the relevant checks:

```bash
dart format lib test
flutter analyze
flutter test
```

For platform or dependency work, also run:

```bash
flutter pub get
flutter build apk --debug
flutter build ios --debug --no-codesign
```

Use the narrower set that fits the change when time is limited, and report any checks that could not be run.

## Editing Expectations

- Prefer small, focused changes that follow nearby code style.
- Do not rewrite generated platform files unless the task requires platform configuration.
- Do not introduce network, auth, analytics, or cloud sync dependencies without an explicit product request.
- Avoid unrelated refactors and formatting churn.
- Update README or this file when setup, architecture, or major workflows change.
- Add or update tests when changing calculations, serialization, backup/restore, controller behavior, or data deletion.

