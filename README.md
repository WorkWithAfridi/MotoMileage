# Moto Mileage

Moto Mileage is an offline-first motorcycle companion for tracking fuel, mileage, costs, and maintenance. Your records stay on your device in a local SQLite database. The app has no account, backend, or cloud sync.

| Dashboard | Fuel history | Maintenance |
| --- | --- | --- |
| ![Moto Mileage dashboard running on iPhone 18 Pro simulator](assets/readme/iphone-18-pro-dashboard.png) | ![Moto Mileage fuel history](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.40.png) | ![Moto Mileage maintenance reminders](assets/MotoMileage%20-%20Promotional%20Images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-03-03%20at%2009.40.45.png) |

The dashboard screenshot was captured from a debug build running in the iPhone 18 Pro simulator. Fuel and maintenance screenshots are from the project’s iPhone 17 Pro promotional captures.

## Features

- **Multiple bikes:** Keep fuel and service history separate for each bike, and choose distance, fuel, and currency units.
- **Fuel log:** Record odometer readings, refill quantity, cost, date, fuel type, station, and notes.
- **Automatic calculations:** See trip distance, fuel economy, price per unit, and cost per distance. Later entries are recalculated when an earlier entry changes.
- **Dashboard and reports:** Review performance, spending, refill patterns, station reports, and trends with charts.
- **Maintenance log:** Record services and notes, set odometer-based due targets, and see due or overdue status.
- **Local backup and export:** Export fuel logs as CSV, back up app data as JSON, and restore from a JSON backup.
- **Demo data:** Load a sample dataset to explore the app.
- **Themes and localization:** Choose from 12 light and dark theme presets. The interface supports English, Simplified Chinese, Hindi, Spanish, French, Bengali, Portuguese, Russian, and Indonesian.

## Privacy and storage

Moto Mileage is designed to work offline. App records and preferences are stored locally in SQLite on the device. There is no sign-in, analytics SDK, backend, or cloud synchronization. CSV export and JSON backup use the device’s sharing and file-picking flows; sharing a file is initiated by the user.

## Tech stack

- Flutter and Dart (`^3.10.7`)
- Material 3
- GetX for state management, routing, and dependency injection
- SQLite via `sqflite`, with JSON payloads in a local key-value table
- `fl_chart` and `flutter_staggered_grid_view` for dashboard visualization and layout
- `intl`, `uuid`, `path`, `path_provider`, and `share_plus`

## Project structure

```text
lib/
  main.dart                 App entry point
  app/
    bindings/               Dependency registration
    constants.dart          Shared keys and domain enums
    controllers/            App state and business logic
    localization/           Translations and localized text
    models/                 Serializable domain models
    repositories/           Persistence abstractions
    services/               SQLite, backup, export, and demo data
    theme/                  Theme presets and app themes
    views/                  Screens, forms, and reusable widgets
    utils/                  Formatting and asset helpers
test/                       Unit and widget tests
assets/                     Store art, promotional screenshots, and icons
```

The app keeps views, controllers, repositories, services, and models separate. Bike-specific fuel and maintenance records are stored under keys scoped to the bike ID. When adding persistent user data, update backup and restore behavior as well as the relevant model and repository.

## Getting started

### Requirements

- Flutter stable with Dart SDK `^3.10.7`
- Xcode for iOS builds and the iOS Simulator
- Android Studio or an Android SDK for Android builds

### Run locally

```sh
git clone https://github.com/WorkWithAfridi/MotoMileage.git
cd MotoMileage
flutter pub get
flutter run
```

To run on an iPhone simulator, start an available simulator and run:

```sh
flutter devices
flutter run -d <device-id>
```

### Build

```sh
flutter build apk
flutter build appbundle
flutter build ios
```

## Development

Format Dart files and run static analysis and tests before opening a pull request:

```sh
dart format lib test
flutter analyze
flutter test
```

For changes to fuel calculations, persistence, backup/restore, or deletion behavior, add or update targeted tests. For interface changes, check the relevant flows on a simulator or device and include screenshots in the pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidance and [SECURITY.md](SECURITY.md) for vulnerability reports.

## License

Moto Mileage is licensed under the [MIT License](LICENSE).
