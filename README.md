
# FurFriendDiary (Flutter)

One-sentence: A production-ready Flutter app to manage pet care, including feedings, walks, meds, vet appointments, reminders, reports, and monetization.

## Quick start (CLI only)

1. Install Flutter (3.24+), Dart SDK 3.4+, and platform SDKs.
2. From project root:
   ```bash
   flutter pub get
   dart format --set-exit-if-changed .
   dart analyze
   flutter test
   flutter gen-l10n
   # Android release (CLI):
   flutter build apk --release
   # iOS release (CLI, on macOS with Xcode installed):
   flutter build ipa --release
   ```

### Minimum OS (proposed, confirm with PM)
- Android: 8.0 (API 26)
- iOS: 13.0
- Devices: phones and tablets
- Accessibility: VoiceOver/TalkBack, larger text, semantics, high-contrast scheme supported
- Dark mode: supported

## Architecture

- Layered: **presentation** (ui/widgets), **domain** (models/use-cases), **data** (repositories/services).
- State management: **Riverpod**. Rationale: simple DI, testable providers, compile-time safety, minimal boilerplate versus Bloc, and clearer ownership than Provider for medium apps.
- Navigation: **go_router** with typed routes.

## Offline & persistence
- Hive for domain data (feedings, walks, meds, appointments) in `lib/src/data/local/`.
- `flutter_secure_storage` for secrets and token-like items.
- Migrations handled using Hive box versioning.

## Notifications
- `flutter_local_notifications` with `timezone` for accurate local scheduling.
- Permissions requested with `permission_handler` only when needed.

## Monetization
- Strategies:
  1. Subscription (monthly/annual) for premium features (advanced reports, unlimited pets).
  2. One-time lifetime unlock.
  3. Ads + paid ad-free.
- Implemented: **One-time lifetime unlock** via `in_app_purchase`. Local premium gating, receipt cache, and server-side validation instructions in `docs/monetization.md`.

## Packages and licenses
- All packages pinned and under MIT/BSD/Apache. See `DECISIONS.md`.

## Tests
- Unit tests for repositories and scheduling logic.
- Widget tests for key screens.
- Integration test for reminder + persistence happy path.

## CI/CD
- GitHub Actions in `.github/workflows/ci.yml` runs format, analyze, tests, and build.
- No remotes are pushed by CI, artifacts stored in workflow run only.

## Localization
- English default with ARB in `assets/i18n/`. Add more locales by copying the ARB and translations.

## Security & privacy
- Least permissions, plaintext secrets not committed. See `.env.example` and `docs/security_privacy.md`.
- GDPR/CCPA notes included.

## State choice
Riverpod over Bloc and Provider due to balance of clarity, testability, and small footprint. Bloc is fine for complex event streams, Provider ok for tiny apps, Riverpod fits most mid-sized apps like this.

## Build variants
- `--dart-define-from-file=.env` supported. See `.env.example`.

## Release checklist
- [ ] Update app icons (see `docs/assets.md`).
- [ ] Set bundle ID, app name, and version.
- [ ] Configure IAP products in App Store Connect and Google Play.
- [ ] Verify notifications on physical devices in multiple timezones.
- [ ] Run integration tests on emulators and on-device.
- [ ] Confirm privacy policy links in store metadata.

Generated on 2025-09-10.
