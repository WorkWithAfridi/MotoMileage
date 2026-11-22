# Contributing

Contributions to Moto Mileage are welcome. For larger changes, open an issue first to discuss the approach.

## Development setup

1. Install Flutter stable and the platform tools you need.
2. Clone the repository and run `flutter pub get`.
3. Run the app with `flutter run` or use the relevant simulator/device.

## Pull requests

- Keep each pull request focused and describe the user-visible change.
- Follow the existing architecture: views render UI, controllers coordinate behavior, repositories persist data, services handle cross-cutting operations, and models remain serializable.
- Keep the app offline-first. Do not add accounts, analytics, backend services, or cloud sync without first discussing the product change.
- Scope fuel and maintenance records to their bike ID.
- Update backup and restore when adding persistent user data.
- Add or update tests when changing calculations, serialization, backup/restore, controller behavior, or deletion flows.
- Run `dart format lib test`, `flutter analyze`, and `flutter test` when applicable. Include any checks you could not run in the pull request description.
- For UI changes, test the affected flow on a simulator or device and attach screenshots.

## Reporting issues

Include the app version, device/platform, steps to reproduce, expected behavior, and actual behavior. Remove personal data from logs and screenshots before posting them publicly.
