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

### Reset Behavior

- Resets: `status`, `quantity`, `unit`, `isChecked` to seed defaults
- Preserves: `categoryId`, `unitOptions`, `modes`, `name`, `id`
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
