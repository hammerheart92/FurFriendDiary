# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Basic Commands
- `flutter pub get` - Install dependencies
- `dart format --set-exit-if-changed .` - Format code and exit with error if changes needed
- `dart analyze` - Run static analysis
- `flutter test` - Run unit and widget tests
- `flutter gen-l10n` - Generate localization files

### Code Generation
- `dart run build_runner build` - Generate code (Hive adapters, Riverpod providers, JSON serialization)
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files

### Build Commands
- `flutter build apk --release` - Build Android APK
- `flutter build ipa --release` - Build iOS IPA (macOS with Xcode required)
- `flutter build apk --dart-define-from-file=.env` - Build with environment variables

### Run Commands
- `flutter run` - Run in debug mode
- `flutter run --release` - Run in release mode
- `flutter run --dart-define-from-file=.env` - Run with environment variables

### Testing
- `flutter test` - Run all tests
- `flutter test test/unit/` - Run unit tests only
- `flutter test test/widget/` - Run widget tests only
- `flutter test integration_test/` - Run integration tests

## Architecture Overview

### Layered Architecture
- **Presentation Layer**: UI screens, widgets, and Riverpod providers (`lib/src/presentation/`, `lib/src/ui/`)
- **Domain Layer**: Business models, repositories interfaces, use cases (`lib/src/domain/`)
- **Data Layer**: Repository implementations, local storage, services (`lib/src/data/`, `lib/src/services/`)

### State Management
- **Riverpod 2.x** with code generation using `@riverpod` annotations
- Providers are generated using `riverpod_generator` and `riverpod_annotation`
- All provider files end with `.g.dart` (generated code)
- Use `ref.invalidateSelf()` to refresh provider state after mutations

### Data Persistence
- **Hive** for local data storage with custom adapters
- `HiveManager` singleton manages all box operations
- Box names defined as constants in `HiveManager`
- All domain models have generated Hive adapters (typeId assignments in models)
- Hive adapters registered in `HiveManager._registerAdapters()`

### Navigation
- **go_router** with typed routes and shell routing
- Main navigation through `AppShell` with bottom navigation
- Route guards check setup completion status
- Nested routes for detail screens (e.g., `/meds/detail/:medicationId`)

### Key Data Models
- `PetProfile` - Pet information and settings
- `FeedingEntry` - Feeding records
- `MedicationEntry` - Medication schedules and administration
- `AppointmentEntry` - Veterinary appointments
- `Walk` - Walk tracking with location data
- `ReportEntry` - Generated reports and analytics

### Provider Patterns
- Repository providers inject implementations into care data providers
- Care data providers expose CRUD operations and invalidate on mutations
- Filtered providers for date ranges, pet-specific data, active/inactive states
- Form state providers for complex forms with validation

### Code Generation Files
Generated files are committed to the repository:
- `*.g.dart` - Riverpod providers, Hive adapters, JSON serialization
- `*.freezed.dart` - Immutable data classes (if using Freezed)

## Monetization
- One-time lifetime unlock via `in_app_purchase`
- Premium features gated behind purchase verification
- Local premium status with receipt validation

## Important Notes
- Minimum supported versions: Android 8.0 (API 26), iOS 13.0
- All packages are pinned to specific versions in `pubspec.yaml`
- Dark mode and accessibility support included
- Notifications via `flutter_local_notifications` with timezone support
- Image handling via `image_picker` and `flutter_secure_storage` for sensitive data

## Testing Strategy
- Unit tests for repositories and business logic
- Widget tests for key screens and components
- Integration tests for critical user flows
- Mocktail for mocking dependencies