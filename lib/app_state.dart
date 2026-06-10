import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_database.dart';
import 'data/packages_data.dart';

/// Global app state. In-memory cache backed by the SQLite database
/// (`restaurant_package_booking`) and `SharedPreferences` for the signed-in
/// user session.
class AppState extends ChangeNotifier {
  CurrentUser? currentUser;
  BookingDraft? bookingDraft;

  /// Set when an admin opens a package via Packages → View (read-only walkthrough).
  bool packagePreviewMode = false;

  /// Reservation just confirmed or updated — used by [BookingSuccessScreen].
  String? lastConfirmedReservationId;
  List<Reservation> reservations = const [];
  List<MenuPackage> packages = const [];
  List<AppUser> users = const [];
  String currentRouteName = '/';

  static const _kCurrentUserId = 'venera.currentUser.id';

  /// Hydrate the in-memory state from the database. Called once from `main`
  /// before `runApp`.
  Future<void> load() async {
    packages = await AppDatabase.instance.loadPackages();
    reservations = await AppDatabase.instance.loadReservations();
    users = await AppDatabase.instance.loadUsers();

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_kCurrentUserId);
    if (savedId != null) {
      for (final u in users) {
        if (u.id == savedId && (u.blocked != true)) {
          currentUser = CurrentUser(
            id: u.id,
            name: u.name,
            email: u.email,
            role: u.role,
          );
          break;
        }
      }
    }
    notifyListeners();
  }

  void setCurrentRoute(String name) {
    if (currentRouteName == name) return;
    currentRouteName = name;
    notifyListeners();
  }

  Future<void> setCurrentUser(CurrentUser? user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_kCurrentUserId);
    } else {
      await prefs.setString(_kCurrentUserId, user.id);
    }
    notifyListeners();
  }

  void setBookingDraft(BookingDraft? draft) {
    bookingDraft = draft;
    if (draft == null) packagePreviewMode = false;
    notifyListeners();
  }

  Reservation? reservationById(String id) {
    for (final r in reservations) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> addReservation(Reservation res) async {
    // Stamp the reservation with the signed-in user's id so "My Reservations"
    // can filter on it. Falls back to whatever id is already on the model
    // (e.g. seed data) when no one is signed in.
    final owned = res.userId == null && currentUser != null
        ? res.copyWith(userId: currentUser!.id)
        : res;
    await AppDatabase.instance
        .insertReservation(owned, userId: currentUser?.id);
    reservations = [owned, ...reservations];
    notifyListeners();
  }

  Future<void> updateReservation(Reservation res) async {
    await AppDatabase.instance.updateReservation(res);
    reservations = reservations
        .map((r) => r.id == res.id ? res : r)
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> cancelReservation(String id) async {
    await AppDatabase.instance.setReservationStatus(id, 'cancelled');
    reservations = reservations
        .map((r) => r.id == id ? r.copyWith(status: 'cancelled') : r)
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> deleteReservation(String id) async {
    await AppDatabase.instance.deleteReservation(id);
    reservations = reservations.where((r) => r.id != id).toList(growable: false);
    notifyListeners();
  }

  Future<void> addPackage(MenuPackage pkg) async {
    await AppDatabase.instance.insertPackage(
      pkg,
      createdByUserId: currentUser?.id,
    );
    packages = [...packages, pkg];
    notifyListeners();
  }

  Future<void> updatePackage(String id, MenuPackage pkg) async {
    await AppDatabase.instance.updatePackage(pkg);
    packages = packages.map((p) => p.id == id ? pkg : p).toList(growable: false);
    notifyListeners();
  }

  /// Admin-side package removal, including any reservations for that package.
  Future<bool> deletePackage(String id) async {
    final removed = await AppDatabase.instance.deletePackage(id);
    if (!removed) return false;
    packages = packages.where((p) => p.id != id).toList(growable: false);
    reservations =
        reservations.where((r) => r.packageId != id).toList(growable: false);
    notifyListeners();
    return true;
  }

  /// Persist a newly registered user and sign them in.
  Future<AppUser?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final existing = await AppDatabase.instance.findUserByEmail(email);
    if (existing != null) return null;
    final user = await AppDatabase.instance.insertUser(
      name: name,
      email: email,
      password: password,
    );
    users = [user, ...users];
    notifyListeners();
    return user;
  }

  /// Authenticate by email + password (guests) or by staff id + password
  /// (admins). Returns `null` when credentials are invalid or the account is
  /// blocked.
  Future<AppUser?> signIn({
    required String identifier,
    required String password,
    required String role,
  }) async {
    AppUser? user;
    if (role == 'admin') {
      user = await AppDatabase.instance
          .authenticateAdminByStaffId(identifier, password);
    } else {
      user = await AppDatabase.instance.authenticate(identifier, password);
    }
    if (user == null || user.blocked == true) return null;
    return user;
  }

  Future<void> setUserBlocked(String id, bool blocked) async {
    await AppDatabase.instance.setUserBlocked(id, blocked);
    users = users
        .map((u) => u.id == id ? u.copyWith(blocked: blocked) : u)
        .toList(growable: false);
    notifyListeners();
  }

  /// Admin-side user creation. Returns `null` when the email already exists.
  Future<AppUser?> adminCreateUser({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final existing = await AppDatabase.instance.findUserByEmail(email);
    if (existing != null) return null;
    final user = await AppDatabase.instance.insertUser(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    users = [user, ...users];
    notifyListeners();
    return user;
  }

  /// Admin-side user update. `password` is optional. Returns `null` when the
  /// user no longer exists.
  Future<AppUser?> adminUpdateUser({
    required String id,
    required String name,
    required String email,
    required String role,
    String? password,
  }) async {
    final updated = await AppDatabase.instance.updateUser(
      id: id,
      name: name,
      email: email,
      role: role,
      password: password,
    );
    if (updated == null) return null;
    users = users.map((u) => u.id == id ? updated : u).toList(growable: false);
    notifyListeners();
    return updated;
  }

  /// Admin-side user deletion. Refuses to delete the currently signed-in
  /// admin to avoid locking themselves out mid-session.
  Future<bool> adminDeleteUser(String id) async {
    if (currentUser?.id == id) return false;
    final removed = await AppDatabase.instance.deleteUser(id);
    if (!removed) return false;
    users = users.where((u) => u.id != id).toList(growable: false);
    // The `reservations.user_id` FK is SET NULL on delete; reflect that in
    // the in-memory cache so the bookings tab shows the orphan state.
    reservations = reservations
        .map((r) => r.userId == id
            ? Reservation(
                id: r.id,
                packageId: r.packageId,
                packageName: r.packageName,
                packageImage: r.packageImage,
                eventDate: r.eventDate,
                eventTime: r.eventTime,
                guests: r.guests,
                addons: r.addons,
                basePrice: r.basePrice,
                addonsPrice: r.addonsPrice,
                totalPrice: r.totalPrice,
                status: r.status,
                bookingRef: r.bookingRef,
                createdAt: r.createdAt,
              )
            : r)
        .toList(growable: false);
    notifyListeners();
    return true;
  }
}

final AppState appState = AppState();

bool shouldShowBottomNav(String routeName) {
  const hidden = {'/', '/login', '/booking/success'};
  if (hidden.contains(routeName)) return false;
  // Guest browsing (`/menu`, `/menu/:id`) — hide auth-only tabs.
  if (appState.currentUser == null) return false;
  return true;
}
