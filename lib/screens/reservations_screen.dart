import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../widgets/venera_network_image.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  String tab = 'upcoming';
  String? cancelId;

  String _todayIso() => DateTime.now().toIso8601String().split('T').first;

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final today = _todayIso();
    // Only show reservations belonging to the signed-in user. Admins manage
    // bookings from the admin dashboard's Bookings tab instead.
    final mine = user == null
        ? const <Reservation>[]
        : appState.reservations.where((r) => r.userId == user.id).toList();
    final upcoming = mine
        .where(
            (r) => r.eventDate.compareTo(today) >= 0 && r.status != 'cancelled')
        .toList();
    final past = mine
        .where(
            (r) => r.eventDate.compareTo(today) < 0 || r.status == 'cancelled')
        .toList();
    final displayed = tab == 'upcoming' ? upcoming : past;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  border: Border(
                      bottom: BorderSide(
                          color: Color.fromRGBO(201, 168, 76, 0.08))),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Guest',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gold,
                                  letterSpacing: 3),
                            ),
                            Text('My Reservations',
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 28, color: AppColors.cream)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _tab(
                                  'upcoming', 'Upcoming', upcoming.length)),
                          Expanded(child: _tab('past', 'Past', past.length)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: displayed.isEmpty
                    ? _Empty(
                        tab: tab,
                        onExplore: () =>
                            Navigator.of(context).pushReplacementNamed('/menu'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final res = displayed[i];
                          return _ReservationCard(
                            res: res,
                            today: today,
                            onCancel: () => setState(() => cancelId = res.id),
                            onEdit: () => Navigator.of(context)
                                .pushNamed('/edit-booking/${res.id}'),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (cancelId != null)
            GestureDetector(
              onTap: () => setState(() => cancelId = null),
              child: Container(color: Colors.black.withOpacity(0.85)),
            ),
          if (cancelId != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: AppColors.card,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: AppColors.cream.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Cancel Reservation',
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 24, color: AppColors.cream)),
                        const SizedBox(height: 8),
                        Text(
                          'Are you sure you want to cancel this reservation? This action cannot be undone and cancellation fees may apply.',
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.7,
                              color: AppColors.cream.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            appState.cancelReservation(cancelId!);
                            setState(() => cancelId = null);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            backgroundColor: const Color(0x26CF4747),
                            side: const BorderSide(color: Color(0x66CF4747)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('YES, CANCEL RESERVATION',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1)),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => setState(() => cancelId = null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.cream.withOpacity(0.5),
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Keep My Reservation'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tab(String id, String label, int count) {
    final active = tab == id;
    return InkWell(
      onTap: () => setState(() => tab = id),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: active ? AppColors.gold : Colors.transparent, width: 2),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color:
                    active ? AppColors.gold : AppColors.cream.withOpacity(0.35),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.gold.withOpacity(0.15)
                    : AppColors.cream.withOpacity(0.06),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                    fontSize: 10,
                    color: active
                        ? AppColors.gold
                        : AppColors.cream.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard(
      {required this.res,
      required this.today,
      required this.onCancel,
      required this.onEdit});

  final Reservation res;
  final String today;
  final VoidCallback onCancel;
  final VoidCallback onEdit;

  Color _statusColor() {
    if (res.status == 'confirmed') return const Color(0xFF4CAF80);
    if (res.status == 'pending') return AppColors.gold;
    return AppColors.danger;
  }

  Color _statusBg() {
    if (res.status == 'confirmed') return const Color(0x1A4CAF50);
    if (res.status == 'pending') return AppColors.gold.withOpacity(0.1);
    return const Color(0x1AB43C3C);
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor();
    final isUpcoming =
        res.eventDate.compareTo(today) >= 0 && res.status != 'cancelled';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                VeneraNetworkImage(url: res.packageImage),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.card.withOpacity(0.85),
                        AppColors.card.withOpacity(0.3)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            res.bookingRef,
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                color: AppColors.cream.withOpacity(0.5)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusBg(),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: sc.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, color: sc)),
                                const SizedBox(width: 5),
                                Text(
                                  res.status[0].toUpperCase() +
                                      res.status.substring(1),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: sc,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(res.packageName,
                          style: GoogleFonts.cormorantGaramond(
                              fontSize: 20, color: AppColors.cream)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _detail('Date', _short(res.eventDate))),
                    Expanded(child: _detail('Time', res.eventTime)),
                    Expanded(child: _detail('Guests', '${res.guests}')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.cream.withOpacity(0.35))),
                    Text(
                      '\$${_money(res.totalPrice)}',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold),
                    ),
                  ],
                ),
                if (isUpcoming) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.3)),
                            backgroundColor: AppColors.gold.withOpacity(0.06),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('MODIFY',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: BorderSide(
                                color: AppColors.danger.withOpacity(0.25)),
                            backgroundColor: AppColors.danger.withOpacity(0.06),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('CANCEL',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                color: AppColors.cream.withOpacity(0.3))),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 12, color: AppColors.cream.withOpacity(0.75))),
      ],
    );
  }

  String _short(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _money(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

class _Empty extends StatelessWidget {
  const _Empty({required this.tab, required this.onExplore});

  final String tab;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final upcoming = tab == 'upcoming';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(upcoming ? '📅' : '🍽️', style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            upcoming ? 'No Upcoming Reservations' : 'No Past Reservations',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
                fontSize: 24, color: AppColors.cream),
          ),
          const SizedBox(height: 8),
          Text(
            upcoming
                ? "You don't have any upcoming reservations. Explore our menu packages to book your next event."
                : 'Your past reservations will appear here once events have taken place.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                height: 1.7,
                color: AppColors.cream.withOpacity(0.4)),
          ),
          if (upcoming) ...[
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.gold, AppColors.goldLight]),
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: TextButton(
                onPressed: onExplore,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.canvas,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 13)),
                child: const Text('EXPLORE PACKAGES',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, letterSpacing: 1)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
