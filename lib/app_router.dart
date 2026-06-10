import 'package:flutter/material.dart';

import 'app_state.dart';
import 'data/packages_data.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/booking_form_screen.dart';
import 'screens/booking_success_screen.dart';
import 'screens/booking_summary_screen.dart';
import 'screens/error_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/manage_package_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/package_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reservations_screen.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    appState.setCurrentRoute(settings.name ?? '/');
  });

  final name = settings.name ?? '/';

  if (name == '/' || name.isEmpty) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const LandingScreen());
  }
  if (name == '/login') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const LoginScreen());
  }
  if (name == '/menu') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const MenuScreen());
  }
  if (name.startsWith('/menu/')) {
    final id = name.substring('/menu/'.length);
    if (id.isEmpty) {
      return MaterialPageRoute<void>(settings: settings, builder: (_) => const ErrorScreen(is404: true));
    }
    return MaterialPageRoute<void>(settings: settings, builder: (_) => PackageDetailScreen(packageId: id));
  }
  if (name.startsWith('/book/')) {
    final id = name.substring('/book/'.length);
    if (id.isEmpty) {
      return MaterialPageRoute<void>(settings: settings, builder: (_) => const ErrorScreen(is404: true));
    }
    return MaterialPageRoute<void>(settings: settings, builder: (_) => BookingFormScreen(packageId: id));
  }
  if (name.startsWith('/edit-booking/')) {
    final reservationId = name.substring('/edit-booking/'.length);
    if (reservationId.isEmpty) {
      return MaterialPageRoute<void>(
          settings: settings, builder: (_) => const ErrorScreen(is404: true));
    }
    Reservation? existing;
    for (final r in appState.reservations) {
      if (r.id == reservationId) {
        existing = r;
        break;
      }
    }
    if (existing == null) {
      return MaterialPageRoute<void>(
          settings: settings, builder: (_) => const ErrorScreen(is404: true));
    }
    appState.packagePreviewMode = false;
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => BookingFormScreen(
        packageId: existing!.packageId,
        editingReservation: existing,
      ),
    );
  }
  if (name == '/booking/summary') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const BookingSummaryScreen());
  }
  if (name == '/booking/success') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const BookingSuccessScreen());
  }
  if (name == '/reservations') {
    if (appState.currentUser?.role == 'admin') {
      return MaterialPageRoute<void>(
          settings: settings, builder: (_) => const AdminDashboardScreen());
    }
    return MaterialPageRoute<void>(
        settings: settings, builder: (_) => const ReservationsScreen());
  }
  if (name == '/admin') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const AdminDashboardScreen());
  }
  if (name == '/profile') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const ProfileScreen());
  }
  if (name == '/manage-package') {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => const ManagePackageScreen());
  }
  if (name.startsWith('/manage-package/')) {
    final id = name.substring('/manage-package/'.length);
    if (id.isEmpty) {
      return MaterialPageRoute<void>(settings: settings, builder: (_) => const ErrorScreen(is404: true));
    }
    return MaterialPageRoute<void>(settings: settings, builder: (_) => ManagePackageScreen(packageId: id));
  }

  return MaterialPageRoute<void>(settings: settings, builder: (_) => const ErrorScreen(is404: true));
}
