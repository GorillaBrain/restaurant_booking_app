import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';
import '../widgets/venera_network_image.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const String _heroUrl = 'assets/images/hero_dining_room.jpg';

  @override
  Widget build(BuildContext context) {
    final featured = appState.packages.take(4).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 520,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const VeneraNetworkImage(url: _heroUrl),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(10, 10, 10, 0.3),
                          Color.fromRGBO(10, 10, 10, 0.5),
                          Color.fromRGBO(10, 10, 10, 0.95),
                        ],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Est. 1987',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 11,
                              letterSpacing: 4.2,
                              color: AppColors.gold,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pushNamed('/login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.goldLight,
                              side: BorderSide(color: AppColors.gold.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              shape: const StadiumBorder(),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Sign In', style: TextStyle(fontSize: 12, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Venera Private Dining',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 11,
                            letterSpacing: 5,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 46,
                              fontWeight: FontWeight.w300,
                              height: 1.1,
                              color: AppColors.cream,
                            ),
                            children: [
                              const TextSpan(text: 'Where Every\n'),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: goldGradientText(
                                  'Moment',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w300,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' Becomes\na Memory'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Bespoke private dining experiences for weddings, corporate events & celebrations.',
                          style: TextStyle(
                            color: AppColors.cream.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.gold.withOpacity(0.1)),
                  bottom: BorderSide(color: AppColors.gold.withOpacity(0.1)),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: const Row(
                children: [
                  Expanded(child: _Stat(value: '6+', label: 'Curated Packages')),
                  Expanded(child: _Stat(value: '500+', label: 'Events Hosted')),
                  Expanded(child: _Stat(value: '4.9★', label: 'Guest Rating')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Collection',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 3.5,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Menu Packages',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: AppColors.cream,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/menu'),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final pkg = featured[index];
                  return _FeaturedCard(pkg: pkg);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Occasions',
                    style: TextStyle(fontSize: 10, letterSpacing: 3.5, color: AppColors.gold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perfect for Every Event',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      color: AppColors.cream,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: const [
                      _Occasion(icon: '💍', label: 'Weddings', sub: 'Unforgettable banquets'),
                      _Occasion(icon: '💼', label: 'Corporate', sub: 'Impress your clients'),
                      _Occasion(icon: '🥂', label: 'Celebrations', sub: 'Birthdays & milestones'),
                      _Occasion(icon: '🕯️', label: 'Anniversaries', sub: 'Romantic experiences'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1508), Color(0xFF0F0D06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.gold,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: AppColors.cream,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(text: 'Begin Your '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: goldGradientText(
                              'Journey',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Create an account to browse all packages and make your reservation with ease.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, height: 1.7, color: AppColors.cream.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(gradient: goldGradient(), borderRadius: BorderRadius.circular(100)),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.canvas,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Reserve Your Experience',
                            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushNamed('/menu'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Explore Menu',
                          style: TextStyle(letterSpacing: 1, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.gold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.cream.withOpacity(0.45),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.pkg});

  final MenuPackage pkg;

  @override
  Widget build(BuildContext context) {
    final snippet = pkg.description.length > 60 ? '${pkg.description.substring(0, 60)}...' : pkg.description;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/menu/${pkg.id}'),
      child: Container(
        width: 230,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 144,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VeneraNetworkImage(url: pkg.image),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        stops: const [0.4, 1],
                      ),
                    ),
                  ),
                  if (pkg.badge != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                        ),
                        child: Text(
                          pkg.badge!.toUpperCase(),
                          style: const TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.gold),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        pkg.category,
                        style: const TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.goldLight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.cream,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        snippet,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.cream.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'FROM',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.cream.withOpacity(0.4),
                                  letterSpacing: 1,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold,
                                  ),
                                  children: [
                                    TextSpan(text: '\$${pkg.pricePerGuest.toStringAsFixed(0)}'),
                                    TextSpan(
                                      text: '/guest',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.gold.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Text('★', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                            const SizedBox(width: 3),
                            Text(
                              '${pkg.rating}',
                              style: TextStyle(fontSize: 11, color: AppColors.cream.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Occasion extends StatelessWidget {
  const _Occasion({required this.icon, required this.label, required this.sub});

  final String icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/menu'),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cormorantGaramond(fontSize: 16, color: AppColors.cream),
            ),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 11, color: AppColors.cream.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}
