# Database — `restaurant_package_booking`

The app uses a local **SQLite** database file named `restaurant_package_booking.db`,
created from the `restaurant_package_booking` schema defined in
`lib/data/app_database.dart` (schema **version 2**). Foreign keys are enabled
(`PRAGMA foreign_keys = ON`) so cascading deletes are enforced by the engine.

The database contains **eight** logical tables. The structure aligns with the
assignment ER diagram while keeping **app extension** columns and tables needed
by the existing UI (categories, courses, badges, ratings, etc.).

> Conventions used in the tables below:
> - **PK** = primary key
> - **FK** = foreign key (with `ON DELETE` action in parentheses)
> - **U**  = unique constraint
> - **Spec** = column/table name in the assignment logical model
> - "Length" for `TEXT` columns is application-level (SQLite stores TEXT as
>   variable-length UTF-8 — values shown are recommended maxima).

---

## Assignment spec mapping

| Assignment name | SQLite table / column | Notes |
|-----------------|----------------------|-------|
| `USERS` | `users` | `id` = `user_id`; `joined_at` = `created_at` |
| `staff_id` | `users.staff_id` | Set to `id` for admin accounts |
| `PACKAGES` | `menu_packages` | `id` = `package_id`; `image` = `image_url` |
| `guest_range_min/max` | `min_guests` / `max_guests` | Same semantics |
| `PACKAGE_FEATURES` | `package_includes` | `feature` = `feature_text`; `position` = `display_order` |
| `PACKAGE_HIGHLIGHTS` | `package_highlights` | New in v2 |
| `ADDONS` | `addons` | `price_type`: `per_guest` / `flat` |
| `RESERVATIONS` | `reservations` | `event_time` = `preferred_time` |
| `RESERVATION_ADDONS` | `reservation_addons` | `id` = `reservation_addon_id` |

### App extensions (not in assignment diagram — kept for UI)

| Table / column | Purpose |
|----------------|---------|
| `menu_packages.category` | Package filters and badges |
| `menu_packages.full_description` | Long copy on detail page |
| `menu_packages.badge` | “Most Popular”, etc. |
| `menu_packages.rating` | Star ratings on cards |
| `menu_packages.bookings` | Cached booking count |
| `package_courses` | Menu course list (admin + detail UI) |
| `users.bookings_count` | Admin user stats |
| `reservations.total_price` | Booking summary pricing |
| `addons.icon` | Emoji in add-on picker |

---

## 1. `users` (spec: **USERS**)

Application user accounts. Both guests and administrators are stored here;
the `role` column distinguishes them. Guests sign in by email; admins by
`staff_id` (mirrors `id` for admin rows).

| Field           | Type    | Length | Key | Notes                                            |
|-----------------|---------|--------|-----|--------------------------------------------------|
| id              | TEXT    | 32     | PK  | Spec: `user_id` / staff id for admins            |
| name            | TEXT    | 80     |     | Display name                                     |
| email           | TEXT    | 120    | U   | Lower-cased on lookup                            |
| staff_id        | TEXT    | 32     | U   | Nullable; set for admin accounts                 |
| password        | TEXT    | 120    |     | Plaintext for the prototype (hash in production) |
| role            | TEXT    | 8      |     | `CHECK (role IN ('user','admin'))`               |
| joined_at       | TEXT    | 10     |     | Spec: `created_at` — ISO `YYYY-MM-DD`            |
| blocked         | INTEGER | 1      |     | `0` = active, `1` = blocked, default `0`         |
| bookings_count  | INTEGER |        |     | App extension — cached reservation count         |

---

## 2. `menu_packages` (spec: **PACKAGES**)

The per-guest priced menu packages browsed in the guest catalog and managed
via the admin "Packages" tab.

| Field             | Type    | Length | Key | Notes                                       |
|-------------------|---------|--------|-----|---------------------------------------------|
| id                | TEXT    | 32     | PK  | Spec: `package_id`                          |
| user_id           | TEXT    | 32     | FK  | Spec: created by admin → `users(id)` SET NULL |
| name              | TEXT    | 120    |     |                                             |
| category          | TEXT    | 32     |     | App extension — e.g. Wedding, Corporate     |
| price_per_guest   | REAL    |        |     | USD per guest                               |
| min_guests        | INTEGER |        |     | Spec: `guest_range_min`                     |
| max_guests        | INTEGER |        |     | Spec: `guest_range_max`                     |
| description       | TEXT    | 240    |     | Short tagline                               |
| full_description  | TEXT    | 2000   |     | App extension — long marketing copy         |
| image             | TEXT    | 400    |     | Spec: `image_url`                           |
| badge             | TEXT    | 40     |     | App extension — optional badge              |
| rating            | REAL    |        |     | App extension — 0 – 5                       |
| bookings          | INTEGER |        |     | App extension — cached total bookings       |
| created_at        | TEXT    | 10     |     | ISO `YYYY-MM-DD`                            |
| updated_at        | TEXT    | 10     |     | ISO `YYYY-MM-DD`                            |

---

## 3. `package_courses` (app extension)

Ordered list of courses included in each menu package (1 package → N courses).
Not in the assignment diagram; powers the “Menu Courses” admin field and detail UI.

| Field      | Type    | Length | Key                                                    |
|------------|---------|--------|--------------------------------------------------------|
| id         | INTEGER |        | PK, AUTOINCREMENT                                      |
| package_id | TEXT    | 32     | FK → `menu_packages(id)` **ON DELETE CASCADE**         |
| course     | TEXT    | 240    |                                                        |
| position   | INTEGER |        | Display order (0-based)                                |

---

## 4. `package_includes` (spec: **PACKAGE_FEATURES**)

Ordered "what's included" list shown on the package detail screen
(1 package → N feature lines).

| Field      | Type    | Length | Key                                              |
|------------|---------|--------|--------------------------------------------------|
| id         | INTEGER |        | PK, AUTOINCREMENT — Spec: `feature_id`           |
| package_id | TEXT    | 32     | FK → `menu_packages(id)` **ON DELETE CASCADE**   |
| feature    | TEXT    | 240    | Spec: `feature_text`                             |
| position   | INTEGER |        | Spec: `display_order` (0-based)                  |

---

## 5. `package_highlights` (spec: **PACKAGE_HIGHLIGHTS**)

Titled highlights with icons for each package (1 package → N highlights).
Table exists in v2; optional in the UI — ready for future admin screens.

| Field       | Type    | Length | Key                                              |
|-------------|---------|--------|--------------------------------------------------|
| id          | INTEGER |        | PK, AUTOINCREMENT — Spec: `highlight_id`         |
| package_id  | TEXT    | 32     | FK → `menu_packages(id)` **ON DELETE CASCADE**   |
| title       | TEXT    | 120    |                                                  |
| description | TEXT    | 500    |                                                  |
| icon        | TEXT    | 16     | Emoji or icon glyph                              |
| position    | INTEGER |        | Display order (0-based)                          |

---

## 6. `addons` (spec: **ADDONS**)

Service add-ons selectable during booking (e.g. floral arrangements, jazz quartet).
Each add-on is priced either `per_guest` or `flat`.

| Field        | Type | Length | Key | Notes                                                   |
|--------------|------|--------|-----|---------------------------------------------------------|
| id           | TEXT | 32     | PK  | Spec: `addon_id`                                        |
| name         | TEXT | 120    |     |                                                         |
| description  | TEXT | 240    |     |                                                         |
| price        | REAL |        |     | USD                                                     |
| price_type   | TEXT | 9      |     | `CHECK (price_type IN ('per_guest','flat'))`            |
| icon         | TEXT | 16     | App extension — emoji glyph used in the UI              |
| is_active    | INTEGER | 1   |     | Spec: `BOOLEAN` — `1` = available, default `1`          |
| created_at   | TEXT | 10     |     | ISO `YYYY-MM-DD`                                        |

---

## 7. `reservations` (spec: **RESERVATIONS**)

Customer bookings. `total_price = base_price + addons_price` and
`base_price = guests × package.price_per_guest`.

| Field          | Type    | Length | Key                                                          |
|----------------|---------|--------|--------------------------------------------------------------|
| id             | TEXT    | 32     | PK — Spec: `reservation_id`                                  |
| user_id        | TEXT    | 32     | FK → `users(id)` **ON DELETE SET NULL** (nullable)           |
| package_id     | TEXT    | 32     | FK → `menu_packages(id)` **ON DELETE RESTRICT**              |
| event_date     | TEXT    | 10     | ISO `YYYY-MM-DD`                                             |
| event_time     | TEXT    | 10     | Spec: `preferred_time` — e.g. `19:00` or `7:00 PM`           |
| guests         | INTEGER |        |                                                              |
| base_price     | REAL    |        |                                                              |
| addons_price   | REAL    |        |                                                              |
| total_price    | REAL    |        | App extension — `base_price + addons_price`                  |
| status         | TEXT    | 10     | `CHECK (status IN ('confirmed','pending','cancelled'))`      |
| booking_ref    | TEXT    | 20     | Customer-facing reference, e.g. `VEN-2026-117`               |
| balance_paid   | REAL    |        | Spec field — default `0`                                     |
| created_at     | TEXT    | 10     | ISO `YYYY-MM-DD`                                             |
| updated_at     | TEXT    | 10     | ISO `YYYY-MM-DD`                                             |

Indexes:

- `idx_reservations_user`    — `reservations(user_id)`
- `idx_reservations_package` — `reservations(package_id)`
- `idx_reservations_date`    — `reservations(event_date)`
- `idx_packages_user`        — `menu_packages(user_id)`

---

## 8. `reservation_addons` (spec: **RESERVATION_ADDONS**)

Many-to-many junction between reservations and add-ons. A reservation may
include zero or more add-ons; an add-on may appear on many reservations.
`price_at_time` snapshots the charged amount at booking time.

| Field            | Type    | Length | Key                                                         |
|------------------|---------|--------|-------------------------------------------------------------|
| id               | TEXT    | 40     | PK — Spec: `reservation_addon_id`                           |
| reservation_id   | TEXT    | 32     | FK → `reservations(id)` **ON DELETE CASCADE**               |
| addon_id         | TEXT    | 32     | FK → `addons(id)` **ON DELETE CASCADE**                     |
| quantity         | INTEGER |        | Default `1`                                                 |
| price_at_time    | REAL    |        | Snapshot price at booking (flat or `per_guest × guests`)    |

`UNIQUE (reservation_id, addon_id)` prevents attaching the same add-on twice.

---

## Entity relationships

```
users 1 ────< menu_packages (created by admin)
users 1 ────< reservations >──── N addons
              │                         │
              │                         └── via reservation_addons
              └── N menu_packages 1 ──< package_courses   (app extension)
                                    ──< package_includes  (spec: PACKAGE_FEATURES)
                                    ──< package_highlights (spec)
```

- A **user** has many **reservations**; a reservation belongs to at most
  one user (`user_id` is `SET NULL` on user delete).
- An **admin user** may have created many **menu_packages** (`user_id` FK).
- A **menu_package** has many **reservations**; `ON DELETE RESTRICT`
  prevents deleting a package with live bookings.
- A **menu_package** has many **courses**, **includes**, and **highlights**;
  all cascade on delete.
- An **add-on** is attached to a **reservation** through
  `reservation_addons` (N:M) with quantity and price snapshot.

---

## Schema migration (v1 → v2)

Existing installs are upgraded automatically on next launch:

1. `users.staff_id` added; backfilled for admin rows.
2. `menu_packages.user_id`, `created_at`, `updated_at` added; backfilled.
3. `package_highlights` table created.
4. `addons.is_active`, `created_at` added.
5. `reservations.balance_paid`, `updated_at` added.
6. `reservation_addons` recreated with `id`, `quantity`, `price_at_time`.

No data is lost; all existing packages, bookings, and users are preserved.

---

## Seeding

When the database file does not yet exist, the schema is created and seeded
with:

- 5 user accounts (3 guests, 2 admins) plus a stable demo admin
  (`id = 12345`, `staff_id = 12345`) and demo guest (`email = demo@venera.com`).
- 6 menu packages with courses and includes, owned by the demo admin.
- 6 add-ons (floral, jazz quartet, photography, cake, open bar, menu cards).
- 3 example reservations spanning confirmed and cancelled statuses.

---

## Third-party packages used

| Package              | Area     | Usage in this project                                    |
|----------------------|----------|----------------------------------------------------------|
| `sqflite`            | Database | SQLite driver — the entire schema above                  |
| `path`               | Utility  | Builds the on-device path to the SQLite file             |
| `shared_preferences` | Caching  | Persists the signed-in user id across app restarts       |
| `google_fonts`       | UI       | Serves the Cormorant Garamond typeface used in the theme |
