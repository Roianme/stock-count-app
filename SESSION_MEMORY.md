# Session Memory

Working memory for AI agent sessions on the Stock Count App project.
Scan this file first to recover context when starting or continuing a session.

---

## Current Phase

**Phase Two — Item & Category Management** (merged to `main`)

PRD: `stock_count_phase_two_prd.md`
Execution steps: `stock_count_phase_two_execution_steps.md`

### Completed Steps

| Step | Commit | Description |
|------|--------|-------------|
| 1 | `c770963` | Category data layer (list/add/update/delete/in-use-check) |
| 2 | `0abed29` | ItemCardWidget category resolution from CategoryRecord |
| 3 | `42f187d` | ReportWidget category grouping/headers from CategoryRecord; dessert special case removed |
| pre-4 | `2058e97` | CategoryRecord ==/hashCode; wire loadCategories() in main.dart |
| 4 | `4c9a058` | Atomic cutover A — HomeView/HomeViewModel/CategoryView/CategoryViewModel → CategoryRecord |
| 5 | `499c21d` | Atomic cutover B — unit-options read from item.unitOptions instead of legacy map |
| 6 | `b892c16` | Manage Categories screen (add/edit/delete with in-use guard) |
| 7 | `dc964fd` | Manage Items screen (add/edit/delete, category picker, unit options editor) |
| 8 | `3967b93` | Navigation wiring — both screens reachable from app drawer |
| 9 | (deferred) | Seed list trim — deferred, noted in PR |
| 10 | (verified) | Full rollout checklist passed code review |
| **11** | `9991f8e` | **Status Controls: three checkboxes (Quantity/Dropdown/Urgent) + single-active-control card with popup menu** |

### Bugs Discovered & Fixed During Phase Two

| Bug | Fix Commit | Description |
|-----|-----------|-------------|
| Reset → no items | `e984e23` | Seed items lacked `categoryId` in fresh-install path |
| Reset → all quantity | `7f076a7` | Seed items lacked `unitOptions` backfill from legacy map |
| Reset → unit selected persists | `79c45a5` | `copyWith(unit: null)` kept old value due to `??`; switched to explicit constructor |
| Reset → categoryId/unitOptions wiped | `ecc9832` | `seed.copyWith()` replaced entire item; switched to `current.copyWith()` |
| Add item → UI not updated | `6da4c9c` | `Set.from()` inferred `Set<dynamic>` → `as Set<Mode>` crashed before `_load()` ran |

### Known Technical Debt / Infos

- `DropdownButtonFormField` uses deprecated `value` param (should be `initialValue`)
- `BuildContext` across async gaps in dialog handlers (standard Flutter pattern)
- `Color.value` deprecated in favor of `.toARGB32()` (fixed in picker, pre-existing elsewhere)

---

## Architecture Decisions

### Data Flow

- **Items**: `data.items` (global mutable list) mutated in place by view models, persisted via `repository.saveItems(data.items)`
- **Categories**: `data.categories` (global mutable list) loaded once at startup, mutated in place, persisted via `repository.saveCategories(categories)`
- **UI pattern**: `ChangeNotifier` + `AnimatedBuilder` for reactive updates

### Category Resolution (Cutover A)

- Category display info resolved from `CategoryRecord` by matching `item.categoryId == category.id`
- Legacy `item.category` enum still exists but is no longer read by UI
- New items assigned to non-original categories get `Category.misc` as the legacy enum fallback

### Unit Options (Cutover B)

- `unitOptionsForItem()`/`selectedUnitOption()` read from `item.unitOptions` instead of `itemUnitOptionsById` map
- Legacy map still exists for seed data backfill; safe to remove after all installs have migrated

### Status Controls (enabledStatuses)
- Items now have `Set<ItemStatus> enabledStatuses` field controlling which status controls appear
- Three status types: `ItemStatus.quantity` (number input 0-999), `ItemStatus.dropdown` (unit options picker), `ItemStatus.urgent` (URGENT badge)
- Only one control shown at a time on the card; three-dot popup menu appears when 2+ enabled to switch between them
- Configured via three checkboxes in the Manage Items add/edit dialog
- Default: `{ItemStatus.quantity}` (backward compatible)
- Persisted via Hive field 10 with null-safe default on read

### Reset Behavior

- Resets: `status`, `quantity`, `unit`, `isChecked` to seed defaults
- Preserves: `categoryId`, `unitOptions`, `modes`, `enabledStatuses`, `name`, `id`
- Uses explicit `Item(...)` constructor (not `copyWith`) so nullable `unit` defaults to null

---

## File Map

### New Files (Phase Two)
| File | Purpose |
|------|---------|
| `lib/model/category_model.dart` | CategoryRecord model + adapter + seed helper |
| `lib/viewmodel/manage_categories_view_model.dart` | Categories CRUD view model |
| `lib/viewmodel/manage_items_view_model.dart` | Items CRUD view model |
| `lib/view/manage_categories_view.dart` | Categories management UI |
| `lib/view/manage_items_view.dart` | Items management UI |

### Modified Files (Phase Two)
| File | Key Changes |
|------|-------------|
| `lib/data/item_data.dart` | Added `categories` list; seed capture includes `categoryId`/`unitOptions` |
| `lib/data/item_repository.dart` | Added category CRUD methods to interface |
| `lib/data/platform_item_repository.dart` | Category CRUD implementation; fresh-install backfill for `categoryId`/`unitOptions` |
| `lib/data/migrations.dart` | V2→V3 migration (backfill `categoryId`/`unitOptions`) |
| `lib/view/home_view.dart` | Category resolution from CategoryRecord; navigation to manage screens |
| `lib/view/category_view.dart` | Accepts CategoryRecord; filers by `categoryId` |
| `lib/view/report_widget.dart` | Groups by CategoryRecord; dessert special case removed |
| `lib/view/widgets/item_card_widget.dart` | Category lookup via categoryId; unit options from ItemUnitOptionRecord |
| `lib/view/widgets/app_drawer.dart` | Added Manage Items/Categories menu items |
| `lib/viewmodel/home_view_model.dart` | Uses CategoryRecord throughout; category matching by `categoryId` |
| `lib/viewmodel/category_view_model.dart` | Uses CategoryRecord; filters by `categoryId` |
| `lib/main.dart` | Calls `repository.loadCategories()` at startup |

---

## Next Steps / Future Work

1. **Retire `Category` enum + `Item.category` field** — separate future phase after Phase Two has run in production long enough
2. **Trim `item_data.dart` seed list** — optional, deferred from Phase Two
3. **User accounts/roles, multi-device sync, bulk import/export** — explicitly out of scope per PRD section 3

---

## Session Recovery

When continuing work:

1. Read this file first to understand current state
2. Check `git log --oneline -10` for latest commits
3. Check `git status` for uncommitted changes
4. Read the relevant PRD section for context (`stock_count_phase_two_prd.md`)
5. Read the execution steps doc for any remaining steps (`stock_count_phase_two_execution_steps.md`)

---

## Release & Deployment Practices (2026-08-05)

- **Versioning**: semver `major.minor.patch+build` in stock_count_app/pubspec.yaml; bump + tag `v<version>` before building for prod. Current: 1.7.0+0 (bump committed with this release).
- **Environments**: staging = `stock-count-app-staging` (project # 978100062413, site exists, https://stock-count-app-staging.web.app); prod = `stock-count-app-c381c` (live build v1.6.6+8 since 2026-04-22, backed up 2026-08-05 -> C:\xampp\htdocs\stock-count-app-prod-backup-2026-08-05 + zip).
- **Backup**: `scripts\backup-live-build.ps1` - downloads live build, double-fetch verify (web.app + firebaseapp.com), zips, keeps 5. Run before every prod deploy.
- **Deploy**: `npx firebase-tools@15.25.1 deploy --only hosting --project <id> --message "..."` - never bare `firebase deploy`. Firebase CLI is NOT on PATH; use npx firebase-tools@15.25.1.
- **Log**: every deploy recorded in `DEPLOYMENTS.md` (repo root).
- **Gotchas learned**: (1) tracked `.firebase/hosting.*.cache` can be STALE vs live - verify live content directly; (2) Firebase Hosting SPA rewrite serves index.html for ANY URL with a query string - never use query-string cache busters; (3) Flutter builds are not byte-reproducible - `flutter clean` destroys the only copy unless archived.
- **Pending**: staging deploy of main (1.7.0+0); GitHub Actions staging workflow created - needs `FIREBASE_SERVICE_ACCOUNT_STOCK_COUNT_APP_STAGING` secret; push commits + tag to origin.
