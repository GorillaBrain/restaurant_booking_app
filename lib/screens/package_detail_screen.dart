import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';
import '../widgets/venera_network_image.dart';

class PackageDetailScreen extends StatelessWidget {
  const PackageDetailScreen({super.key, required this.packageId});

  final String packageId;

  @override
  Widget build(BuildContext context) {
    MenuPackage? pkg;
    try {
      pkg = appState.packages.firstWhere((p) => p.id == packageId);
    } catch (_) {
      pkg = null;
    }

    if (pkg == null) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
            child: Text('Package not found',
                style: TextStyle(color: AppColors.cream, fontSize: 22))),
      );
    }

    final p = pkg;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 380,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VeneraNetworkImage(url: p.image),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.95),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 52,
                        left: 20,
                        child: IconButton(
                          onPressed: () {
                            if (appState.packagePreviewMode) {
                              appState.packagePreviewMode = false;
                            }
                            Navigator.of(context).pop();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.2)),
                          ),
                          icon: const Icon(Icons.arrow_back,
                              size: 18, color: AppColors.cream),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: AppColors.gold.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    p.category.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        color: AppColors.gold),
                                  ),
                                ),
                                if (p.badge != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: goldGradient(),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      p.badge!.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                        color: AppColors.canvas,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 34,
                                height: 1.1,
                                color: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                ...List.generate(5, (i) {
                                  final filled = i < p.rating.floor();
                                  return Text(
                                    '★',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: filled
                                          ? AppColors.gold
                                          : AppColors.gold.withOpacity(0.3),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 6),
                                Text(
                                  '${p.rating} (${p.bookings} bookings)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.cream.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1508), Color(0xFF120F05)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRICE PER GUEST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.cream.withOpacity(0.4),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gold,
                                      height: 1,
                                    ),
                                    children: [
                                      TextSpan(
                                          text:
                                              '\$${p.pricePerGuest.toStringAsFixed(0)}'),
                                      TextSpan(
                                        text: '/guest',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              AppColors.gold.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Guest Range',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          AppColors.cream.withOpacity(0.35))),
                              Text(
                                '${p.minGuests}–${p.maxGuests}',
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 20, color: AppColors.cream),
                              ),
                              Text('guests',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          AppColors.cream.withOpacity(0.35))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('About This Package'),
                    Text(
                      p.fullDescription,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.8,
                          color: AppColors.cream.withOpacity(0.65)),
                    ),
                    const SizedBox(height: 28),
                    _sectionTitle('Menu Courses'),
                    ...List.generate(p.courses.length, (i) {
                      final course = p.courses[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.gold.withOpacity(0.07)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withOpacity(0.1),
                                  border: Border.all(
                                      color: AppColors.gold.withOpacity(0.3)),
                                ),
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.gold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(course,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.cream))),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    _sectionTitle("What's Included"),
                    ...p.includes.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withOpacity(0.12)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check,
                                  size: 12, color: AppColors.gold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(item,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.cream.withOpacity(0.7))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Customise your booking with premium add-ons including live entertainment, floral arrangements, open bar packages and more.',
                              style: TextStyle(
                                  fontSize: 12,
                                  height: 1.7,
                                  color: AppColors.cream.withOpacity(0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.canvas, AppColors.canvas.withOpacity(0)],
                    stops: const [0, 0.6],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: goldGradient(),
                          borderRadius: BorderRadius.circular(100)),
                      child: TextButton(
                        onPressed: () {
                          if (appState.currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please sign in to book this package'),
                              ),
                            );
                            Navigator.of(context).pushNamed('/login');
                          } else {
                            Navigator.of(context).pushNamed('/book/${p.id}');
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.canvas,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          appState.currentUser == null
                              ? 'SIGN IN TO BOOK'
                              : 'CUSTOMIZE & BOOK',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
              width: 20, height: 1, color: AppColors.gold.withOpacity(0.5)),
          const SizedBox(width: 12),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
                fontSize: 10, letterSpacing: 3, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Container(
                  height: 1, color: AppColors.gold.withOpacity(0.15))),
        ],
      ),
    );
  }
}
