
# QA / PM Handoff

## Test Cases (high level)
- Create feeding, edit, delete.
- Log a walk with duration and optional distance.
- Add medication with schedule, ensure reminder created.
- Create vet appointment with notes and check reminder.
- Toggle premium and verify gated feature labels.
- Change settings and verify persistence.
- Try app in dark mode and with large font sizes.
- Localization key fallback works for English.

## Known Issues
- IAP requires real store configuration before products load.
- Calendar export is not implemented, use reports as CSV in next sprint.
- Analytics not wired to a provider, only setting is present.

## Upgrade Steps
- Bump Flutter and packages quarterly, run tests and manual smoke.
- Consider migrating to sqflite if complex queries appear.
