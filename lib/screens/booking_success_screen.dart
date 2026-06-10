import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = appState.currentUser?.role == 'admin';
    final confirmedId = appState.lastConfirmedReservationId;
    final latest = confirmedId != null
        ? appState.reservationById(confirmedId)
        : (appState.reservations.isNotEmpty
            ? appState.reservations.first
            : null);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                    parent: _controller, curve: Curves.elasticOut),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.08)),
                        ),
                      ),
                      Container(
                        width: 98,
                        height: 98,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.2)),
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withOpacity(0.15),
                              AppColors.gold.withOpacity(0.05)
                            ],
                          ),
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: const Icon(Icons.check,
                            size: 38, color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'BOOKING CONFIRMED',
                style: TextStyle(
                    fontSize: 10, letterSpacing: 4, color: AppColors.gold),
              ),
              const SizedBox(height: 10),
              Text(
                isAdmin ? 'Booking Saved' : 'Your Table Awaits You',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 38, height: 1.1, color: AppColors.cream),
              ),
              const SizedBox(height: 14),
              Text(
                isAdmin
                    ? 'The reservation has been updated in the system.'
                    : 'Your reservation has been confirmed. A confirmation email has been sent to your inbox.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColors.cream.withOpacity(0.5)),
              ),
              if (latest != null) ...[
                const SizedBox(height: 36),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1A1508), Color(0xFF100E05)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            AppColors.gold.withOpacity(0.3),
                            Colors.transparent
                          ]),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BOOKING REFERENCE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                      color: AppColors.cream.withOpacity(0.35)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  latest.bookingRef,
                                  style: GoogleFonts.cormorantGaramond(
                                      fontSize: 22,
                                      color: AppColors.gold,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.gold.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.receipt_long,
                                color: AppColors.gold, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _row('Package', latest.packageName),
                      _row('Date', formatDateLongGb(latest.eventDate)),
                      _row('Time', latest.eventTime),
                      _row('Guests', '${latest.guests} guests'),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            AppColors.gold.withOpacity(0.3),
                            Colors.transparent
                          ]),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.cream.withOpacity(0.5))),
                          Text(
                            '\$${_money(latest.totalPrice)}',
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.confirmed),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Confirmed · Deposit pending payment',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cream.withOpacity(0.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: goldGradient(),
                      borderRadius: BorderRadius.circular(100)),
                  child: TextButton(
                    onPressed: () {
                      appState.lastConfirmedReservationId = null;
                      Navigator.of(context).pushReplacementNamed(
                          isAdmin ? '/admin' : '/reservations');
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.canvas,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: Text(
                      isAdmin ? 'BACK TO DASHBOARD' : 'VIEW MY RESERVATIONS',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
              if (!isAdmin) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      appState.lastConfirmedReservationId = null;
                      Navigator.of(context).pushReplacementNamed('/menu');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cream.withOpacity(0.5),
                      side:
                          BorderSide(color: AppColors.gold.withOpacity(0.15)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Explore More Packages',
                        style: TextStyle(fontSize: 13, letterSpacing: 0.6)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.cream.withOpacity(0.35))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13, color: AppColors.cream.withOpacity(0.75))),
          ),
        ],
      ),
    );
  }

  String _money(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
