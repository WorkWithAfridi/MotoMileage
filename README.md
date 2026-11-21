# Moto Mileage - Motorcycle Fuel Tracker & Maintenance Log (Flutter)

Moto Mileage is an offline-first bike companion app that helps riders log fuel refills, track mileage and fuel costs, and manage maintenance schedules from one place.

The app is built with Flutter and stores everything locally using SQLite, so it works without internet, account setup, or cloud sync.

Keywords: bike fuel tracker, motorcycle mileage tracker, bike maintenance app, fuel log app, mileage calculator, offline fuel expense tracker, Flutter motorcycle app.

## Table of Contents

- [Project Overview](#project-overview)
- [App Screenshots](#app-screenshots)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Architecture & Data Flow](#architecture--data-flow)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Contributing](#contributing)
- [Testing & Quality](#testing--quality)
- [Planned Improvements](#planned-improvements)

## Project Overview

Moto Mileage focuses on practical day-to-day riding needs:

- Track every fuel refill with useful metadata
- Calculate real-world mileage and cost trends automatically
- Record service/maintenance activities and due targets
- View dashboard analytics per bike
- Export and back up data locally

The core product goal is reliability and privacy for riders who prefer an offline, no-cloud workflow.

## App Screenshots

Promotional screenshots from the latest app build:

| Screenshot 1 | Screenshot 2 |
| --- | --- |
| ![Moto Mileage screenshot 1](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.14.png) | ![Moto Mileage screenshot 2](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.33.png) |

| Screenshot 3 | Screenshot 4 |
| --- | --- |
| ![Moto Mileage screenshot 3](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.40.png) | ![Moto Mileage screenshot 4](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.45.png) |

| Screenshot 5 | Screenshot 6 |
| --- | --- |
| ![Moto Mileage screenshot 5](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.51.png) | ![Moto Mileage screenshot 6](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.57.png) |

| Screenshot 7 | Screenshot 8 |
| --- | --- |
| ![Moto Mileage screenshot 7](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.41.07.png) | ![Moto Mileage screenshot 8](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.41.20.png) |

## Key Features

### 1. Multi-Bike Management

- Create, edit, and delete bikes
- Switch active bike quickly from the app bar
- Keep fuel and maintenance history isolated per bike
- Configure measurement units for each bike

### 2. Fuel Logging & Smart Calculations

- Add, edit, and delete fuel entries
- Optional fields: fuel type, station, notes, date
- Auto-computed metrics:
  - Trip distance
  - Fuel efficiency (mileage)
  - Cost per unit
  - Cost per distance
- Recalculation chain keeps subsequent entries consistent after edits/deletes

### 3. Maintenance Tracking

- Log maintenance records (oil, chain lube, custom)
- Add next-due odometer values
- See due/overdue visual status directly in cards

### 4. Dashboard & Analytics

Segmented dashboard with cards and charts:

- `Performance`: average/latest/best/worst mileage + trend
- `Cost & Spending`: monthly expense, recent cost behavior, cost-per-distance
- `Fuel Profile`: refill patterns, fuel usage, fuel type distribution

### 5. Reminders

- Refill reminder based on configured interval
- Maintenance due reminder from odometer progression

### 6. Export, Backup, and Restore

- CSV export for bike fuel logs
- JSON backup of full app state
- JSON restore from payload
- Demo dataset loader for local testing and showcase

### 7. Onboarding & Themes

- First-launch onboarding flow (shown once)
- 12 built-in theme presets (light and dark)

### 8. Languages

- Detects the device language automatically and falls back to English
- Supports English, Simplified Chinese, Hindi, Spanish, French, Bengali,
  Portuguese, Russian, and Indonesian
- Allows an optional persisted language override from Settings
- Localizes app UI, dialogs, validation, dates, numbers, exports, onboarding,
  and the fuel and maintenance tips library

## Tech Stack

### Framework & Language

- Flutter (Material 3)
- Dart SDK `^3.10.7`

### State, Routing, and DI

- `get` (GetX) for state management, navigation, dependency injection

### Local Storage & Data

- `sqflite` for SQLite persistence
- `path` for file/path helpers
- `uuid` for unique IDs

### Data Export & Sharing

- `path_provider` for local file access
- `share_plus` for share/export flows

### UI & Visualization

- `fl_chart` for analytics charts
- `flutter_staggered_grid_view` for dashboard layouts
- `intl` for formatting
- `flutter_localizations` for Material and platform localization support

## Architecture & Data Flow

### Offline-First Design

- No backend/API integration
- No authentication dependency
- All data and logic run locally on-device

### Storage

- App data persisted in SQLite
- Key app preferences stored in `kv_store`, including:
  - `active_bike_id`
  - `settings`
  - `onboarding_seen`

### Layering

- `views` handle UI rendering and interactions
- `controllers` coordinate business logic and derived metrics
- `repositories` provide persistence abstraction
- `services` handle backup/export/storage utilities
- `models` represent serializable domain objects

## Project Structure

- `lib/main.dart` - app entrypoint and startup initialization
- `lib/app/app.dart` - root app widget and global bindings
- `lib/app/bindings` - dependency graph setup
- `lib/app/constants.dart` - app enums, constants, storage keys
- `lib/app/models` - bike, fuel, maintenance, and settings models
- `lib/app/repositories` - SQLite-backed repositories
- `lib/app/services` - storage, export, backup, demo data services
- `lib/app/controllers` - state and analytics logic
- `lib/app/views` - screens, sheets, and reusable presentation widgets
- `lib/app/theme` - theme presets and theme config
- `lib/app/utils` - utility helpers

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android Studio or VS Code with Flutter/Dart plugins
- A connected device or emulator

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

### Build Release Artifacts

```bash
flutter build apk
flutter build appbundle
flutter build ios
```

## Development Workflow

1. Create a feature/fix branch from your main development branch.
2. Implement focused changes with readable commits.
3. Run formatting and checks locally.
4. Verify behavior manually (fuel flow, maintenance flow, dashboard impact).
5. Open a pull request with clear scope and screenshots for UI changes.

## Contributing

Contributions are welcome for feature improvements, bug fixes, and documentation.

### Contribution Guidelines

1. Fork the repository and create a new branch.
2. Keep each PR scoped to one logical change.
3. Follow existing architecture patterns (`controllers` + `repositories` + `services`).
4. Use clear naming and avoid unrelated refactors in the same PR.
5. Add/update tests when business logic changes.
6. Update README/docs when behavior or setup changes.

### Commit Style (Recommended)

Use concise commit messages such as:

- `feat: add fuel entry validation for negative values`
- `fix: recalculate mileage chain after fuel delete`
- `docs: update setup and contribution guide`

### Pull Request Checklist

- [ ] App runs locally without regressions
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] UI changes validated on at least one real/simulated device
- [ ] Docs updated if needed

## Testing & Quality

Run before opening a PR:

```bash
dart format .
flutter analyze
flutter test
```

Also test key journeys manually:

- Add/edit/delete bike
- Add/edit/delete fuel entries and metric recalculation
- Add/delete maintenance records and due status updates
- Backup/export and restore behavior

## Planned Improvements

- More granular reminder configurations
- Enhanced trend filters (time range presets)
- Better import/export UX for larger datasets
- Additional widget-level test coverage

---

If you are publishing this repository publicly, keep the project title, description, and tags aligned with bike fuel tracking and motorcycle maintenance search terms for stronger discoverability.
