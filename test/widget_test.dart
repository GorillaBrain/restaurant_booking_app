
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moba/app_state.dart';
import 'package:moba/main.dart';

void main() {
  testWidgets('Venera app renders landing hero', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    addTearDown(() => binding.setSurfaceSize(null));
    await binding.setSurfaceSize(const Size(430, 932));

    await tester.pumpWidget(const VeneraApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Venera Private Dining'), findsWidgets);
  });

  testWidgets('Guest sign-in routes to /menu without crash', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    addTearDown(() => binding.setSurfaceSize(null));
    await binding.setSurfaceSize(const Size(430, 932));

    appState.setCurrentUser(null);

    await tester.pumpWidget(const VeneraApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final signIn = find.text('Sign In').first;
    expect(signIn, findsOneWidget);
    await tester.ensureVisible(signIn);
    await tester.tap(signIn, warnIfMissed: false);
    await tester.pumpAndSettle();

    final emailField = find.byType(TextField).first;
    await tester.enterText(emailField, 'guest@example.com');
    final passwordField = find.byType(TextField).at(1);
    await tester.enterText(passwordField, 'secret');
    await tester.pump();

    final signInButton = find.text('SIGN IN');
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton, warnIfMissed: false);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(appState.currentUser, isNotNull);
    expect(appState.currentUser?.role, 'user');
    expect(appState.currentRouteName, '/menu');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Admin sign-in routes to /admin without crash', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    addTearDown(() => binding.setSurfaceSize(null));
    await binding.setSurfaceSize(const Size(430, 932));

    appState.setCurrentUser(null);

    await tester.pumpWidget(const VeneraApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('Sign In').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('⚙️ Admin'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.pump();

    await tester.tap(find.text('SIGN IN'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(appState.currentUser?.role, 'admin');
    expect(appState.currentRouteName, '/admin');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Admin dashboard tabs do not crash', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    addTearDown(() => binding.setSurfaceSize(null));
    await binding.setSurfaceSize(const Size(430, 932));

    appState.setCurrentUser(null);

    await tester.pumpWidget(const VeneraApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('Sign In').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('⚙️ Admin'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.text('SIGN IN'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(appState.currentRouteName, '/admin');

    for (final tab in const ['Packages', 'Bookings', 'Users']) {
      await tester.tap(find.text(tab).first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: 'Crash on tab "$tab"');
    }
  });

  testWidgets('Bottom nav switches active route between tabs', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    addTearDown(() => binding.setSurfaceSize(null));
    await binding.setSurfaceSize(const Size(430, 932));

    appState.setCurrentUser(null);

    await tester.pumpWidget(const VeneraApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('Sign In').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'guest@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('SIGN IN'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(appState.currentRouteName, '/menu');

    await tester.tap(find.text('My Reservation'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(appState.currentRouteName, '/reservations');

    await tester.tap(find.text('Profile'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(appState.currentRouteName, '/profile');

    expect(tester.takeException(), isNull);
  });
}
