import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';
import '../widgets/venera_network_image.dart';

class ManagePackageScreen extends StatefulWidget {
  const ManagePackageScreen({super.key, this.packageId});

  final String? packageId;

  @override
  State<ManagePackageScreen> createState() => _ManagePackageScreenState();
}

class _ManagePackageScreenState extends State<ManagePackageScreen> {
  late final TextEditingController nameCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController minCtrl;
  late final TextEditingController maxCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController fullDescCtrl;
  late final TextEditingController imageCtrl;
  late final TextEditingController badgeCtrl;
  late final TextEditingController courseCtrl;
  late final TextEditingController includeCtrl;

  late String category;
  late String id;
  late List<String> courses;
  late List<String> includes;
  late double rating;
  late int bookings;

  bool get isEdit => widget.packageId != null && widget.packageId!.isNotEmpty;

  MenuPackage? _existing() {
    if (!isEdit) return null;
    for (final p in appState.packages) {
      if (p.id == widget.packageId) return p;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final ex = _existing();
    id = ex?.id ?? 'pkg${DateTime.now().millisecondsSinceEpoch}';
    category = ex?.category ?? 'Celebration';
    courses = List<String>.from(ex?.courses ?? const []);
    includes = List<String>.from(ex?.includes ?? const []);
    rating = ex?.rating ?? 4.5;
    bookings = ex?.bookings ?? 0;

    nameCtrl = TextEditingController(text: ex?.name ?? '');
    priceCtrl = TextEditingController(
        text: ex == null || ex.pricePerGuest == 0
            ? ''
            : ex.pricePerGuest.toString());
    minCtrl = TextEditingController(text: '${ex?.minGuests ?? 10}');
    maxCtrl = TextEditingController(text: '${ex?.maxGuests ?? 100}');
    descCtrl = TextEditingController(text: ex?.description ?? '');
    fullDescCtrl = TextEditingController(text: ex?.fullDescription ?? '');
    imageCtrl = TextEditingController(
      text: ex?.image ?? 'assets/images/grand_wedding_banquet.jpg',
    );
    badgeCtrl = TextEditingController(text: ex?.badge ?? '');
    courseCtrl = TextEditingController();
    includeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    minCtrl.dispose();
    maxCtrl.dispose();
    descCtrl.dispose();
    fullDescCtrl.dispose();
    imageCtrl.dispose();
    badgeCtrl.dispose();
    courseCtrl.dispose();
    includeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    final description = descCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    if (name.isEmpty || description.isEmpty || price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    final minGuests = int.tryParse(minCtrl.text.trim()) ?? 0;
    final maxGuests = int.tryParse(maxCtrl.text.trim()) ?? 0;
    final badgeText = badgeCtrl.text.trim();
    final pkg = MenuPackage(
      id: id,
      name: name,
      category: category,
      pricePerGuest: price,
      minGuests: minGuests,
      maxGuests: maxGuests,
      description: description,
      fullDescription: fullDescCtrl.text.trim(),
      image: imageCtrl.text.trim(),
      badge: badgeText.isEmpty ? null : badgeText,
      courses: courses,
      includes: includes,
      rating: rating,
      bookings: bookings,
    );

    if (isEdit) {
      appState.updatePackage(widget.packageId!, pkg);
    } else {
      appState.addPackage(pkg);
    }
    Navigator.of(context).pushReplacementNamed('/admin');
  }

  InputDecoration _deco() => InputDecoration(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.2))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.5))),
        hintStyle: TextStyle(color: AppColors.cream.withOpacity(0.25)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.gold)),
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Package' : 'Add New Package',
                          style: GoogleFonts.cormorantGaramond(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cream),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 160),
                  children: [
                    _label('Package Name *'),
                    TextField(
                        controller: nameCtrl,
                        style: const TextStyle(color: AppColors.cream),
                        decoration: _deco()
                            .copyWith(hintText: 'e.g., Grand Wedding Banquet')),
                    const SizedBox(height: 24),
                    _label('Category *'),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      dropdownColor: AppColors.card,
                      decoration: _deco(),
                      style: const TextStyle(color: AppColors.cream),
                      items: const [
                        'Celebration',
                        'Wedding',
                        'Corporate',
                        'Anniversary',
                        'Gala'
                      ]
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => category = v ?? category),
                    ),
                    const SizedBox(height: 24),
                    _label('Price Per Guest (\$) *'),
                    TextField(
                      controller: priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.cream),
                      decoration: _deco().copyWith(hintText: '0'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Min Guests *'),
                              TextField(
                                controller: minCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.cream),
                                decoration: _deco().copyWith(hintText: '10'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Max Guests *'),
                              TextField(
                                controller: maxCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.cream),
                                decoration: _deco().copyWith(hintText: '100'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _label('Short Description *'),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: _deco()
                          .copyWith(hintText: 'Brief description for cards'),
                    ),
                    const SizedBox(height: 24),
                    _label('Full Description'),
                    TextField(
                      controller: fullDescCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: _deco().copyWith(
                          hintText:
                              'Detailed description for package detail page'),
                    ),
                    const SizedBox(height: 24),
                    _label('Image URL'),
                    TextField(
                      controller: imageCtrl,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: _deco()
                          .copyWith(hintText: 'assets/images/package.jpg'),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (imageCtrl.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: VeneraNetworkImage(url: imageCtrl.text)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _label('Badge (Optional)'),
                    TextField(
                      controller: badgeCtrl,
                      style: const TextStyle(color: AppColors.cream),
                      decoration:
                          _deco().copyWith(hintText: 'e.g., Popular, New'),
                    ),
                    const SizedBox(height: 24),
                    _label('Menu Courses'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: courseCtrl,
                            style: const TextStyle(color: AppColors.cream),
                            decoration:
                                _deco().copyWith(hintText: 'Add a course'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final t = courseCtrl.text.trim();
                            if (t.isEmpty) return;
                            setState(() {
                              courses = [...courses, t];
                              courseCtrl.clear();
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.gold.withOpacity(0.15),
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.3)),
                          ),
                          icon: const Icon(Icons.add, color: AppColors.gold),
                        ),
                      ],
                    ),
                    ...courses.asMap().entries.map((e) => _chip(e.value, () {
                          setState(
                              () => courses = [...courses]..removeAt(e.key));
                        })),
                    const SizedBox(height: 24),
                    _label("What's Included"),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: includeCtrl,
                            style: const TextStyle(color: AppColors.cream),
                            decoration:
                                _deco().copyWith(hintText: 'Add an inclusion'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final t = includeCtrl.text.trim();
                            if (t.isEmpty) return;
                            setState(() {
                              includes = [...includes, t];
                              includeCtrl.clear();
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.gold.withOpacity(0.15),
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.3)),
                          ),
                          icon: const Icon(Icons.add, color: AppColors.gold),
                        ),
                      ],
                    ),
                    ...includes.asMap().entries.map((e) => _chip(e.value, () {
                          setState(
                              () => includes = [...includes]..removeAt(e.key));
                        })),
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
                    colors: [
                      AppColors.canvas,
                      AppColors.canvas.withOpacity(0)
                    ]),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.cream.withOpacity(0.6),
                            side: BorderSide(
                                color: AppColors.gold.withOpacity(0.2)),
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
                          decoration: BoxDecoration(
                              gradient: goldGradient(),
                              borderRadius: BorderRadius.circular(100)),
                          child: TextButton(
                            onPressed: _submit,
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.canvas,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14)),
                            child: Text(
                                isEdit ? 'SAVE CHANGES' : 'CREATE PACKAGE',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 10, letterSpacing: 3, color: AppColors.gold)),
      );

  Widget _chip(String text, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(text,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.cream.withOpacity(0.8)))),
            IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close,
                    size: 16, color: AppColors.danger.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}
