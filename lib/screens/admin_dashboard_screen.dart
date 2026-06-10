import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';
import '../widgets/venera_network_image.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String tab = 'overview';
  AppUser? selectedUser;
  MenuPackage? packageToDelete;
  AppUser? userToDelete;
  // When non-null, the user form modal is shown. Empty `id` means "create".
  _UserFormSeed? userForm;

  List<AppUser> get users => appState.users;

  double get totalRevenue => appState.reservations
      .where((r) => r.status != 'cancelled')
      .fold<double>(0, (s, r) => s + r.totalPrice);

  int get confirmedCount =>
      appState.reservations.where((r) => r.status == 'confirmed').length;

  int get cancelledCount =>
      appState.reservations.where((r) => r.status == 'cancelled').length;

  Future<void> _confirmAdminCancel(String reservationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        title: Text('Cancel Booking',
            style: GoogleFonts.cormorantGaramond(
                fontSize: 22, color: AppColors.cream)),
        content: Text(
          'Mark this customer reservation as cancelled? The booking will be retained in the database with a cancelled status.',
          style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.cream.withOpacity(0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep',
                style:
                    TextStyle(color: AppColors.cream.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Booking',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await appState.cancelReservation(reservationId);
      if (mounted) setState(() {});
    }
  }

  String _shortDate(String iso) {
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

  @override
  Widget build(BuildContext context) {
    final reservations = appState.reservations;
    final packages = appState.packages;
    final user = appState.currentUser;

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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ADMIN PANEL',
                                      style: TextStyle(
                                          fontSize: 10,
                                          letterSpacing: 3,
                                          color: AppColors.gold)),
                                  Text('Dashboard',
                                      style: GoogleFonts.cormorantGaramond(
                                          fontSize: 28,
                                          color: AppColors.cream)),
                                  Text(
                                    'Welcome, ${(user?.name ?? 'Admin').split(' ').first}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppColors.cream.withOpacity(0.35)),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                appState.setCurrentUser(null);
                                Navigator.of(context)
                                    .pushNamedAndRemoveUntil('/', (r) => false);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppColors.cream.withOpacity(0.4),
                                side: BorderSide(
                                    color: AppColors.gold.withOpacity(0.2)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              icon: const Icon(Icons.logout, size: 14),
                              label: const Text('Logout',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _topTab('overview', 'Overview'),
                              _topTab('packages', 'Packages'),
                              _topTab('bookings', 'Bookings'),
                              _topTab('users', 'Users'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                  children: [
                    if (tab == 'overview') ..._overview(reservations, packages),
                    if (tab == 'packages') ..._packages(packages),
                    if (tab == 'bookings') ..._bookings(reservations),
                    if (tab == 'users') ..._users(),
                  ],
                ),
              ),
            ],
          ),
          if (selectedUser != null) _userModal(),
          if (packageToDelete != null) _deleteModal(),
          if (userToDelete != null) _deleteUserModal(),
          if (userForm != null) _userFormModal(),
        ],
      ),
    );
  }

  Widget _topTab(String id, String label) {
    final active = tab == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () => setState(() => tab = id),
        style: TextButton.styleFrom(
          foregroundColor:
              active ? AppColors.gold : AppColors.cream.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
                height: 2,
                width: 40,
                color: active ? AppColors.gold : Colors.transparent),
          ],
        ),
      ),
    );
  }

  List<Widget> _overview(
      List<Reservation> reservations, List<MenuPackage> packages) {
    return [
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
        children: [
          _statCard('💰', '${(totalRevenue / 1000).round()}k', 'Total Revenue',
              'All confirmed bookings', true),
          _statCard('📋', '${reservations.length}', 'Total Bookings',
              '$confirmedCount confirmed', true),
          _statCard('🍽️', '${packages.length}', 'Packages',
              'Active menu packages', null),
          _statCard(
              '❌', '$cancelledCount', 'Cancellations', 'This period', false),
        ],
      ),
      const SizedBox(height: 24),
      _section('Recent Bookings'),
      Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < reservations.length && i < 4; i++) ...[
              if (i > 0)
                Divider(height: 1, color: AppColors.gold.withOpacity(0.06)),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                      width: 36,
                      height: 36,
                      child: VeneraNetworkImage(
                          url: reservations[i].packageImage)),
                ),
                title: Text(
                  reservations[i].packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream),
                ),
                subtitle: Text(
                  '${_shortDate(reservations[i].eventDate)} · ${reservations[i].guests} guests',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.cream.withOpacity(0.35)),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${_money(reservations[i].totalPrice)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold)),
                    Text(
                      reservations[i].status,
                      style: TextStyle(
                          fontSize: 9,
                          color: _statusColor(reservations[i].status)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _packages(List<MenuPackage> packages) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                  fontSize: 12, color: AppColors.cream.withOpacity(0.4)),
              children: [
                TextSpan(
                    text: '${packages.length}',
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 16, color: AppColors.gold)),
                const TextSpan(text: ' packages'),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldLight]),
                borderRadius: BorderRadius.circular(8)),
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/manage-package'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.canvas,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
              child: const Text('+ Add New',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ...packages.map((pkg) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.1)),
            ),
            // [IntrinsicHeight] bounds the row's height; without it, the inner
            // [Row]'s [CrossAxisAlignment.stretch] would receive infinite height
            // from the parent [ListView] and crash with an assertion.
            child: IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 80, child: VeneraNetworkImage(url: pkg.image)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pkg.name,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.cream)),
                                  const SizedBox(height: 2),
                                  Text(pkg.category.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.gold,
                                          letterSpacing: 1)),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 16, color: AppColors.gold),
                                children: [
                                  TextSpan(
                                      text:
                                          '\$${pkg.pricePerGuest.toStringAsFixed(0)}'),
                                  TextSpan(
                                      text: '/g',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color:
                                              AppColors.gold.withOpacity(0.6))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${pkg.minGuests}–${pkg.maxGuests} guests    ★ ${pkg.rating}    ${pkg.bookings} bookings',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.cream.withOpacity(0.35)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                appState.packagePreviewMode = true;
                                Navigator.of(context)
                                    .pushNamed('/menu/${pkg.id}');
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                foregroundColor: AppColors.gold,
                                side: BorderSide(
                                    color: AppColors.gold.withOpacity(0.2)),
                              ),
                              child: const Text('View',
                                  style: TextStyle(fontSize: 10)),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/manage-package/${pkg.id}'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                foregroundColor:
                                    AppColors.cream.withOpacity(0.4),
                                side: BorderSide(
                                    color: AppColors.gold.withOpacity(0.15)),
                              ),
                              child: const Text('Edit',
                                  style: TextStyle(fontSize: 10)),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  setState(() => packageToDelete = pkg),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                foregroundColor: AppColors.danger,
                                side: BorderSide(
                                    color: AppColors.danger.withOpacity(0.2)),
                              ),
                              child: const Text('Delete',
                                  style: TextStyle(fontSize: 10)),
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
          ),
        );
      }),
    ];
  }

  List<Widget> _bookings(List<Reservation> reservations) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                    fontSize: 12, color: AppColors.cream.withOpacity(0.4)),
                children: [
                  TextSpan(
                      text: '${reservations.length}',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 16, color: AppColors.gold)),
                  const TextSpan(text: ' total bookings'),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['All', 'Confirmed', 'Cancelled']
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            foregroundColor: AppColors.cream.withOpacity(0.4),
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.15)),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(f, style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.05),
                  border: Border(
                      bottom:
                          BorderSide(color: AppColors.gold.withOpacity(0.1)))),
              child: const Row(
                children: [
                  Expanded(
                      child: Text('PACKAGE',
                          style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              color: Color(0x4DF5F0E8)))),
                  SizedBox(
                      width: 80,
                      child: Text('DATE',
                          style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              color: Color(0x4DF5F0E8)))),
                  SizedBox(
                      width: 70,
                      child: Text('GUESTS',
                          style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              color: Color(0x4DF5F0E8)))),
                  SizedBox(
                      width: 80,
                      child: Text('TOTAL',
                          style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              color: Color(0x4DF5F0E8)))),
                ],
              ),
            ),
            for (var i = 0; i < reservations.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: AppColors.gold.withOpacity(0.05)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reservations[i]
                                    .packageName
                                    .split(' ')
                                    .take(2)
                                    .join(' '),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.cream),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _statusColor(
                                              reservations[i].status))),
                                  const SizedBox(width: 4),
                                  Text(reservations[i].status,
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: _statusColor(
                                              reservations[i].status))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                              _shortDate(reservations[i].eventDate)
                                  .split(' ')
                                  .take(2)
                                  .join(' '),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.cream.withOpacity(0.5))),
                        ),
                        SizedBox(
                            width: 70,
                            child: Text('${reservations[i].guests}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        AppColors.cream.withOpacity(0.6)))),
                        SizedBox(
                          width: 80,
                          child: Text(
                              '\$${(reservations[i].totalPrice / 1000).toStringAsFixed(1)}k',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              '/edit-booking/${reservations[i].id}'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            foregroundColor: AppColors.gold,
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.25)),
                          ),
                          child:
                              const Text('Edit', style: TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(width: 6),
                        if (reservations[i].status != 'cancelled')
                          OutlinedButton(
                            onPressed: () =>
                                _confirmAdminCancel(reservations[i].id),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              foregroundColor: AppColors.danger,
                              side: BorderSide(
                                  color: AppColors.danger.withOpacity(0.25)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(fontSize: 10)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A1508), Color(0xFF100E05)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Revenue',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.cream.withOpacity(0.4))),
                  Text('\$${_money(totalRevenue)}',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 24, color: AppColors.gold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Avg. Booking',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.cream.withOpacity(0.4))),
                Text(
                  '\$${_money(totalRevenue / (confirmedCount == 0 ? 1 : confirmedCount))}',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 20, color: AppColors.cream),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _users() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                  fontSize: 12, color: AppColors.cream.withOpacity(0.4)),
              children: [
                TextSpan(
                    text: '${users.length}',
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 16, color: AppColors.gold)),
                const TextSpan(text: ' users'),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: goldGradient(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => userForm = _UserFormSeed.create()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.canvas,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.add, size: 14),
              label: const Text(
                'Add User',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ...users.map((u) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: u.role == 'admin'
                        ? const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldLight])
                        : null,
                    color: u.role == 'admin'
                        ? null
                        : AppColors.gold.withOpacity(0.12),
                    border: Border.all(
                        color: u.role == 'admin'
                            ? Colors.transparent
                            : AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Text(
                    u.name.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          u.role == 'admin' ? AppColors.canvas : AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: Text(u.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.cream))),
                          if (u.role == 'admin')
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  gradient: goldGradient(),
                                  borderRadius: BorderRadius.circular(100)),
                              child: const Text('ADMIN',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.canvas,
                                      letterSpacing: 1)),
                            ),
                        ],
                      ),
                      Text(u.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.cream.withOpacity(0.35))),
                      Text(
                          'Joined ${_shortDate(u.joinedAt)} · ${u.bookings} bookings',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.cream.withOpacity(0.25))),
                    ],
                  ),
                ),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () => setState(() => selectedUser = u),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        foregroundColor: AppColors.gold,
                        side:
                            BorderSide(color: AppColors.gold.withOpacity(0.2)),
                      ),
                      child: const Text('View', style: TextStyle(fontSize: 10)),
                    ),
                    if (u.role != 'admin')
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: OutlinedButton(
                          onPressed: () async {
                            await appState.setUserBlocked(
                                u.id, !(u.blocked ?? false));
                            if (mounted) setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            foregroundColor: AppColors.danger,
                            side: BorderSide(
                                color: AppColors.danger.withOpacity(0.2)),
                          ),
                          child: Text(u.blocked == true ? 'Unblock' : 'Block',
                              style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    ];
  }

  Widget _userModal() {
    final u = selectedUser!;
    return GestureDetector(
      onTap: () => setState(() => selectedUser = null),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {},
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text('User Details',
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 20, color: AppColors.cream))),
                        IconButton(
                            onPressed: () =>
                                setState(() => selectedUser = null),
                            icon: Icon(Icons.close,
                                color: AppColors.cream.withOpacity(0.4))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: u.role == 'admin'
                                  ? const LinearGradient(colors: [
                                      AppColors.gold,
                                      AppColors.goldLight
                                    ])
                                  : null,
                              color: u.role == 'admin'
                                  ? null
                                  : AppColors.gold.withOpacity(0.12),
                              border: Border.all(
                                  color: u.role == 'admin'
                                      ? Colors.transparent
                                      : AppColors.gold,
                                  width: u.role == 'admin' ? 0 : 2),
                            ),
                            child: Text(
                              u.name.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: u.role == 'admin'
                                    ? AppColors.canvas
                                    : AppColors.gold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(u.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.cream)),
                          if (u.role == 'admin')
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                    gradient: goldGradient(),
                                    borderRadius: BorderRadius.circular(100)),
                                child: const Text('ADMINISTRATOR',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.canvas,
                                        letterSpacing: 1)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _detailRow('Email', u.email),
                          _detailRow('Role',
                              u.role[0].toUpperCase() + u.role.substring(1)),
                          _detailRow('Member Since', _shortDate(u.joinedAt)),
                          _detailRow('Total Bookings', '${u.bookings}'),
                          _detailRow(
                            'Status',
                            u.blocked == true ? 'Blocked' : 'Active',
                            valueColor: u.blocked == true
                                ? AppColors.danger
                                : const Color(0xFF4CAF80),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedUser = null;
                                userForm = _UserFormSeed.edit(u);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gold,
                              side: BorderSide(
                                  color: AppColors.gold.withOpacity(0.4)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: appState.currentUser?.id == u.id
                                ? null
                                : () {
                                    setState(() {
                                      selectedUser = null;
                                      userToDelete = u;
                                    });
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: BorderSide(
                                  color: AppColors.danger.withOpacity(0.4)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 14),
                            label: const Text('Delete',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (u.role != 'admin')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await appState.setUserBlocked(
                                    u.id, !(u.blocked ?? false));
                                if (!mounted) return;
                                setState(() {
                                  selectedUser = appState.users.firstWhere(
                                      (x) => x.id == u.id,
                                      orElse: () => u);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: BorderSide(
                                    color: AppColors.danger.withOpacity(0.3)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(u.blocked == true
                                  ? 'Unblock User'
                                  : 'Block User'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  gradient: goldGradient(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => selectedUser = null),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.canvas,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12)),
                                child: const Text('Close',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: goldGradient(),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextButton(
                          onPressed: () => setState(() => selectedUser = null),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.canvas,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text('Close',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteModal() {
    final pkg = packageToDelete!;
    return GestureDetector(
      onTap: () => setState(() => packageToDelete = null),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {},
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                            fontSize: 15, height: 1.6, color: AppColors.cream),
                        children: [
                          const TextSpan(
                              text: 'Are you sure you want to delete '),
                          TextSpan(
                              text: '"${pkg.name}"',
                              style: GoogleFonts.cormorantGaramond(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold)),
                          const TextSpan(text: '?'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This action cannot be undone. The package and any linked bookings will be permanently removed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.cream.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => packageToDelete = null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cream.withOpacity(0.7),
                              side: BorderSide(
                                  color: AppColors.gold.withOpacity(0.25)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('CANCEL',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFFCF4747),
                                Color(0xFFA83A3A)
                              ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                final ok =
                                    await appState.deletePackage(pkg.id);
                                if (!mounted) return;
                                setState(() => packageToDelete = null);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? '"${pkg.name}" and linked bookings deleted.'
                                        : 'Could not delete "${pkg.name}". Please try again.'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('DELETE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
                width: 14, height: 1, color: AppColors.gold.withOpacity(0.5)),
            const SizedBox(width: 12),
            Text(t.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10, letterSpacing: 3, color: AppColors.gold)),
            const SizedBox(width: 12),
            Expanded(
                child: Container(
                    height: 1, color: AppColors.gold.withOpacity(0.12))),
          ],
        ),
      );

  Widget _statCard(
      String icon, String value, String title, String sub, bool? positive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              if (positive != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: positive
                        ? const Color(0x1A4CAF50)
                        : const Color(0x1ACF4747),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(positive ? '↑' : '↓',
                      style: TextStyle(
                          fontSize: 9,
                          color: positive
                              ? const Color(0xFF4CAF80)
                              : AppColors.danger,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  height: 1)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 11, color: AppColors.cream)),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(
                  fontSize: 10, color: AppColors.cream.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cream.withOpacity(0.4),
                  letterSpacing: 1)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.cream)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'confirmed') return const Color(0xFF4CAF80);
    if (status == 'pending') return AppColors.gold;
    return AppColors.danger;
  }

  String _money(double v) {
    if (v >= 1000) {
      return v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  Widget _deleteUserModal() {
    final u = userToDelete!;
    return GestureDetector(
      onTap: () => setState(() => userToDelete = null),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {},
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                            fontSize: 15, height: 1.6, color: AppColors.cream),
                        children: [
                          const TextSpan(
                              text: 'Are you sure you want to delete '),
                          TextSpan(
                              text: '"${u.name}"',
                              style: GoogleFonts.cormorantGaramond(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold)),
                          const TextSpan(text: '?'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This will permanently remove the account. Their past bookings are kept (and unassigned) in the booking history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.cream.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => userToDelete = null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cream.withOpacity(0.7),
                              side: BorderSide(
                                  color: AppColors.gold.withOpacity(0.25)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('CANCEL',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFFCF4747),
                                Color(0xFFA83A3A)
                              ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                final ok =
                                    await appState.adminDeleteUser(u.id);
                                if (!mounted) return;
                                setState(() => userToDelete = null);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? '${u.name} deleted.'
                                        : 'Cannot delete this account.'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('DELETE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userFormModal() {
    final seed = userForm!;
    return _UserFormModal(
      key: ValueKey(seed.id ?? 'new'),
      seed: seed,
      onCancel: () => setState(() => userForm = null),
      onSaved: (msg) {
        if (!mounted) return;
        setState(() => userForm = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }
}

/// Snapshot of the user-form modal's initial values. `id == null` means a
/// brand-new user is being created; otherwise the form edits the user with
/// that id.
class _UserFormSeed {
  _UserFormSeed.create()
      : id = null,
        name = '',
        email = '',
        role = 'user';

  _UserFormSeed.edit(AppUser u)
      : id = u.id,
        name = u.name,
        email = u.email,
        role = u.role;

  final String? id;
  final String name;
  final String email;
  final String role;

  bool get isEdit => id != null;
}

class _UserFormModal extends StatefulWidget {
  const _UserFormModal({
    super.key,
    required this.seed,
    required this.onCancel,
    required this.onSaved,
  });

  final _UserFormSeed seed;
  final VoidCallback onCancel;
  final void Function(String message) onSaved;

  @override
  State<_UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<_UserFormModal> {
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController passwordCtrl;
  late String role;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.seed.name);
    emailCtrl = TextEditingController(text: widget.seed.email);
    passwordCtrl = TextEditingController();
    role = widget.seed.role;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (name.isEmpty || email.isEmpty) {
      setState(() => error = 'Name and email are required.');
      return;
    }
    if (!widget.seed.isEdit && password.isEmpty) {
      setState(() => error = 'Password is required for new accounts.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    if (widget.seed.isEdit) {
      final updated = await appState.adminUpdateUser(
        id: widget.seed.id!,
        name: name,
        email: email,
        role: role,
        password: password.isEmpty ? null : password,
      );
      if (!mounted) return;
      if (updated == null) {
        setState(() {
          saving = false;
          error = 'Could not update user.';
        });
        return;
      }
      widget.onSaved('${updated.name} updated.');
    } else {
      final created = await appState.adminCreateUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      if (!mounted) return;
      if (created == null) {
        setState(() {
          saving = false;
          error = 'An account with that email already exists.';
        });
        return;
      }
      widget.onSaved('${created.name} added.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCancel,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {},
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.seed.isEdit ? 'Edit User' : 'Add User',
                              style: GoogleFonts.cormorantGaramond(
                                  fontSize: 22, color: AppColors.cream),
                            ),
                          ),
                          IconButton(
                            onPressed: saving ? null : widget.onCancel,
                            icon: Icon(Icons.close,
                                color: AppColors.cream.withOpacity(0.4)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _label('Full Name'),
                      _input(controller: nameCtrl, hint: 'Eleanor Whitmore'),
                      const SizedBox(height: 14),
                      _label('Email'),
                      _input(
                          controller: emailCtrl,
                          hint: 'eleanor@example.com',
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _label(widget.seed.isEdit
                          ? 'New Password (optional)'
                          : 'Password'),
                      _input(
                          controller: passwordCtrl,
                          hint: widget.seed.isEdit
                              ? 'Leave blank to keep current'
                              : 'Set a starting password',
                          obscure: true),
                      const SizedBox(height: 14),
                      _label('Role'),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            _roleChip('user', 'Guest'),
                            _roleChip('admin', 'Admin'),
                          ],
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving ? null : widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppColors.cream.withOpacity(0.7),
                                side: BorderSide(
                                    color: AppColors.gold.withOpacity(0.25)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('CANCEL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: goldGradient(),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: TextButton(
                                onPressed: saving ? null : _submit,
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.canvas,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14)),
                                child: Text(
                                  saving
                                      ? 'SAVING…'
                                      : widget.seed.isEdit
                                          ? 'SAVE'
                                          : 'CREATE',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label) {
    final selected = role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? goldGradient() : null,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.canvas
                  : AppColors.cream.withOpacity(0.55),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.4,
            color: AppColors.cream.withOpacity(0.45),
          ),
        ),
      );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: AppColors.cream),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(fontSize: 13, color: AppColors.cream.withOpacity(0.3)),
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)),
        ),
      ),
    );
  }
}
