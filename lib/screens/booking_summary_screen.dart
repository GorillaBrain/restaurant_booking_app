import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';
import '../widgets/venera_network_image.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (appState.bookingDraft == null) {
        final fallback = appState.currentUser?.role == 'admin'
            ? '/admin'
            : '/menu';
        Navigator.of(context).pushReplacementNamed(fallback);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = appState.bookingDraft;
    if (draft == null) {
      return const Scaffold(
          backgroundColor: AppColors.canvas, body: SizedBox.shrink());
    }

    final isPreview = draft.packagePreviewOnly;
    final basePrice = draft.pricePerGuest * draft.guests;
    final addonsPrice = draft.totalPrice - basePrice;
    final addonsDetails = draft.addons
        .map((id) {
          for (final a in addOns) {
            if (a.id == id) return a;
          }
          return null;
        })
        .whereType<AddOn>()
        .toList();

    Future<void> confirm() async {
      final editingId = draft.editingReservationId;
      String confirmedId;
      if (editingId != null) {
        Reservation? existing;
        for (final r in appState.reservations) {
          if (r.id == editingId) {
            existing = r;
            break;
          }
        }
        final ref = draft.bookingRef ??
            existing?.bookingRef ??
            'VEN-${DateTime.now().year}-${Random().nextInt(900) + 100}';
        confirmedId = editingId;
        await appState.updateReservation(
          Reservation(
            id: editingId,
            userId: existing?.userId ?? appState.currentUser?.id,
            packageId: draft.packageId,
            packageName: draft.packageName,
            packageImage: draft.packageImage,
            eventDate: draft.eventDate,
            eventTime: draft.eventTime,
            guests: draft.guests,
            addons: draft.addons,
            basePrice: basePrice,
            addonsPrice: addonsPrice,
            totalPrice: draft.totalPrice,
            status: existing?.status ?? 'confirmed',
            bookingRef: ref,
            createdAt: existing?.createdAt ??
                DateTime.now().toIso8601String().split('T').first,
          ),
        );
      } else {
        final year = DateTime.now().year;
        final ref = 'VEN-$year-${Random().nextInt(900) + 100}';
        confirmedId = 'res-${DateTime.now().millisecondsSinceEpoch}';
        await appState.addReservation(
          Reservation(
            id: confirmedId,
            packageId: draft.packageId,
            packageName: draft.packageName,
            packageImage: draft.packageImage,
            eventDate: draft.eventDate,
            eventTime: draft.eventTime,
            guests: draft.guests,
            addons: draft.addons,
            basePrice: basePrice,
            addonsPrice: addonsPrice,
            totalPrice: draft.totalPrice,
            status: 'confirmed',
            bookingRef: ref,
            createdAt: DateTime.now().toIso8601String().split('T').first,
          ),
        );
      }
      appState.lastConfirmedReservationId = confirmedId;
      appState.setBookingDraft(null);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/booking/success');
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.cream.withOpacity(0.4)),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Edit Booking',
                            style: TextStyle(fontSize: 13)),
                      ),
                      const Text('STEP 2 OF 2',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 3,
                              color: AppColors.gold)),
                      Text('Booking Summary',
                          style: GoogleFonts.cormorantGaramond(
                              fontSize: 28, color: AppColors.cream)),
                      Text(
                        isPreview
                            ? 'Review how this package appears to guests before returning to the dashboard.'
                            : 'Please review your details before confirming',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.cream.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 2,
                width: double.infinity,
                child: DecoratedBox(
                    decoration: BoxDecoration(gradient: goldGradient())),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.gold.withOpacity(0.15))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 160,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  VeneraNetworkImage(url: draft.packageImage),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.95)
                                        ],
                                        stops: const [0.3, 1],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                    child: Text(
                                      draft.packageName,
                                      style: GoogleFonts.cormorantGaramond(
                                          fontSize: 22, color: AppColors.cream),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('EVENT DETAILS', style: _sectionLabel()),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _detailTile('📅', 'Event Date',
                              formatDateLongGb(draft.eventDate)),
                          _divider(),
                          _detailTile('🕐', 'Event Time', draft.eventTime),
                          _divider(),
                          _detailTile('👥', 'Guests', '${draft.guests} guests'),
                          _divider(),
                          _detailTile('👤', 'Reserved For',
                              appState.currentUser?.name ?? 'Guest'),
                        ],
                      ),
                    ),
                    if (addonsDetails.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('SELECTED ADD-ONS', style: _sectionLabel()),
                      const SizedBox(height: 10),
                      ...addonsDetails.map((ao) {
                        final cost = ao.priceType == 'flat'
                            ? ao.price
                            : ao.price * draft.guests;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.gold.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Text(ao.icon,
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(ao.name,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.cream
                                                .withOpacity(0.7)))),
                                Text('+\$${_fmt(cost)}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 20),
                    Text('PRICE BREAKDOWN', style: _sectionLabel()),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1A1508), Color(0xFF100E05)]),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Base Package × ${draft.guests} guests',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.cream.withOpacity(0.6))),
                              Text('\$${_fmt(basePrice)}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.cream.withOpacity(0.8))),
                            ],
                          ),
                          if (addonsPrice > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Add-ons',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.cream
                                              .withOpacity(0.6))),
                                  Text('+\$${_fmt(addonsPrice)}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.cream
                                              .withOpacity(0.8))),
                                ],
                              ),
                            ),
                          Divider(
                              color: AppColors.gold.withOpacity(0.2),
                              height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount',
                                  style: GoogleFonts.cormorantGaramond(
                                      fontSize: 20, color: AppColors.cream)),
                              Text(
                                '\$${_fmt(draft.totalPrice)}',
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cancellation Policy',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gold)),
                                const SizedBox(height: 4),
                                Text(
                                  'Free cancellation up to 30 days before your event. 50% refund within 15–30 days. No refund within 14 days.',
                                  style: TextStyle(
                                      fontSize: 11,
                                      height: 1.7,
                                      color: AppColors.cream.withOpacity(0.4)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: goldGradient(),
                            borderRadius: BorderRadius.circular(100)),
                        child: TextButton(
                          onPressed: isPreview
                              ? () {
                                  appState.setBookingDraft(null);
                                  Navigator.of(context)
                                      .pushReplacementNamed('/admin');
                                }
                              : confirm,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.canvas,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            isPreview
                                ? 'GO BACK TO DASHBOARD'
                                : 'CONFIRM BOOKING',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                fontSize: 14),
                          ),
                        ),
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

  TextStyle _sectionLabel() =>
      const TextStyle(fontSize: 10, letterSpacing: 3, color: AppColors.gold);

  Widget _divider() =>
      Container(height: 1, color: AppColors.gold.withOpacity(0.06));

  Widget _detailTile(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.cream.withOpacity(0.35),
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 2),
                Text(value,
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.cream)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}
