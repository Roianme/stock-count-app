# Changelog

All notable changes to this project are documented here.
Format: `[version] - date` (semver: `major.minor.patch+build`).

## [1.7.1+0] - 2026-08-08
### Fixed
- **Persistence bug**: deleted seed items were silently re-added on app restart
  due to upsert logic not distinguishing user-deleted items from new seed
  additions. Now tracked via `deleted_seed_ids` in `meta_box`.
- **ViewModel lifecycle**: added `_disposed` guard to prevent `notifyListeners()`
  after disposal during async operations (`resetAllToDefaults`, `exportAndClear`).
- **Restore error**: `late final` to `late` in `_HomePageState.viewModel`
  to allow reassignment after data restore.

### Added
- **Data Backup & Restore**: users can download full JSON backup (items +
  categories + metadata) and restore it later -- protects against browser
  cache clearing which wipes IndexedDB/Hive.
- **ID remapping v4 migration**: user-created item IDs remapped to 10000+
  range to prevent collisions with future seed items (seed: 1-9999, user: 10000+).
- **Stress tests**: 5 automated tests (multi-delete, bulk add 20, invalid JSON,
  rapid restore cycle, export idempotency).

### Changed
- `Item._nextId` raised from `1` to `10000` to reserve ID range for seed items.

## [1.7.0+0] - 2026-08-05
### Added
- Report preview: quantity value `0` now renders in red (non-zero stays blue)
### Changed
- Report urgent-column cleanup, portrait urgent section, larger category header
- Release & deployment tooling: backup script, deploy log, changelog (see AGENTS.md)

## [1.6.6+8] - 2026-04-22
- Last production release before 1.7.0+0 (live build backed up 2026-08-05)