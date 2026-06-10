// Local SQLite database for the Venera Private Dining app.
//
// Database name: `restaurant_package_booking` (per assignment spec).
//
// Logical tables — full schema documented in `DATABASE_SCHEMA.md`:
//   1. users                 – application user accounts (guests + admins)
//   2. menu_packages         – per-guest priced menu packages (spec: PACKAGES)
//   3. package_courses       – ordered courses (app extension)
//   4. package_includes      – ordered features (spec: PACKAGE_FEATURES)
//   5. package_highlights    – titled highlights with icons (spec)
//   6. addons                – optional service add-ons
//   7. reservations          – customer bookings
//   8. reservation_addons    – junction (N:M) between reservations and addons
//
// All foreign keys are enforced via `PRAGMA foreign_keys = ON`.

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'packages_data.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String dbFileName = 'restaurant_package_booking.db';
  static const String defaultAdminId = '12345';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, dbFileName);
    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
      onUpgrade: _onUpgrade,
      onOpen: _heal,
    );
  }

  String _today() => DateTime.now().toIso8601String().split('T').first;

  String _reservationAddonId(String reservationId, String addonId) =>
      'ra_${reservationId}_$addonId';

  Future<double> _addonSnapshotPrice(
    DatabaseExecutor txn,
    String addonId,
    int guests,
  ) async {
    final rows = await txn.query(
      'addons',
      where: 'id = ?',
      whereArgs: [addonId],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    final price = (rows.first['price'] as num).toDouble();
    final priceType = rows.first['price_type'] as String;
    if (priceType == 'flat') return price;
    return price * guests;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _migrateToV2(db);
  }

  /// Upgrades v1 installs in place without losing data.
  Future<void> _migrateToV2(Database db) async {
    final today = _today();

    await db.execute('ALTER TABLE users ADD COLUMN staff_id TEXT');
    await db.execute(
      "UPDATE users SET staff_id = id WHERE role = 'admin' AND staff_id IS NULL",
    );

    await db.execute('ALTER TABLE menu_packages ADD COLUMN user_id TEXT');
    await db.execute('ALTER TABLE menu_packages ADD COLUMN created_at TEXT');
    await db.execute('ALTER TABLE menu_packages ADD COLUMN updated_at TEXT');
    await db.execute(
      "UPDATE menu_packages SET user_id = '$defaultAdminId', "
      "created_at = '$today', updated_at = '$today' "
      'WHERE user_id IS NULL',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS package_highlights (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id  TEXT    NOT NULL,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        icon        TEXT    NOT NULL DEFAULT '✦',
        position    INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (package_id) REFERENCES menu_packages(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'ALTER TABLE addons ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
    await db.execute('ALTER TABLE addons ADD COLUMN created_at TEXT');
    await db.execute(
      "UPDATE addons SET created_at = '$today' WHERE created_at IS NULL",
    );

    await db.execute(
        'ALTER TABLE reservations ADD COLUMN balance_paid REAL NOT NULL DEFAULT 0');
    await db.execute('ALTER TABLE reservations ADD COLUMN updated_at TEXT');
    await db.execute(
      'UPDATE reservations SET updated_at = created_at WHERE updated_at IS NULL',
    );

    final columns =
        await db.rawQuery('PRAGMA table_info(reservation_addons)');
    final hasId = columns.any((c) => c['name'] == 'id');
    if (!hasId) {
      await db.execute('''
        CREATE TABLE reservation_addons_new (
          id               TEXT    PRIMARY KEY,
          reservation_id   TEXT    NOT NULL,
          addon_id         TEXT    NOT NULL,
          quantity         INTEGER NOT NULL DEFAULT 1,
          price_at_time    REAL    NOT NULL DEFAULT 0,
          UNIQUE (reservation_id, addon_id),
          FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE,
          FOREIGN KEY (addon_id)       REFERENCES addons(id)       ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        INSERT INTO reservation_addons_new (id, reservation_id, addon_id, quantity, price_at_time)
        SELECT
          'ra_' || reservation_id || '_' || addon_id,
          reservation_id,
          addon_id,
          1,
          COALESCE((SELECT price FROM addons WHERE addons.id = addon_id), 0)
        FROM reservation_addons
      ''');
      await db.execute('DROP TABLE reservation_addons');
      await db.execute(
          'ALTER TABLE reservation_addons_new RENAME TO reservation_addons');
    }
  }

  /// Idempotent post-open cleanup for installs seeded before user-list edits.
  /// Safe to call on every launch — each statement is a no-op when there's
  /// nothing to remove.
  Future<void> _heal(Database db) async {
    await db.delete(
      'users',
      where: 'id = ? AND email = ?',
      whereArgs: ['u4', 'alex@venera.com'],
    );
    await db.update(
      'reservations',
      {'user_id': 'u-demo'},
      where: 'id IN (?, ?, ?) AND user_id IS NULL',
      whereArgs: ['res1', 'res2', 'res3'],
    );
    await db.execute(
      "UPDATE users SET staff_id = id WHERE role = 'admin' AND staff_id IS NULL",
    );
    final today = _today();
    await db.execute(
      "UPDATE menu_packages SET user_id = '$defaultAdminId', "
      "created_at = COALESCE(created_at, '$today'), "
      "updated_at = COALESCE(updated_at, '$today') "
      'WHERE user_id IS NULL',
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE users (
        id              TEXT    PRIMARY KEY,
        name            TEXT    NOT NULL,
        email           TEXT    NOT NULL UNIQUE,
        staff_id        TEXT    UNIQUE,
        password        TEXT    NOT NULL,
        role            TEXT    NOT NULL CHECK (role IN ('user','admin')),
        joined_at       TEXT    NOT NULL,
        blocked         INTEGER NOT NULL DEFAULT 0,
        bookings_count  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE menu_packages (
        id                TEXT    PRIMARY KEY,
        user_id           TEXT,
        name              TEXT    NOT NULL,
        category          TEXT    NOT NULL,
        price_per_guest   REAL    NOT NULL,
        min_guests        INTEGER NOT NULL,
        max_guests        INTEGER NOT NULL,
        description       TEXT    NOT NULL,
        full_description  TEXT    NOT NULL,
        image             TEXT    NOT NULL,
        badge             TEXT,
        rating            REAL    NOT NULL DEFAULT 0,
        bookings          INTEGER NOT NULL DEFAULT 0,
        created_at        TEXT    NOT NULL,
        updated_at        TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE package_courses (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id  TEXT    NOT NULL,
        course      TEXT    NOT NULL,
        position    INTEGER NOT NULL,
        FOREIGN KEY (package_id) REFERENCES menu_packages(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE package_includes (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id  TEXT    NOT NULL,
        feature     TEXT    NOT NULL,
        position    INTEGER NOT NULL,
        FOREIGN KEY (package_id) REFERENCES menu_packages(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE package_highlights (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id  TEXT    NOT NULL,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        icon        TEXT    NOT NULL DEFAULT '✦',
        position    INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (package_id) REFERENCES menu_packages(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE addons (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        description TEXT NOT NULL,
        price       REAL NOT NULL,
        price_type  TEXT NOT NULL CHECK (price_type IN ('per_guest','flat')),
        icon        TEXT NOT NULL,
        is_active   INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE reservations (
        id             TEXT    PRIMARY KEY,
        user_id        TEXT,
        package_id     TEXT    NOT NULL,
        event_date     TEXT    NOT NULL,
        event_time     TEXT    NOT NULL,
        guests         INTEGER NOT NULL,
        base_price     REAL    NOT NULL,
        addons_price   REAL    NOT NULL,
        total_price    REAL    NOT NULL,
        status         TEXT    NOT NULL CHECK (status IN ('confirmed','pending','cancelled')),
        booking_ref    TEXT    NOT NULL,
        balance_paid   REAL    NOT NULL DEFAULT 0,
        created_at     TEXT    NOT NULL,
        updated_at     TEXT    NOT NULL,
        FOREIGN KEY (user_id)    REFERENCES users(id)         ON DELETE SET NULL,
        FOREIGN KEY (package_id) REFERENCES menu_packages(id) ON DELETE RESTRICT
      )
    ''');

    batch.execute('''
      CREATE TABLE reservation_addons (
        id               TEXT    PRIMARY KEY,
        reservation_id   TEXT    NOT NULL,
        addon_id         TEXT    NOT NULL,
        quantity         INTEGER NOT NULL DEFAULT 1,
        price_at_time    REAL    NOT NULL DEFAULT 0,
        UNIQUE (reservation_id, addon_id),
        FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE,
        FOREIGN KEY (addon_id)       REFERENCES addons(id)       ON DELETE CASCADE
      )
    ''');

    batch.execute(
        'CREATE INDEX idx_reservations_user ON reservations(user_id)');
    batch.execute(
        'CREATE INDEX idx_reservations_package ON reservations(package_id)');
    batch.execute(
        'CREATE INDEX idx_reservations_date ON reservations(event_date)');
    batch.execute(
        'CREATE INDEX idx_packages_user ON menu_packages(user_id)');

    await batch.commit(noResult: true);
    await _seed(db);
  }

  // -------------------------------------------------------------------------
  // Seeding
  // -------------------------------------------------------------------------

  Future<void> _seed(Database db) async {
    final batch = db.batch();
    final today = _today();

    for (final u in mockUsers) {
      batch.insert('users', {
        'id': u.id,
        'name': u.name,
        'email': u.email,
        'staff_id': u.role == 'admin' ? u.id : null,
        'password': u.role == 'admin' ? 'admin123' : 'demo1234',
        'role': u.role,
        'joined_at': u.joinedAt,
        'blocked': (u.blocked ?? false) ? 1 : 0,
        'bookings_count': u.bookings,
      });
    }
    batch.insert('users', {
      'id': defaultAdminId,
      'name': 'Alexander Crane',
      'email': 'admin@venera.com',
      'staff_id': defaultAdminId,
      'password': 'admin123',
      'role': 'admin',
      'joined_at': '2025-01-01',
      'blocked': 0,
      'bookings_count': 0,
    });
    batch.insert('users', {
      'id': 'u-demo',
      'name': 'Eleanor Whitmore',
      'email': 'demo@venera.com',
      'password': 'demo1234',
      'role': 'user',
      'joined_at': '2025-11-12',
      'blocked': 0,
      'bookings_count': 0,
    });

    for (final a in addOns) {
      batch.insert('addons', {
        'id': a.id,
        'name': a.name,
        'description': a.description,
        'price': a.price,
        'price_type': a.priceType,
        'icon': a.icon,
        'is_active': 1,
        'created_at': today,
      });
    }

    for (final pkg in initialMenuPackages) {
      batch.insert('menu_packages', {
        ..._packageToRow(pkg),
        'user_id': defaultAdminId,
        'created_at': today,
        'updated_at': today,
      });
      for (var i = 0; i < pkg.courses.length; i++) {
        batch.insert('package_courses', {
          'package_id': pkg.id,
          'course': pkg.courses[i],
          'position': i,
        });
      }
      for (var i = 0; i < pkg.includes.length; i++) {
        batch.insert('package_includes', {
          'package_id': pkg.id,
          'feature': pkg.includes[i],
          'position': i,
        });
      }
    }

    for (final r in mockReservations) {
      batch.insert('reservations', {
        ..._reservationToRow(r),
        'balance_paid': 0,
        'updated_at': r.createdAt,
      });
      for (final aid in r.addons) {
        AddOn? ao;
        for (final a in addOns) {
          if (a.id == aid) {
            ao = a;
            break;
          }
        }
        final unitPrice = ao == null
            ? 0.0
            : ao.priceType == 'flat'
                ? ao.price
                : ao.price * r.guests;
        batch.insert('reservation_addons', {
          'id': _reservationAddonId(r.id, aid),
          'reservation_id': r.id,
          'addon_id': aid,
          'quantity': 1,
          'price_at_time': unitPrice,
        });
      }
    }

    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------------------------
  // Row <-> model helpers
  // -------------------------------------------------------------------------

  Map<String, Object?> _packageToRow(MenuPackage p) => {
        'id': p.id,
        'name': p.name,
        'category': p.category,
        'price_per_guest': p.pricePerGuest,
        'min_guests': p.minGuests,
        'max_guests': p.maxGuests,
        'description': p.description,
        'full_description': p.fullDescription,
        'image': p.image,
        'badge': p.badge,
        'rating': p.rating,
        'bookings': p.bookings,
      };

  Map<String, Object?> _reservationToRow(Reservation r) => {
        'id': r.id,
        'user_id': r.userId,
        'package_id': r.packageId,
        'event_date': r.eventDate,
        'event_time': r.eventTime,
        'guests': r.guests,
        'base_price': r.basePrice,
        'addons_price': r.addonsPrice,
        'total_price': r.totalPrice,
        'status': r.status,
        'booking_ref': r.bookingRef,
        'created_at': r.createdAt,
      };

  MenuPackage _rowToPackage(
    Map<String, Object?> row,
    List<String> courses,
    List<String> includes,
  ) {
    return MenuPackage(
      id: row['id'] as String,
      name: row['name'] as String,
      category: row['category'] as String,
      pricePerGuest: (row['price_per_guest'] as num).toDouble(),
      minGuests: (row['min_guests'] as num).toInt(),
      maxGuests: (row['max_guests'] as num).toInt(),
      description: row['description'] as String,
      fullDescription: row['full_description'] as String,
      image: row['image'] as String,
      badge: row['badge'] as String?,
      courses: courses,
      includes: includes,
      rating: (row['rating'] as num).toDouble(),
      bookings: (row['bookings'] as num).toInt(),
    );
  }

  Reservation _rowToReservation(
    Map<String, Object?> row,
    List<String> addonIds,
    String packageName,
    String packageImage,
  ) {
    return Reservation(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      packageId: row['package_id'] as String,
      packageName: packageName,
      packageImage: packageImage,
      eventDate: row['event_date'] as String,
      eventTime: row['event_time'] as String,
      guests: (row['guests'] as num).toInt(),
      addons: addonIds,
      basePrice: (row['base_price'] as num).toDouble(),
      addonsPrice: (row['addons_price'] as num).toDouble(),
      totalPrice: (row['total_price'] as num).toDouble(),
      status: row['status'] as String,
      bookingRef: row['booking_ref'] as String,
      createdAt: row['created_at'] as String,
    );
  }

  AppUser _rowToUser(Map<String, Object?> row) => AppUser(
        id: row['id'] as String,
        name: row['name'] as String,
        email: row['email'] as String,
        role: row['role'] as String,
        bookings: (row['bookings_count'] as num).toInt(),
        joinedAt: row['joined_at'] as String,
        blocked: ((row['blocked'] as num).toInt()) == 1,
      );

  Future<void> _insertReservationAddons(
    DatabaseExecutor txn,
    String reservationId,
    List<String> addonIds,
    int guests,
  ) async {
    for (final aid in addonIds) {
      final snapshot = await _addonSnapshotPrice(txn, aid, guests);
      await txn.insert('reservation_addons', {
        'id': _reservationAddonId(reservationId, aid),
        'reservation_id': reservationId,
        'addon_id': aid,
        'quantity': 1,
        'price_at_time': snapshot,
      });
    }
  }

  // -------------------------------------------------------------------------
  // Queries
  // -------------------------------------------------------------------------

  Future<List<MenuPackage>> loadPackages() async {
    final db = await database;
    final rows = await db.query('menu_packages', orderBy: 'name ASC');
    final result = <MenuPackage>[];
    for (final row in rows) {
      final id = row['id'] as String;
      final courses = (await db.query(
        'package_courses',
        where: 'package_id = ?',
        whereArgs: [id],
        orderBy: 'position ASC',
      ))
          .map((r) => r['course'] as String)
          .toList();
      final includes = (await db.query(
        'package_includes',
        where: 'package_id = ?',
        whereArgs: [id],
        orderBy: 'position ASC',
      ))
          .map((r) => r['feature'] as String)
          .toList();
      result.add(_rowToPackage(row, courses, includes));
    }
    return result;
  }

  Future<List<Reservation>> loadReservations() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT r.*, p.name AS pkg_name, p.image AS pkg_image
      FROM reservations r
      LEFT JOIN menu_packages p ON p.id = r.package_id
      ORDER BY r.event_date DESC
    ''');
    final result = <Reservation>[];
    for (final row in rows) {
      final addonIds = (await db.query(
        'reservation_addons',
        where: 'reservation_id = ?',
        whereArgs: [row['id']],
      ))
          .map((r) => r['addon_id'] as String)
          .toList();
      result.add(_rowToReservation(
        row,
        addonIds,
        (row['pkg_name'] as String?) ?? 'Package',
        (row['pkg_image'] as String?) ?? '',
      ));
    }
    return result;
  }

  Future<List<AppUser>> loadUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'joined_at DESC');
    return rows.map(_rowToUser).toList();
  }

  // -------------------------------------------------------------------------
  // Mutations
  // -------------------------------------------------------------------------

  Future<void> insertPackage(
    MenuPackage pkg, {
    String? createdByUserId,
  }) async {
    final db = await database;
    final now = _today();
    await db.transaction((txn) async {
      await txn.insert('menu_packages', {
        ..._packageToRow(pkg),
        'user_id': createdByUserId ?? defaultAdminId,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      for (var i = 0; i < pkg.courses.length; i++) {
        await txn.insert('package_courses', {
          'package_id': pkg.id,
          'course': pkg.courses[i],
          'position': i,
        });
      }
      for (var i = 0; i < pkg.includes.length; i++) {
        await txn.insert('package_includes', {
          'package_id': pkg.id,
          'feature': pkg.includes[i],
          'position': i,
        });
      }
    });
  }

  Future<void> updatePackage(MenuPackage pkg) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'menu_packages',
        {
          ..._packageToRow(pkg),
          'updated_at': _today(),
        },
        where: 'id = ?',
        whereArgs: [pkg.id],
      );
      await txn.delete('package_courses',
          where: 'package_id = ?', whereArgs: [pkg.id]);
      await txn.delete('package_includes',
          where: 'package_id = ?', whereArgs: [pkg.id]);
      for (var i = 0; i < pkg.courses.length; i++) {
        await txn.insert('package_courses', {
          'package_id': pkg.id,
          'course': pkg.courses[i],
          'position': i,
        });
      }
      for (var i = 0; i < pkg.includes.length; i++) {
        await txn.insert('package_includes', {
          'package_id': pkg.id,
          'feature': pkg.includes[i],
          'position': i,
        });
      }
    });
  }

  Future<bool> deletePackage(String id) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.delete('reservations',
            where: 'package_id = ?', whereArgs: [id]);
        await txn.delete('package_courses',
            where: 'package_id = ?', whereArgs: [id]);
        await txn.delete('package_includes',
            where: 'package_id = ?', whereArgs: [id]);
        await txn.delete('package_highlights',
            where: 'package_id = ?', whereArgs: [id]);
        await txn.delete('menu_packages', where: 'id = ?', whereArgs: [id]);
      });
      return true;
    } on DatabaseException {
      return false;
    }
  }

  Future<void> insertReservation(Reservation r, {String? userId}) async {
    final db = await database;
    final now = _today();
    await db.transaction((txn) async {
      final row = _reservationToRow(r);
      row['user_id'] = userId ?? r.userId;
      row['balance_paid'] = 0;
      row['updated_at'] = now;
      await txn.insert('reservations', row);
      await _insertReservationAddons(txn, r.id, r.addons, r.guests);
    });
  }

  Future<void> updateReservation(Reservation r) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'reservations',
        {
          'user_id': r.userId,
          'package_id': r.packageId,
          'event_date': r.eventDate,
          'event_time': r.eventTime,
          'guests': r.guests,
          'base_price': r.basePrice,
          'addons_price': r.addonsPrice,
          'total_price': r.totalPrice,
          'status': r.status,
          'updated_at': _today(),
        },
        where: 'id = ?',
        whereArgs: [r.id],
      );
      await txn.delete('reservation_addons',
          where: 'reservation_id = ?', whereArgs: [r.id]);
      await _insertReservationAddons(txn, r.id, r.addons, r.guests);
    });
  }

  Future<void> setReservationStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'reservations',
      {'status': status, 'updated_at': _today()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReservation(String id) async {
    final db = await database;
    await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
  }

  // ----- Users -------------------------------------------------------------

  Future<AppUser?> findUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users',
        where: 'LOWER(email) = LOWER(?)', whereArgs: [email], limit: 1);
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  Future<AppUser?> authenticate(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = LOWER(?) AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  Future<AppUser?> authenticateAdminByStaffId(
      String staffId, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where:
          "role = 'admin' AND password = ? AND (id = ? OR staff_id = ?)",
      whereArgs: [password, staffId, staffId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  Future<AppUser> insertUser({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final db = await database;
    final id = 'u${DateTime.now().millisecondsSinceEpoch}';
    final joinedAt = _today();
    await db.insert('users', {
      'id': id,
      'name': name,
      'email': email,
      'staff_id': role == 'admin' ? id : null,
      'password': password,
      'role': role,
      'joined_at': joinedAt,
      'blocked': 0,
      'bookings_count': 0,
    });
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role,
      bookings: 0,
      joinedAt: joinedAt,
      blocked: false,
    );
  }

  Future<void> setUserBlocked(String id, bool blocked) async {
    final db = await database;
    await db.update('users', {'blocked': blocked ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<AppUser?> updateUser({
    required String id,
    required String name,
    required String email,
    required String role,
    String? password,
  }) async {
    final db = await database;
    final values = <String, Object?>{
      'name': name,
      'email': email,
      'role': role,
    };
    if (password != null && password.isNotEmpty) {
      values['password'] = password;
    }
    if (role == 'admin') {
      values['staff_id'] = id;
    }
    final updated = await db.update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updated == 0) return null;
    final rows = await db.query('users',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  Future<bool> deleteUser(String id) async {
    final db = await database;
    final removed =
        await db.delete('users', where: 'id = ?', whereArgs: [id]);
    return removed > 0;
  }
}
