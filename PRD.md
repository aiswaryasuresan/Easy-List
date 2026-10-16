# PRD — Shopping List (Flutter + GetX)

**Version:** 1.0
**Status:** Approved for development
**Platform:** Android
**Stack:** Flutter, GetX (state management, routing, dependency injection), local persistence (no backend)
**Tagline:** *Remember. Buy. Done.*

---

## 1. Purpose & Vision

A simple, minimal shopping list app. When a user notices household items (sugar, salt, soap, toothpaste, etc.) running low, they add them to the list in seconds. While shopping, they check items off as purchased.

**Core principle:** Open the app, add an item in seconds, check it off when purchased.

The app must be extremely easy to use, fast, lightweight, and fully offline. No accounts, no cloud sync, no ads.

---

## 2. Technology & Architecture

| Concern | Decision |
|---|---|
| Framework | Flutter (Dart) |
| State management / DI / routing | GetX (`GetMaterialApp`, `GetView`/`GetWidget`, `Bindings`, `Get.put`/`lazyPut`) |
| Local database | **GetStorage** (primary choice — lightweight, synchronous-keyed, idiomatic with GetX). Alternative: `sqflite` if relational queries are later needed. |
| Architecture | MVVM: View (Flutter widgets) → Controller (GetX `GetxController`) → Repository → Local DB |
| Reactivity | `RxList` / `Rx` observables, or a plain repository stream exposed through controllers; UI updates immediately after persistence |
| Network | None required; app is fully offline |
| Auth | None |
| Language | English only |

### 2.1 Suggested project structure

```
lib/
  main.dart                      # GetMaterialApp, initial binding, splash route
  app/
    data/
      models/shopping_item.dart  # entity + JSON serialization
      repositories/cart_repository.dart   # GetStorage read/write, CRUD
    routes/
      app_pages.dart / app_routes.dart
    modules/
      splash/  (view, controller, binding)
      home/    (view, controller, binding)
      item_form/ (add & edit bottom sheet, controller)
    theme/app_theme.dart         # colors, typography, shape
  assets/                        # splash illustration, product icons/emojis
```

### 2.2 Persistence rules

- All state lives in the local DB; **never** in-memory only.
- Data must survive: app close, removal from recents, device restart.
- Write operations run off the UI isolate where feasible (GetStorage writes are fast; keep list small; avoid blocking frames).
- Whitelist of stored keys; no unnecessary Android permissions.

---

## 3. Design System

Clean, minimal, modern, Material 3 styling.

- **Background:** white / off-white (`#F7F8F5`-ish, matching storyboard)
- **Primary accent:** green (`#1E7A3C` family) — buttons, checkboxes, active chips
- **Destructive:** red (`#E53935`) — delete, clear actions
- **Text:** dark, high contrast; secondary gray for subtitles
- **Components:** rounded buttons and input fields, card-style list rows, subtle dividers/shadows, comfortable spacing and ≥48dp touch targets
- **Item icons:** each product row shows a small product icon/emoji (rice bowl, salt shaker, ginger, soap, toothpaste…). Auto-assign the best-matching icon from the item name; fall back to a generic grocery icon.
- **Bottom sheets** are the primary modal pattern (add/edit form, item options, confirmations).
- Responsive layout for different Android screen sizes; long product names must wrap/ellipsize without breaking the row layout.

Avoid: dashboards, heavy animation, extra screens, clutter.

---

## 4. Screens (per storyboard)

### Screen 1 — Splash
- App illustration (shopping basket), title **Shopping List**, tagline **"Remember. Buy. Done."**
- Optional and fast: auto-navigate to Home after ~1.5–2s (or immediately if data is cached). Must not delay access to the list.

### Screen 2 — Main Screen (Home)
- Header: **Shopping List** + overflow menu (⋮) for app-level actions (e.g., Clear Purchased Items).
- Subtitle: live remaining count — "5 items to buy" (singular "1 item to buy" when applicable; "0 items to buy" handled by empty state).
- Vertical list of **pending** items. Each row:
  - Checkbox (unchecked)
  - Product icon
  - Item name (bold) + "quantity unit" subtitle (e.g., "2 kg"); name only when no quantity
  - Overflow menu (⋮) → item options (Screen 7)
- Prominent green **+ Add Item** button pinned below the list / near bottom.
- Purchased items live in a collapsible **Purchased (n)** section below pending items (Screen 8). Pending always appears first.

### Screen 10 — Empty State (variant of Main)
- When there are no items at all: grayed basket icon, heading **"Your list is empty"**, body "Add items whenever you remember something to buy.", and the **+ Add Item** button.

### Screen 3 — Add Item (bottom sheet)
- Title **Add Item**, close (×) affordance.
- Fields:
  1. **Item name** — required text input
  2. **Quantity (optional)** — numeric input
  3. **Unit (optional)** — dropdown **and** selectable quick-chips: `kg · g · L · ml · pack · piece · box` (extendable with `bottle`, `packet`)
- Green **Save** button.
- On save: dismiss sheet, item appears immediately in the list, fields cleared for next use.

### Screen 6 — Edit Item (bottom sheet)
- Same form as Add, prefilled with current values.
- Actions: **Delete** (red, outlined) · **Cancel** · **Save** (green).
- Save updates the existing item (no duplicate).

### Screen 7 — Item Options Menu (bottom sheet from row ⋮)
- Item preview (icon, name, quantity).
- **Edit item** (pencil)
- **Duplicate item** (copy icon) — adds a copy of the item to the list
- **Delete item** (red trash)
- **Cancel**

### Screen 5 — Purchased Marked (state of Main)
- Tapping a checkbox marks the item purchased: green filled check, crossed-out name, item moves into the **Purchased (n)** collapsible section.
- Remaining count updates (e.g., "4 items to buy").
- Unchecking returns the item to pending.
- Purchased status persists across app restarts.

### Screen 8 — Purchased Section Expanded
- Section header **Purchased (n)** with expand/collapse chevron.
- Purchased rows keep checkbox, icon, struck-through text, and their own ⋮ menu.
- Red-tinted **🗑 Clear purchased items** button at the bottom of the section.

### Screen 9 — Clear Purchased Confirmation (dialog / sheet)
- Red trash icon, title **"Clear purchased items?"**, body "This will remove all purchased items from your list."
- Buttons: **Cancel** · **Clear** (red).
- Only purchased items are removed; pending items untouched.
- Action is hidden/disabled when there are no purchased items.

---

## 5. Data Model

Single shopping list, multiple items (no multi-list support in v1).

```dart
class ShoppingItem {
  final int id;          // unique, auto-increment
  final String name;     // required, trimmed
  final double? quantity;   // optional, positive, decimals allowed (e.g., 0.5)
  final String? unit;    // optional: kg, g, L, ml, pack, piece, box, bottle, packet
  bool isPurchased;      // default false
  int sortOrder;         // stable display order
  final int createdAt;   // epoch ms
}
```

- Stored as a JSON-encoded list under one GetStorage key (e.g., `shopping_items`).
- Repository exposes: `getAll`, `add`, `update`, `delete`, `togglePurchased`, `duplicate`, `clearPurchased`.
- Display label rule: `"Sugar — 2 kg"` when quantity+unit present; `"Ginger — 500 g"`; name only when no quantity (`"Soap"`).

---

## 6. Functional Requirements

### 6.1 Add item
- **FR-1** Item name is required; empty/whitespace-only names are rejected (inline validation, Save disabled or error message).
- **FR-2** Names are trimmed (leading/trailing/multiple internal spaces collapsed).
- **FR-3** Quantity and unit are both optional and independent.
- **FR-4** Quantity must be a positive number when provided; decimals allowed (0.5 kg).
- **FR-5** Unit may be chosen via dropdown or chips; never forced.
- **FR-6** After save: sheet closes, item appears at once, form fields reset.

### 6.2 Edit item
- **FR-7** Edit opens the same form prefilled; saving mutates the existing item in place.
- **FR-8** Same validation rules as add.

### 6.3 Delete & duplicate
- **FR-9** Delete (from ⋮ menu or edit sheet) permanently removes the item. A confirmation is shown for delete from the options menu (small confirm or direct delete + undo is acceptable; storyboard shows delete as a red menu action).
- **FR-10** Duplicate creates a new item with identical name/quantity/unit, un-purchased, inserted after the source.

### 6.4 Purchased status
- **FR-11** Checkbox toggles purchased; visual: green check + strikethrough.
- **FR-12** Pending items always render before purchased items.
- **FR-13** Purchased items grouped in collapsible "Purchased (n)" section; collapsed by default is acceptable, state remembered per session.
- **FR-14** Remaining count = number of pending items; updates live.
- **FR-15** Unchecking returns an item to pending.

### 6.6 Clear purchased
- **FR-17** "Clear purchased items" requires confirmation (Screen 9) and removes only purchased items.
- **FR-18** Hidden or disabled when no purchased items exist.

### 6.7 Persistence
- **FR-19** All CRUD + toggle results persist immediately to GetStorage.
- **FR-20** Data survives app close, recents-kill, and device reboot.
- **FR-21** Fully offline; zero network calls.

---

## 7. User Flow

1. Open app → (brief splash) → saved list appears immediately.
2. Tap **Add Item** → enter name (+optional quantity/unit) → Save → item in list.
3. Repeat whenever something is remembered.
4. While shopping → tap checkbox → item moves to Purchased section; count decreases.
5. Optionally expand Purchased → **Clear purchased items** → confirm.
6. Any time: ⋮ → Edit / Duplicate / Delete.
7. Close and reopen → everything intact, including purchased state.

---

## 8. Explicitly Out of Scope (v1)

Prices/budget tracking · multiple lists · accounts/auth · cloud sync or sharing · barcode scanning · AI recommendations · product catalogs/e-commerce · notifications/reminders · ads/IAP · categories/inventory management.

---

## 9. Quality Requirements (NFRs)

- Cold start to interactive list < ~1s (splash must not gate access).
- Adding an item: ≤ 3 interactions (tap Add, type name, Save).
- UI reflects every DB change immediately.
- No data loss on navigation, process kill, or restart.
- Keyboard and inputs behave correctly (numeric keyboard for quantity; sheet resizes above keyboard).
- Long names do not break layout.
- Easy tap targets (checkbox, ⋮, buttons ≥48dp).
- DB operations off the main thread where feasible.
- Graceful empty state and invalid-input handling.
- No unnecessary Android permissions.

---

## 10. Definition of Done / Acceptance Criteria

A build is done when a user can:

1. Add **Sugar** with quantity **2 kg** → row shows "Sugar / 2 kg".
2. Add **Soap** with quantity **5 packs** → row shows "Soap / 5 packs".
3. Add an item with **no quantity** → row shows name only.
4. Edit an item's name, quantity, and unit → list updates in place, no duplicate.
5. Delete an unwanted item → gone permanently.
6. Duplicate an item → second identical row appears.
7. Mark an item purchased → green check, strikethrough, moves to "Purchased (n)", count decreases.
8. Unmark a purchased item → returns to pending.
9. Clear purchased items → only purchased removed; pending untouched.
10. Force-close and reopen the app → list and purchased states intact.
11. Use every feature with airplane mode on.
12. Match the 10-screen storyboard visually (theme, bottom sheets, chips, sections, empty state).
