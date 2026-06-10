import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.packageId,
    this.editingReservation,
  });

  final String packageId;

  /// When non-null, the form prefills with this reservation's values and
  /// confirming updates the reservation instead of creating a new one.
  final Reservation? editingReservation;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? eventDate;
  String? time;
  late int guests;
  late String packageId;
  final Set<String> selectedAddons = {};
  final timeSlots = const [
    '10:00 AM',
    '12:00 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
    '8:00 PM'
  ];

  bool get isEditing => widget.editingReservation != null;

  MenuPackage? _package() {
    for (final p in appState.packages) {
      if (p.id == packageId) return p;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    packageId = widget.packageId;
    final existing = widget.editingReservation;
    if (existing != null) {
      guests = existing.guests;
      time = existing.eventTime;
      eventDate = DateTime.tryParse(existing.eventDate);
      selectedAddons.addAll(existing.addons);
    } else {
      guests = _package()?.minGuests ?? 20;
    }
  }

  /// Show a bottom sheet of all packages and switch to the selected one.
  /// Re-clamps the guest count into the new package's min/max range so the
  /// price recalculation stays valid.
  Future<void> _pickPackage() async {
    final selected = await showModalBottomSheet<MenuPackage>(
      context: context,
      backgroundColor: AppColors.canvas,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final all = appState.packages;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Change Package',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Switching will recalculate your price.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cream.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: all.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = all[i];
                      final active = p.id == packageId;
                      return InkWell(
                        onTap: () => Navigator.of(ctx).pop(p),
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? AppColors.gold
                                  : AppColors.gold.withOpacity(0.12),
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.cream),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.category} · \$${p.pricePerGuest.toStringAsFixed(0)}/guest · ${p.minGuests}–${p.maxGuests} guests',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.cream.withOpacity(0.45),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (active)
                                const Icon(Icons.check_circle,
                                    color: AppColors.gold, size: 18)
                              else
                                Icon(Icons.chevron_right,
                                    color: AppColors.cream.withOpacity(0.3)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected.id == packageId) return;
    setState(() {
      packageId = selected.id;
      guests = guests.clamp(selected.minGuests, selected.maxGuests);
    });
  }

  double _addonsTotal(MenuPackage p) {
    var sum = 0.0;
    for (final id in selectedAddons) {
      AddOn? ao;
      for (final a in addOns) {
        if (a.id == id) {
          ao = a;
          break;
        }
      }
      if (ao == null) continue;
      sum += ao.priceType == 'flat' ? ao.price : ao.price * guests;
    }
    return sum;
  }

  void _proceed(MenuPackage p) {
    if (eventDate == null || time == null) return;
    final dateStr =
        '${eventDate!.year.toString().padLeft(4, '0')}-${eventDate!.month.toString().padLeft(2, '0')}-${eventDate!.day.toString().padLeft(2, '0')}';
    final base = p.pricePerGuest * guests;
    final addons = _addonsTotal(p);
    appState.setBookingDraft(
      BookingDraft(
        packageId: p.id,
        packageName: p.name,
        packageImage: p.image,
        pricePerGuest: p.pricePerGuest,
        eventDate: dateStr,
        eventTime: time!,
        guests: guests,
        addons: selectedAddons.toList(),
        totalPrice: base + addons,
        editingReservationId: widget.editingReservation?.id,
        bookingRef: widget.editingReservation?.bookingRef,
        packagePreviewOnly:
            appState.packagePreviewMode && widget.editingReservation == null,
      ),
    );
    Navigator.of(context).pushNamed('/booking/summary');
  }

  Future<void> _pickDate(MenuPackage p) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: eventDate ?? first,
      firstDate: first,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
                primary: AppColors.gold, onPrimary: AppColors.canvas),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => eventDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final p = _package();
    if (p == null) return const SizedBox.shrink();

    final baseTotal = p.pricePerGuest * guests;
    final addonsTotal = _addonsTotal(p);
    final grandTotal = baseTotal + addonsTotal;
    final canProceed = eventDate != null && time != null;

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
                        label: const Text('Back to Package',
                            style: TextStyle(fontSize: 13)),
                      ),
                      const Text(
                        'STEP 1 OF 2',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 3,
                            color: AppColors.gold),
                      ),
                      Text(
                        isEditing ? 'Edit Your Booking' : 'Book Your Event',
                        style: GoogleFonts.cormorantGaramond(
                            fontSize: 28, color: AppColors.cream),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.name,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.cream.withOpacity(0.4))),
                          ),
                          TextButton.icon(
                            onPressed: _pickPackage,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              foregroundColor: AppColors.gold,
                            ),
                            icon: const Icon(Icons.swap_horiz, size: 14),
                            label: const Text(
                              'Change Package',
                              style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 2,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(color: AppColors.card),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                            height: 2,
                            decoration:
                                BoxDecoration(gradient: goldGradient())),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
                  children: [
                    _sectionTitle('Event Date & Time'),
                    Text('EVENT DATE', style: _labelStyle()),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _pickDate(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16,
                                color: AppColors.cream.withOpacity(0.35)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                eventDate == null
                                    ? 'Select date'
                                    : '${eventDate!.year}-${eventDate!.month.toString().padLeft(2, '0')}-${eventDate!.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.cream),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('PREFERRED TIME', style: _labelStyle()),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeSlots.map((slot) {
                        final active = time == slot;
                        return OutlinedButton(
                          onPressed: () => setState(() => time = slot),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: active
                                ? AppColors.gold
                                : AppColors.cream.withOpacity(0.5),
                            side: BorderSide(
                                color: active
                                    ? AppColors.gold
                                    : AppColors.gold.withOpacity(0.15)),
                            backgroundColor: active
                                ? AppColors.gold.withOpacity(0.12)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child:
                              Text(slot, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    _sectionTitle('Number of Guests'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$guests',
                                      style: GoogleFonts.cormorantGaramond(
                                          fontSize: 36,
                                          color: AppColors.gold,
                                          height: 1),
                                    ),
                                    Text(
                                      'guests (min. ${p.minGuests}, max. ${p.maxGuests})',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              AppColors.cream.withOpacity(0.4)),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _GuestButton(
                                    label: '−',
                                    onTap: () => setState(() => guests =
                                        (guests - 5)
                                            .clamp(p.minGuests, p.maxGuests)),
                                  ),
                                  const SizedBox(width: 8),
                                  _GuestButton(
                                    label: '+',
                                    onTap: () => setState(() => guests =
                                        (guests + 5)
                                            .clamp(p.minGuests, p.maxGuests)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Slider(
                            value: guests.toDouble().clamp(
                                p.minGuests.toDouble(), p.maxGuests.toDouble()),
                            min: p.minGuests.toDouble(),
                            max: p.maxGuests.toDouble(),
                            divisions: p.maxGuests > p.minGuests
                                ? ((p.maxGuests - p.minGuests) ~/ 5)
                                    .clamp(1, 1000)
                                : 1,
                            onChanged: (v) => setState(() {
                              final snapped = ((v.round() / 5).round() * 5)
                                  .clamp(p.minGuests, p.maxGuests);
                              guests = snapped;
                            }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p.minGuests}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.cream.withOpacity(0.3))),
                              Text('${p.maxGuests}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.cream.withOpacity(0.3))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _sectionTitle('Optional Add-ons'),
                    ...addOns.map((ao) {
                      final selected = selectedAddons.contains(ao.id);
                      final cost =
                          ao.priceType == 'flat' ? ao.price : ao.price * guests;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => setState(() {
                            if (selected) {
                              selectedAddons.remove(ao.id);
                            } else {
                              selectedAddons.add(ao.id);
                            }
                          }),
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.gold.withOpacity(0.05)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.gold.withOpacity(0.35)
                                    : AppColors.gold.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(ao.icon,
                                    style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ao.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.cream)),
                                      const SizedBox(height: 2),
                                      Text(ao.description,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.cream
                                                  .withOpacity(0.4))),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '+\$${_formatMoney(cost)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? AppColors.gold
                                            : AppColors.cream.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      ao.priceType == 'flat'
                                          ? 'FLAT FEE'
                                          : '/GUEST',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color:
                                              AppColors.cream.withOpacity(0.3),
                                          letterSpacing: 1),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? AppColors.gold
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: selected
                                            ? AppColors.gold
                                            : AppColors.gold.withOpacity(0.3),
                                        width: 1.5),
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check,
                                          size: 12, color: AppColors.canvas)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    _sectionTitle('Price Calculation'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1A1508), Color(0xFF111008)]),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _priceLine(
                            'Base Package × $guests guests',
                            '\$${_formatMoney(baseTotal)}',
                            '\$${p.pricePerGuest.toStringAsFixed(0)}/guest',
                          ),
                          ...selectedAddons.map((id) {
                            AddOn? ao;
                            for (final a in addOns) {
                              if (a.id == id) {
                                ao = a;
                                break;
                              }
                            }
                            if (ao == null) return const SizedBox.shrink();
                            final c = ao.priceType == 'flat'
                                ? ao.price
                                : ao.price * guests;
                            return _priceLine(
                              ao.name,
                              '+\$${_formatMoney(c)}',
                              ao.priceType == 'flat'
                                  ? 'flat fee'
                                  : '\$${ao.price.toStringAsFixed(0)}/guest',
                            );
                          }),
                          Divider(
                              color: AppColors.gold.withOpacity(0.15),
                              height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Estimate',
                                  style: GoogleFonts.cormorantGaramond(
                                      fontSize: 18, color: AppColors.cream)),
                              Text(
                                '\$${_formatMoney(grandTotal)}',
                                style: GoogleFonts.cormorantGaramond(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold),
                              ),
                            ],
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: canProceed ? goldGradient() : null,
                      color:
                          canProceed ? null : AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextButton(
                      onPressed: canProceed ? () => _proceed(p) : null,
                      style: TextButton.styleFrom(
                        foregroundColor: canProceed
                            ? AppColors.canvas
                            : AppColors.gold.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        canProceed
                            ? 'PREVIEW SUMMARY · \$${_formatMoney(grandTotal)}'
                            : 'SELECT DATE & TIME TO CONTINUE',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontSize: 13),
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

  TextStyle _labelStyle() => TextStyle(
        fontSize: 11,
        color: AppColors.cream.withOpacity(0.4),
        letterSpacing: 1.5,
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
                width: 16, height: 1, color: AppColors.gold.withOpacity(0.5)),
            const SizedBox(width: 12),
            Text(t.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10, letterSpacing: 3, color: AppColors.gold)),
            const SizedBox(width: 12),
            Expanded(
                child: Container(
                    height: 1, color: AppColors.gold.withOpacity(0.15))),
          ],
        ),
      );

  Widget _priceLine(String label, String value, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.cream.withOpacity(0.7))),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.cream.withOpacity(0.3))),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withOpacity(0.8))),
        ],
      ),
    );
  }

  String _formatMoney(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}

class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withOpacity(0.15)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 18, color: AppColors.gold)),
      ),
    );
  }
}
