# Logical Tables — Venera Private Dining

Database: `restaurant_package_booking` · Schema version **2**  
Implementation: SQLite (`lib/data/app_database.dart`)

> **Note:** Logical types below follow the assignment model (`UUID`, `ENUM`, `BOOLEAN`, etc.).
> The running app stores these as SQLite `TEXT`, `REAL`, and `INTEGER` (0/1 for booleans).
> Columns marked **(ext)** are app extensions beyond the base assignment spec.

---

## USERS

Application user accounts. Guests sign in by email; admins sign in by `staff_id`.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| user_id | UUID | PK, NOT NULL | Unique user identifier (`users.id`) |
| name | VARCHAR(255) | NOT NULL | Full name |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Email (guest login) |
| staff_id | VARCHAR(50) | UNIQUE, NULLABLE | Staff ID (admin only) |
| password | VARCHAR(255) | NOT NULL | Password (plaintext in prototype) |
| role | ENUM | NOT NULL, DEFAULT 'user' | `user` / `admin` |
| blocked | BOOLEAN | NOT NULL, DEFAULT FALSE | Account status |
| created_at | TIMESTAMP | NOT NULL | Account created (`users.joined_at`, ISO date) |
| bookings_count | INTEGER | NOT NULL, DEFAULT 0 | **(ext)** Cached reservation count |

---

## PACKAGES

Per-guest dining packages created by admins and browsed by guests.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| package_id | UUID | PK, NOT NULL | Unique package ID (`menu_packages.id`) |
| user_id | UUID | FK → USERS(user_id), NULLABLE | Created by admin |
| name | VARCHAR(255) | NOT NULL | Package name |
| category | VARCHAR(32) | NOT NULL | **(ext)** e.g. Wedding, Corporate, Gala |
| description | TEXT | NOT NULL | Short tagline for cards |
| full_description | TEXT | NOT NULL | **(ext)** Long copy on detail page |
| price_per_guest | DECIMAL(10,2) | NOT NULL | Price per guest (USD) |
| guest_range_min | INTEGER | NOT NULL | Minimum guests (`min_guests`) |
| guest_range_max | INTEGER | NOT NULL | Maximum guests (`max_guests`) |
| image_url | VARCHAR(500) | NOT NULL | Image link (`image`) |
| badge | VARCHAR(40) | NULLABLE | **(ext)** e.g. Popular, New |
| rating | DECIMAL(2,1) | NOT NULL, DEFAULT 0 | **(ext)** Star rating 0–5 |
| bookings | INTEGER | NOT NULL, DEFAULT 0 | **(ext)** Cached total bookings |
| created_at | TIMESTAMP | NOT NULL | Created time |
| updated_at | TIMESTAMP | NOT NULL | Last updated time |

---

## PACKAGE FEATURES

Ordered “what’s included” lines for each package (1 package → N features).

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| feature_id | UUID | PK, NOT NULL | Feature ID (`package_includes.id`, autoincrement) |
| package_id | UUID | FK → PACKAGES(package_id), NOT NULL | Related package |
| feature_text | VARCHAR(500) | NOT NULL | Feature description (`feature`) |
| display_order | INTEGER | NOT NULL, DEFAULT 0 | Display order (`position`, 0-based) |

---

## PACKAGE HIGHLIGHTS

Titled highlights with icons for each package (1 package → N highlights).

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| highlight_id | UUID | PK, NOT NULL | Highlight ID (`package_highlights.id`, autoincrement) |
| package_id | UUID | FK → PACKAGES(package_id), NOT NULL | Related package |
| title | VARCHAR(255) | NOT NULL | Highlight title |
| description | TEXT | NOT NULL | Highlight details |
| icon | VARCHAR(50) | NOT NULL | Icon or emoji glyph |
| display_order | INTEGER | NOT NULL, DEFAULT 0 | **(ext)** Display order (`position`) |

---

## PACKAGE COURSES *(app extension)*

Ordered menu courses for each package. Powers the admin “Menu Courses” field and package detail UI.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| course_id | UUID | PK, NOT NULL | Course row ID (`package_courses.id`, autoincrement) |
| package_id | UUID | FK → PACKAGES(package_id), NOT NULL | Related package |
| course | VARCHAR(500) | NOT NULL | Course name / description |
| display_order | INTEGER | NOT NULL, DEFAULT 0 | Display order (`position`, 0-based) |

---

## ADDONS

Optional services selectable during booking (e.g. floral arrangement, jazz quartet).

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| addon_id | UUID | PK, NOT NULL | Add-on ID (`addons.id`) |
| name | VARCHAR(255) | NOT NULL | Add-on name |
| description | TEXT | NOT NULL | Description |
| price | DECIMAL(10,2) | NOT NULL | Price (USD) |
| price_type | ENUM | NOT NULL | `flat` / `per_guest` |
| icon | VARCHAR(50) | NOT NULL | **(ext)** Emoji shown in booking UI |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | Availability |
| created_at | TIMESTAMP | NOT NULL | Created time |

---

## RESERVATIONS

Customer bookings for a package on a given date and time.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| reservation_id | UUID | PK, NOT NULL | Reservation ID (`reservations.id`) |
| user_id | UUID | FK → USERS(user_id), NULLABLE | Booking user |
| package_id | UUID | FK → PACKAGES(package_id), NOT NULL | Selected package |
| booking_ref | VARCHAR(50) | NOT NULL | Booking reference, e.g. `VEN-2026-117` |
| event_date | DATE | NOT NULL | Event date (ISO `YYYY-MM-DD`) |
| preferred_time | VARCHAR(20) | NOT NULL | Time (`event_time`) |
| guests | INTEGER | NOT NULL | Number of guests |
| base_price | DECIMAL(10,2) | NOT NULL | Package base cost |
| addons_price | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Add-ons total |
| total_price | DECIMAL(10,2) | NOT NULL | **(ext)** `base_price + addons_price` |
| status | ENUM | NOT NULL | `confirmed` / `pending` / `cancelled` |
| balance_paid | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Payment balance |
| created_at | TIMESTAMP | NOT NULL | Created timestamp |
| updated_at | TIMESTAMP | NOT NULL | Updated timestamp |

**Foreign-key actions:** `user_id` → SET NULL on user delete; `package_id` → RESTRICT on package delete.

---

## RESERVATION_ADDONS

Junction table linking reservations to add-ons (N:M). Stores quantity and a price snapshot at booking time.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| reservation_addon_id | UUID | PK, NOT NULL | Row ID (`reservation_addons.id`) |
| reservation_id | UUID | FK → RESERVATIONS(reservation_id), NOT NULL | Parent reservation |
| addon_id | UUID | FK → ADDONS(addon_id), NOT NULL | Selected add-on |
| quantity | INTEGER | NOT NULL, DEFAULT 1 | Quantity |
| price_at_time | DECIMAL(10,2) | NOT NULL | Snapshot price at booking |

**Unique constraint:** `(reservation_id, addon_id)` — same add-on cannot be attached twice.

---

## Entity relationships

```
USERS 1 ────< PACKAGES                    (user_id, created by admin)
USERS 1 ────< RESERVATIONS                (user_id)
PACKAGES 1 ──< PACKAGE_FEATURES           (package_id)
PACKAGES 1 ──< PACKAGE_HIGHLIGHTS        (package_id)
PACKAGES 1 ──< PACKAGE_COURSES (ext)     (package_id)
PACKAGES 1 ────< RESERVATIONS             (package_id)
RESERVATIONS 1 ──< RESERVATION_ADDONS     (reservation_id)
ADDONS 1 ────────< RESERVATION_ADDONS     (addon_id)
```

---

## SQLite table name reference

| Logical name | SQLite table |
|--------------|--------------|
| USERS | `users` |
| PACKAGES | `menu_packages` |
| PACKAGE_FEATURES | `package_includes` |
| PACKAGE_HIGHLIGHTS | `package_highlights` |
| PACKAGE_COURSES | `package_courses` |
| ADDONS | `addons` |
| RESERVATIONS | `reservations` |
| RESERVATION_ADDONS | `reservation_addons` |
