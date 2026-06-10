import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../user_display.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final isAdmin = user?.role == 'admin';
    var confirmedCount = 0;
    var totalSpend = 0.0;
    if (!isAdmin) {
      final mine = user == null
          ? const <Reservation>[]
          : appState.reservations.where((r) => r.userId == user.id).toList();
      confirmedCount = mine.where((r) => r.status == 'confirmed').length;
      totalSpend = mine
          .where((r) => r.status != 'cancelled')
          .fold<double>(0, (s, r) => s + r.totalPrice);
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1A1508), AppColors.canvas]),
              border: Border(bottom: BorderSide(color: Color.fromRGBO(201, 168, 76, 0.08))),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.gold, AppColors.goldLight]),
                    boxShadow: [BoxShadow(color: Color(0x40C9A84C), blurRadius: 30)],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userAvatarLetter(user?.name),
                    style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.canvas),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'Guest', style: GoogleFonts.cormorantGaramond(fontSize: 26, color: AppColors.cream)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: TextStyle(fontSize: 13, color: AppColors.cream.withOpacity(0.4))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                  ),
                  child: Text(
                    user?.role == 'admin' ? '⚙️ ADMINISTRATOR' : '✦ VALUED GUEST',
                    style: const TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _stat(
                        icon: '📋',
                        value: '$confirmedCount',
                        label: 'Bookings Made'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _stat(
                        icon: '💎',
                        value: '\$${_fmt(totalSpend)}',
                        label: 'Total Spent'),
                  ),
                ],
              ),
            ),
          if (!isAdmin)
            ...[
              {'icon': '📅', 'label': 'My Reservations', 'route': '/reservations'},
              {'icon': '🍽️', 'label': 'Explore Packages', 'route': '/menu'},
            ].map((item) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: OutlinedButton(
                  onPressed: item['route'] == ''
                      ? null
                      : () => Navigator.of(context).pushReplacementNamed(item['route'] as String),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: AppColors.cream,
                    side: BorderSide(color: AppColors.gold.withOpacity(0.08)),
                    backgroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Text(item['icon'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 14),
                      Expanded(child: Text(item['label'] as String, style: const TextStyle(fontSize: 14))),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.cream.withOpacity(0.25)),
                    ],
                  ),
                ),
              );
            }),
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: OutlinedButton(
                onPressed: () => _showCustomerSupport(context),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  foregroundColor: AppColors.cream,
                  side: BorderSide(color: AppColors.gold.withOpacity(0.08)),
                  backgroundColor: AppColors.card,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Text('🎧', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 14),
                    const Expanded(child: Text('Customer Support', style: TextStyle(fontSize: 14))),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.cream.withOpacity(0.25)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: OutlinedButton(
              onPressed: () {
                appState.setCurrentUser(null);
                Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(color: AppColors.danger.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              child: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Venera Private Dining · v1.0', style: TextStyle(fontSize: 11, color: AppColors.cream.withOpacity(0.2)))),
        ],
      ),
    );
  }

  Widget _stat({required String icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.cormorantGaramond(fontSize: 24, color: AppColors.gold, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.cream.withOpacity(0.4))),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  Future<void> _showCustomerSupport(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.canvas,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.gold.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withOpacity(0.12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎧', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Customer Support',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    color: AppColors.cream,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'We are here to assist you, anytime.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cream.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _supportRow(icon: Icons.phone_outlined, label: 'Phone', value: '+60 3-2788 8888'),
              const SizedBox(height: 10),
              _supportRow(icon: Icons.email_outlined, label: 'Email', value: 'support@venera-dining.com'),
              const SizedBox(height: 10),
              _supportRow(icon: Icons.chat_bubble_outline, label: 'WhatsApp', value: '+60 12-345 6789'),
              const SizedBox(height: 10),
              _supportRow(icon: Icons.access_time, label: 'Hours', value: 'Daily · 9:00 AM – 11:00 PM'),
              const SizedBox(height: 10),
              _supportRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: 'Level 28, Menara Venera, Kuala Lumpur',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: BorderSide(color: AppColors.gold.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportRow({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: AppColors.cream),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
