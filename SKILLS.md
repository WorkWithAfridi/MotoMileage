# SKILLS.md

Practical skills for agents working on Moto Mileage.

## Skill: Fuel Log And Mileage Logic

Use this skill when changing fuel entry creation, editing, deletion, sorting, dashboard metrics, or mileage/cost calculations.

Key files:

- `lib/app/controllers/fuel_controller.dart`
- `lib/app/models/fuel_log_entry.dart`
- `lib/app/repositories/fuel_repository.dart`
- `lib/app/views/fuel_logs_view.dart`
- `lib/app/views/widgets/fuel_entry_form_sheet.dart`

Checklist:

- Preserve chronological recalculation in `_persistWithRecalculation`.
- Sort by date first and odometer second when order matters.
- Keep first-entry derived metrics empty.
- Guard against zero or negative fuel quantity and non-increasing odometers.
- Persist through `FuelRepository.saveFuelLogs`.
- Add focused tests for calculation changes.

## Skill: Bike Management

Use this skill when changing bike creation, active-bike switching, unit defaults, or bike deletion behavior.

Key files:

- `lib/app/controllers/bike_controller.dart`
- `lib/app/models/bike.dart`
- `lib/app/repositories/bike_repository.dart`
- `lib/app/views/home_shell_view.dart`
- `lib/app/views/widgets/bike_form_sheet.dart`

Checklist:

- Keep bike IDs UUID-based.
- Use settings defaults for distance and fuel units when a bike does not specify units.
- Ensure active bike fallback is valid after reload or deletion.
- Delete bike-scoped fuel and maintenance data when deleting a bike.
- Verify dependent controllers reload after active-bike changes.

## Skill: Maintenance Tracking

Use this skill when changing service logs, due/overdue behavior, maintenance types, or maintenance UI.

Key files:

- `lib/app/controllers/maintenance_controller.dart`
- `lib/app/models/maintenance_entry.dart`
- `lib/app/repositories/maintenance_repository.dart`
- `lib/app/views/maintenance_view.dart`
- `lib/app/views/widgets/maintenance_form_sheet.dart`
- `lib/app/constants.dart`

Checklist:

- Add new maintenance types to `MaintenanceType` and `MaintenanceTypeX.label`.
- Keep maintenance entries scoped by active bike.
- Sort newest first by date, then odometer.
- Treat `nextDueOdometer` as optional.
- Update backup/restore behavior only if storage shape changes.

## Skill: Local Storage, Backup, And Restore

Use this skill when changing persisted data, backup JSON, restore behavior, or storage keys.

Key files:

- `lib/app/services/local_storage_service.dart`
- `lib/app/services/backup_service.dart`
- `lib/app/constants.dart`
- `lib/app/repositories/*_repository.dart`
- `lib/app/models/*.dart`

Checklist:

- Add or update `StorageKeys` for shared persisted keys.
- Make `fromMap` tolerant of missing or older fields when possible.
- Include new user-owned data in backup export and restore.
- Avoid clearing storage except in explicit restore/reset flows.
- Test restore with missing optional fields and multi-bike payloads.

## Skill: CSV Export And Sharing

Use this skill when changing exported fuel-log columns, formatting, or share flows.

Key files:

- `lib/app/services/csv_export_service.dart`
- `lib/app/controllers/fuel_controller.dart`
- `lib/app/views/fuel_logs_view.dart`

Checklist:

- Escape CSV fields that may contain commas, quotes, or newlines.
- Keep date formatting stable unless the product requirement changes.
- Update headers and row values together.
- Verify exported values respect nullable fields.

## Skill: Settings, Theme, And Onboarding

Use this skill when changing settings, theme presets, units, reminders, or first-run behavior.

Key files:

- `lib/app/controllers/settings_controller.dart`
- `lib/app/models/app_settings.dart`
- `lib/app/repositories/settings_repository.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/views/settings_view.dart`
- `lib/app/views/onboarding_view.dart`
- `lib/app/views/startup_gate_view.dart`

Checklist:

- Persist settings through `SettingsRepository`.
- Keep app settings serializable and backward tolerant.
- Add theme presets in both enum and theme factory logic.
- Confirm `StartupGateView` still routes correctly after onboarding changes.
- Check status/navigation bar colors after theme changes.

## Skill: Dashboard And Analytics

Use this skill when changing summary cards, charts, trends, or derived dashboard values.

Key files:

- `lib/app/controllers/dashboard_controller.dart`
- `lib/app/controllers/fuel_controller.dart`
- `lib/app/views/dashboard_view.dart`
- `lib/app/views/widgets/summary_card.dart`
- `lib/app/utils/formatters.dart`

Checklist:

- Base analytics on recalculated fuel entries, not raw form inputs.
- Handle empty, single-entry, and invalid-trip states gracefully.
- Keep chart labels compact for mobile screens.
- Use `AppFormatters` for displayed dates and numbers when appropriate.

## Skill: App Initialization And Dependency Injection

Use this skill when adding controllers, repositories, services, startup gates, or global app behavior.

Key files:

- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/bindings/initial_binding.dart`

Checklist:

- Initialize async services before `runApp`.
- Register repositories and services before controllers that depend on them.
- Use `permanent: true` for app-level controllers that should live for the whole session.
- Prefer `fenix: true` for lazily created services/repositories matching the existing pattern.

## Skill: Testing And Verification

Use this skill before finishing any behavioral code change.

Commands:

```bash
dart format lib test
flutter analyze
flutter test
```

Test targets to consider:

- Fuel recalculation chains after insert, edit, delete, and out-of-order dates.
- Bike deletion removing scoped data.
- Backup/restore preserving multiple bikes and optional fields.
- CSV escaping and nullable field handling.
- Settings serialization defaults.

When a change is UI-only, at minimum run `dart format` and `flutter analyze`, then manually smoke-test the relevant screen if a device or simulator is available.

