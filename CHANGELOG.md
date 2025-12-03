## [1.2.0] - 2025-12-03

### Added
- Complete standalone Vaccination management system
- Protocol-based vaccination scheduling (4 predefined protocols)
- Species-aware vaccine types (Dogs & Cats)
- Certificate photo upload
- Full Romanian localization for vaccination features
- Automatic data migration for existing users
- Calendar integration for vaccinations
- Home Screen Upcoming Care shows vaccinations

### Fixed
- Protocol card visibility in empty vaccination timeline
- Date calculation for vaccination schedules
- Calendar navigation for vaccination events
- Romanian localization for new vaccinations (protocol sync)

### Changed
- Removed vaccination toggle from medication screen (now standalone)
- Improved protocol data syncing from JSON

### Technical
- Added VaccinationEvent model (Hive typeId: 30)
- Implemented automatic migration system for v1.2.0 upgrade
- Added 15+ new files for vaccination feature
- Added 25+ new Romanian localization keys
