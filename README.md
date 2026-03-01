# Moto Mileage

Moto Mileage is an offline-first bike fuel and maintenance tracker built with Flutter.
It is designed for fast daily logging, meaningful insights, and zero cloud dependency.

## Highlights

- Fully offline app (no API, no auth, no cloud sync)
- Local persistence with SharedPreferences (JSON-encoded models)
- GetX for state management, dependency injection, and navigation flow
- Multi-bike support with per-bike fuel and maintenance history
- Smart fuel calculations (trip, mileage, cost-per-unit, cost-per-distance)
- Segmented analytics dashboard with cards + charts
- Local CSV export and full JSON backup/restore
- Startup flow with splash + onboarding walkthrough
- 12 selectable color theme presets (default: dark `Midnight Teal`)

## Architecture

### Offline-only

- No backend communication
- No internet required
- All app behavior runs locally

### Storage model (SharedPreferences)

Data is stored as key-value JSON payloads:

- `bikes` -> JSON list of bikes
- `active_bike_id` -> currently selected bike id
- `fuel_logs_{bikeId}` -> JSON list of fuel entries per bike
- `maintenance_{bikeId}` -> JSON list of maintenance entries per bike
- `settings` -> JSON object of app settings and theme preset
- `onboarding_seen` -> bool flag for first-launch onboarding

### Tech stack

- Flutter (Material 3)
- GetX (`get`)
- SharedPreferences (`shared_preferences`)
- Charts (`fl_chart`)
- Staggered cards (`flutter_staggered_grid_view`)
- Export/share (`path_provider`, `share_plus`)
- Formatting (`intl`)

## Features

### 1. Startup & Onboarding

- Splash screen
- First-launch onboarding with feature explanation pages
- Skip / Next / Get Started flow
- Onboarding shown once (`onboarding_seen`)

### 2. Bike Management

- Add, edit, delete bikes
- Configurable units per bike (distance + fuel)
- Active bike switcher in app bar
- Deleting bike removes bike-scoped fuel/maintenance data

### 3. Fuel Logging

- Quick add fuel entry
- Edit and delete entries
- Optional fields: fuel type, station, notes, date
- Automatic calculations on save/re-save:
  - Trip distance
  - Mileage
  - Price per unit
  - Cost per distance
- Recalculation propagation for subsequent entries after edit/delete
- Newest entries shown first in list

### 4. Maintenance Logging

- Add and delete maintenance records
- Maintenance types (oil, chain lube, custom)
- Next due odometer support
- Due status shown in list cards
- Newest entries shown first in list

### 5. Dashboard (Segmented)

Dashboard is grouped into sections with mixed cards and charts:

- `Performance`
  - Mileage cards and mileage trend chart
- `Cost & Spending`
  - Cost cards, monthly expense chart, cost/distance trend
- `Fuel Profile`
  - Fuel cards, fuel quantity trend, fuel type split pie

Includes metrics such as:

- Average/latest mileage
- Best/worst mileage
- Total distance/fuel/refills
- Avg refill cost
- Avg trip distance
- Avg cost per distance
- This month expense
- Last 30 days expense
- 30-day change vs previous period

Info bottom sheets (`i` icon) are available on selected cards to explain metric formulas.

### 6. Reminders

- Refill reminder based on configured interval
- Maintenance due reminder based on latest odometer vs next due
- Reminder cards are theme-aware

### 7. Export, Backup, Restore

- CSV export of current bike fuel logs
- JSON backup of full app state
- JSON restore from pasted payload
- Debug action to load rich demo dataset

### 8. Theme System

Theme selection is in Settings (`Theme` section), with 12 presets:

1. Midnight Teal (Dark) [default]
2. Ocean Light
3. Forest Mist
4. Sunset Sand
5. Royal Indigo (Dark)
6. Rose Blush
7. Volcanic Ash (Dark)
8. Arctic Blue
9. Emerald Night (Dark)
10. Citrus Pop
11. Lavender Haze
12. Graphite Mono (Dark)

## UX Notes

- Bottom sheets use drag handle + explicit `Close` button
- Form sheets are keyboard-safe and scrollable
- Fuel/Maintenance cards show additional optional details when available

## Project Structure

- `lib/main.dart` -> app bootstrap + storage init
- `lib/app/app.dart` -> root app + theme binding
- `lib/app/constants.dart` -> enums and storage keys
- `lib/app/models` -> serializable domain models
- `lib/app/repositories` -> storage repositories
- `lib/app/services` -> storage, backup, csv, demo data services
- `lib/app/controllers` -> business logic and computed metrics
- `lib/app/views` -> UI screens and bottom sheets
- `lib/app/theme` -> theme preset system
- `lib/app/bindings` -> dependency graph

## Getting Started

```bash
flutter pub get
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```

Current status: both commands pass.
