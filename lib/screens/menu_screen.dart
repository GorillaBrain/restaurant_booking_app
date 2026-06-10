import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../user_display.dart';
import '../theme/app_colors.dart';
import '../widgets/venera_network_image.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  String category = 'All';
  int priceRange = 0;
  bool grid = true;
  bool showFilters = false;

  static const categories = [
    'All',
    'Wedding',
    'Corporate',
    'Celebration',
    'Anniversary',
    'Gala'
  ];

  static const priceRanges = <Map<String, Object>>[
    {'label': 'All Prices', 'min': 0, 'max': double.infinity},
    {'label': r'Under $200', 'min': 0, 'max': 200},
    {'label': r'$200–$270', 'min': 200, 'max': 270},
    {'label': r'$270+', 'min': 270, 'max': double.infinity},
  ];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<MenuPackage> _filtered() {
    final q = searchCtrl.text.toLowerCase();
    final pr = priceRanges[priceRange];
    final min = pr['min'] as num;
    final max = pr['max'] as num;

    return appState.packages.where((pkg) {
      final matchSearch = pkg.name.toLowerCase().contains(q) ||
          pkg.category.toLowerCase().contains(q);
      final matchCat = category == 'All' || pkg.category == category;
      final matchPrice = pkg.pricePerGuest >= min && pkg.pricePerGuest <= max;
      return matchSearch && matchCat && matchPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final filtered = _filtered();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              border: Border(
                  bottom:
                      BorderSide(color: Color.fromRGBO(201, 168, 76, 0.08))),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Venera',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.gold,
                                    letterSpacing: 3),
                              ),
                              Text(
                                'Menu Packages',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 28,
                                  height: 1.1,
                                  color: AppColors.cream,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => grid = !grid),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.card,
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.15)),
                          ),
                          icon: Icon(grid ? Icons.grid_view : Icons.view_list,
                              color: AppColors.gold, size: 18),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            final String target;
                            if (user == null) {
                              target = '/login';
                            } else if (user.role == 'admin') {
                              target = '/admin';
                            } else {
                              target = '/reservations';
                            }
                            Navigator.of(context).pushReplacementNamed(target);
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [
                                AppColors.gold,
                                AppColors.goldLight
                              ]),
                            ),
                            child: Text(
                              userAvatarLetter(user?.name),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.canvas,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              size: 16,
                              color: AppColors.cream.withOpacity(0.3)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                  color: AppColors.cream, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search packages...',
                                border: InputBorder.none,
                                isDense: true,
                                hintStyle: TextStyle(
                                    color: AppColors.cream.withOpacity(0.25)),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => showFilters = !showFilters),
                            style: TextButton.styleFrom(
                              foregroundColor: showFilters
                                  ? AppColors.gold
                                  : AppColors.cream.withOpacity(0.4),
                              backgroundColor: showFilters
                                  ? AppColors.gold.withOpacity(0.15)
                                  : null,
                              side: BorderSide(
                                color: showFilters
                                    ? AppColors.gold.withOpacity(0.4)
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.tune, size: 14),
                            label: const Text('Filter',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final active = category == cat;
                        return OutlinedButton(
                          onPressed: () => setState(() => category = cat),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: active
                                ? AppColors.canvas
                                : AppColors.cream.withOpacity(0.5),
                            backgroundColor:
                                active ? AppColors.gold : Colors.transparent,
                            side: BorderSide(
                              color: active
                                  ? Colors.transparent
                                  : AppColors.gold.withOpacity(0.15),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(cat,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400)),
                        );
                      },
                    ),
                  ),
                  if (showFilters)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRICE RANGE (PER GUEST)',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.cream.withOpacity(0.35),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(priceRanges.length, (i) {
                              final pr = priceRanges[i];
                              final label = pr['label'] as String;
                              final active = priceRange == i;
                              return OutlinedButton(
                                onPressed: () => setState(() => priceRange = i),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: active
                                      ? AppColors.gold
                                      : AppColors.cream.withOpacity(0.4),
                                  side: BorderSide(
                                    color: active
                                        ? AppColors.gold
                                        : AppColors.gold.withOpacity(0.15),
                                  ),
                                  backgroundColor: active
                                      ? AppColors.gold.withOpacity(0.12)
                                      : null,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(label,
                                    style: const TextStyle(fontSize: 11)),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🍽️', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          Text(
                            'No Packages Found',
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 22, color: AppColors.cream),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try adjusting your search or filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.cream.withOpacity(0.4)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.cream.withOpacity(0.35)),
                            children: [
                              TextSpan(
                                text: '${filtered.length}',
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 16, color: AppColors.gold),
                              ),
                              const TextSpan(text: ' packages available'),
                            ],
                          ),
                        ),
                      ),
                      if (grid)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final pkg = filtered[i];
                            return _GridCard(
                              pkg: pkg,
                              onTap: () => Navigator.of(context)
                                  .pushNamed('/menu/${pkg.id}'),
                            );
                          },
                        )
                      else
                        Column(
                          children: filtered
                              .map(
                                (pkg) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ListCard(
                                    pkg: pkg,
                                    onTap: () => Navigator.of(context)
                                        .pushNamed('/menu/${pkg.id}'),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.pkg, required this.onTap});

  final MenuPackage pkg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 124,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VeneraNetworkImage(url: pkg.image),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85)
                        ],
                        stops: const [0.5, 1],
                      ),
                    ),
                  ),
                  if (pkg.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          pkg.badge!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.canvas,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pkg.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pkg.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14,
                        height: 1.15,
                        color: AppColors.cream,
                      ),
                    ),
                    const Spacer(),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                        children: [
                          TextSpan(
                              text:
                                  '\$${pkg.pricePerGuest.toStringAsFixed(0)}'),
                          TextSpan(
                            text: '/guest',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: AppColors.gold.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Min. ${pkg.minGuests} guests',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.cream.withOpacity(0.4)),
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

class _ListCard extends StatelessWidget {
  const _ListCard({required this.pkg, required this.onTap});

  final MenuPackage pkg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snippet = pkg.description.length > 70
        ? '${pkg.description.substring(0, 70)}...'
        : pkg.description;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 132,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VeneraNetworkImage(url: pkg.image),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.card.withOpacity(0.8)
                        ],
                        stops: const [0.6, 1],
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pkg.category.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.gold,
                                letterSpacing: 1.2),
                          ),
                        ),
                        if (pkg.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: AppColors.gold.withOpacity(0.3)),
                            ),
                            child: Text(
                              pkg.badge!,
                              style: const TextStyle(
                                  fontSize: 8,
                                  letterSpacing: 1,
                                  color: AppColors.gold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pkg.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 17, height: 1.2, color: AppColors.cream),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: AppColors.cream.withOpacity(0.45)),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                              children: [
                                TextSpan(
                                    text:
                                        '\$${pkg.pricePerGuest.toStringAsFixed(0)}'),
                                TextSpan(
                                  text: '/guest',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.gold.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text('★',
                            style:
                                TextStyle(color: AppColors.gold, fontSize: 11)),
                        const SizedBox(width: 4),
                        Text('${pkg.rating}',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.cream.withOpacity(0.5))),
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
