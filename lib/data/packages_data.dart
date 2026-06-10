// Ported from `src/app/data/packages.ts`.

class AddOn {
  const AddOn({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceType,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String priceType; // 'per_guest' | 'flat'
  final String icon;
}

class MenuPackage {
  const MenuPackage({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerGuest,
    required this.minGuests,
    required this.maxGuests,
    required this.description,
    required this.fullDescription,
    required this.image,
    this.badge,
    required this.courses,
    required this.includes,
    required this.rating,
    required this.bookings,
  });

  final String id;
  final String name;
  final String category;
  final double pricePerGuest;
  final int minGuests;
  final int maxGuests;
  final String description;
  final String fullDescription;
  final String image;
  final String? badge;
  final List<String> courses;
  final List<String> includes;
  final double rating;
  final int bookings;

  MenuPackage copyWith({
    String? id,
    String? name,
    String? category,
    double? pricePerGuest,
    int? minGuests,
    int? maxGuests,
    String? description,
    String? fullDescription,
    String? image,
    String? badge,
    List<String>? courses,
    List<String>? includes,
    double? rating,
    int? bookings,
  }) {
    return MenuPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      pricePerGuest: pricePerGuest ?? this.pricePerGuest,
      minGuests: minGuests ?? this.minGuests,
      maxGuests: maxGuests ?? this.maxGuests,
      description: description ?? this.description,
      fullDescription: fullDescription ?? this.fullDescription,
      image: image ?? this.image,
      badge: badge ?? this.badge,
      courses: courses ?? List<String>.from(this.courses),
      includes: includes ?? List<String>.from(this.includes),
      rating: rating ?? this.rating,
      bookings: bookings ?? this.bookings,
    );
  }
}

class Reservation {
  const Reservation({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.packageImage,
    required this.eventDate,
    required this.eventTime,
    required this.guests,
    required this.addons,
    required this.basePrice,
    required this.addonsPrice,
    required this.totalPrice,
    required this.status,
    required this.bookingRef,
    required this.createdAt,
    this.userId,
  });

  final String id;
  final String packageId;
  final String packageName;
  final String packageImage;
  final String eventDate;
  final String eventTime;
  final int guests;
  final List<String> addons;
  final double basePrice;
  final double addonsPrice;
  final double totalPrice;
  final String status; // confirmed | pending | cancelled
  final String bookingRef;
  final String createdAt;

  /// Owning user id (FK → `users.id`). May be `null` for legacy / seed rows.
  final String? userId;

  Reservation copyWith({String? status, String? userId}) {
    return Reservation(
      id: id,
      packageId: packageId,
      packageName: packageName,
      packageImage: packageImage,
      eventDate: eventDate,
      eventTime: eventTime,
      guests: guests,
      addons: addons,
      basePrice: basePrice,
      addonsPrice: addonsPrice,
      totalPrice: totalPrice,
      status: status ?? this.status,
      bookingRef: bookingRef,
      createdAt: createdAt,
      userId: userId ?? this.userId,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.bookings,
    required this.joinedAt,
    this.blocked,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final int bookings;
  final String joinedAt;
  final bool? blocked;

  AppUser copyWith({bool? blocked}) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role,
      bookings: bookings,
      joinedAt: joinedAt,
      blocked: blocked ?? this.blocked,
    );
  }
}

class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;
}

class BookingDraft {
  const BookingDraft({
    required this.packageId,
    required this.packageName,
    required this.packageImage,
    required this.pricePerGuest,
    required this.eventDate,
    required this.eventTime,
    required this.guests,
    required this.addons,
    required this.totalPrice,
    this.bookingRef,
    this.editingReservationId,
    this.packagePreviewOnly = false,
  });

  final String packageId;
  final String packageName;
  final String packageImage;
  final double pricePerGuest;
  final String eventDate;
  final String eventTime;
  final int guests;
  final List<String> addons;
  final double totalPrice;
  final String? bookingRef;

  /// When non-null, confirming the draft updates an existing reservation
  /// instead of inserting a new one.
  final String? editingReservationId;

  /// Admin package "View" flow — walk through booking UI without saving.
  final bool packagePreviewOnly;
}

const List<AddOn> addOns = [
  AddOn(
    id: 'ao1',
    name: 'Premium Floral Arrangements',
    description: 'Bespoke floral centerpieces and décor',
    price: 45,
    priceType: 'per_guest',
    icon: '🌸',
  ),
  AddOn(
    id: 'ao3',
    name: 'Professional Photography',
    description: 'Full-event coverage with edited gallery',
    price: 1200,
    priceType: 'flat',
    icon: '📸',
  ),
  AddOn(
    id: 'ao4',
    name: 'Custom Celebration Cake',
    description: 'Artisan multi-tier cake by our pastry chef',
    price: 450,
    priceType: 'flat',
    icon: '🎂',
  ),
  AddOn(
    id: 'ao5',
    name: 'Premium Open Bar',
    description: 'Curated cocktails, fine wines & spirits',
    price: 75,
    priceType: 'per_guest',
    icon: '🍾',
  ),
  AddOn(
    id: 'ao6',
    name: 'Personalized Menu Cards',
    description: 'Gold-foil embossed menu cards per guest',
    price: 12,
    priceType: 'per_guest',
    icon: '📜',
  ),
];

final List<MenuPackage> initialMenuPackages = [
  const MenuPackage(
    id: 'pkg1',
    name: 'Grand Wedding Banquet',
    category: 'Wedding',
    pricePerGuest: 285,
    minGuests: 50,
    maxGuests: 300,
    description:
        'An opulent five-course dining experience designed for your most special day.',
    fullDescription:
        'Transform your wedding day into a culinary masterpiece. Our Grand Wedding Banquet offers a meticulously crafted five-course dinner, featuring the finest seasonal ingredients, paired with an exceptional wine selection. Every detail is curated to reflect elegance and romance, from the hand-poured amuse-bouche to the decadent dessert finale.',
    image: 'assets/images/grand_wedding_banquet.jpg',
    badge: 'Most Popular',
    courses: [
      'Champagne & Canapé Reception',
      'Chilled Lobster Bisque with Crème Fraîche',
      'Pan-Seared Foie Gras with Brioche Toast',
      'Sorbet Intermezzo',
      'Wagyu Beef Tenderloin with Truffle Jus',
      'Seasonal Cheese Selection',
      'Wedding Dessert Showcase',
    ],
    includes: [
      'Dedicated event coordinator',
      'Custom table linen & centrepieces',
      'Sommelier wine pairing',
      'Bridal suite access',
      'Complimentary tasting session',
    ],
    rating: 4.9,
    bookings: 247,
  ),
  const MenuPackage(
    id: 'pkg2',
    name: 'Executive Corporate Dinner',
    category: 'Corporate',
    pricePerGuest: 245,
    minGuests: 20,
    maxGuests: 150,
    description:
        'Impress clients and colleagues with a distinguished four-course dinner experience.',
    fullDescription:
        'Elevate your corporate events with our Executive Corporate Dinner package. Designed for business gatherings where impression matters, this package offers a sophisticated four-course meal with seamless AV integration, private dining rooms, and a dedicated service team ensuring absolute professionalism throughout your event.',
    image: 'assets/images/executive_corporate_dinner.jpg',
    badge: 'Business Choice',
    courses: [
      'Welcome Aperitif & Canapés',
      'Seared Scallops with Pea Purée',
      'Wild Mushroom Velouté',
      'Prime Beef Fillet or Pan-Roasted Sea Bass',
      'Artisan Cheese & Charcuterie',
      'Chocolate Fondant with Gold Leaf',
    ],
    includes: [
      'Private dining room',
      'AV equipment & presentation screens',
      'Dedicated event manager',
      'Branded menu cards',
      'Pre-event cocktail reception',
    ],
    rating: 4.8,
    bookings: 189,
  ),
  const MenuPackage(
    id: 'pkg3',
    name: 'Black Tie Gala',
    category: 'Gala',
    pricePerGuest: 320,
    minGuests: 100,
    maxGuests: 500,
    description:
        'The ultimate luxury gala experience with six courses and live entertainment.',
    fullDescription:
        'Our Black Tie Gala package is the pinnacle of refined entertaining. Designed for grand-scale events requiring the highest standard of service and cuisine, this six-course extravaganza is complemented by a champagne tower, live entertainment options, and our finest wine cellar selections. An evening your guests will remember forever.',
    image: 'assets/images/black_tie_gala.jpg',
    badge: 'Ultra Premium',
    courses: [
      'Champagne Tower & Caviar Reception',
      'Blue Fin Tuna Tartare',
      'Truffle-Scented Consommé',
      'Granite & Herb Sorbet',
      'Wagyu A5 Striploin with Black Truffle',
      'Valrhona Chocolate Experience',
      'Mignardises & Petits Fours',
    ],
    includes: [
      'Grand ballroom access',
      'Champagne tower installation',
      'Full lighting & décor design',
      'Personal butler per table',
      'Luxury gift bags',
      'Dedicated security team',
    ],
    rating: 5.0,
    bookings: 94,
  ),
  const MenuPackage(
    id: 'pkg4',
    name: 'Signature Tasting Experience',
    category: 'Celebration',
    pricePerGuest: 165,
    minGuests: 10,
    maxGuests: 40,
    description:
        "An intimate seven-course chef's tasting menu for memorable celebrations.",
    fullDescription:
        "For those who seek the extraordinary, our Signature Tasting Experience brings the chef's table into your private event. This intimate seven-course tasting journey showcases our chef's seasonal inspirations, with each dish narrated and expertly paired with natural wines. Perfect for birthdays, milestones, and intimate celebrations.",
    image: 'assets/images/signature_tasting.jpg',
    courses: [
      'Amuse-Bouche Trio',
      'Market Garden Salad with Aged Balsamic',
      'Chilled Lobster with Citrus Dressing',
      'Handmade Pasta with Seasonal Truffle',
      'Palate Cleanser',
      'Dry-Aged Duck Breast with Cherry Jus',
      'Cheese Trolley Selection',
      'Artistic Dessert Creation',
    ],
    includes: [
      "Chef's personal introduction",
      'Curated natural wine flight',
      'Printed tasting notes',
      'Kitchen tour option',
      'Signed menu keepsake',
    ],
    rating: 4.9,
    bookings: 312,
  ),
  const MenuPackage(
    id: 'pkg5',
    name: 'Royal Anniversary Dinner',
    category: 'Anniversary',
    pricePerGuest: 225,
    minGuests: 2,
    maxGuests: 60,
    description:
        'Celebrate your love story with a bespoke romantic dining experience.',
    fullDescription:
        'Our Royal Anniversary Dinner is crafted for couples and intimate gatherings celebrating love and togetherness. From rose petal décor to a bespoke couple\'s menu, every element is designed to evoke romance and luxury. Begin with a private champagne reception and end with a personalised dessert message from our pastry team.',
    image: 'assets/images/royal_anniversary.jpg',
    badge: 'Romantic',
    courses: [
      'Private Champagne & Rose Reception',
      'Oysters with Mignonette',
      'Bisque of Native Lobster',
      'Seared Foie Gras with Peach Compote',
      'Wagyu Fillet with Bone Marrow',
      'Artisan Cheese Selection',
      'Bespoke Anniversary Dessert',
    ],
    includes: [
      'Private candlelit dining room',
      'Rose petal décor',
      'Personalised dessert message',
      'Complimentary bottle of Moët',
      'Polaroid photo keepsake',
    ],
    rating: 4.8,
    bookings: 156,
  ),
  const MenuPackage(
    id: 'pkg6',
    name: 'The Neptune Seafood Feast',
    category: 'Celebration',
    pricePerGuest: 195,
    minGuests: 15,
    maxGuests: 80,
    description:
        'A spectacular ocean-to-table celebration with the finest sustainable seafood.',
    fullDescription:
        'Dive into an extraordinary seafood celebration with our Neptune Feast package. Sourced from sustainable fisheries and delivered fresh daily, each course showcases the ocean\'s finest offerings. From Alaskan king crab to whole-roasted turbot, this package is a tribute to the sea, presented with theatrical flair and refined technique.',
    image: 'assets/images/neptune_seafood.jpg',
    courses: [
      'Oyster & Champagne Welcome',
      'Alaskan King Crab Cocktail',
      'Bouillabaisse with Saffron Rouille',
      'Lobster Thermidor Interlude',
      'Whole-Roasted Turbot with Herb Butter',
      'Saffron Panna Cotta with Caviar',
    ],
    includes: [
      'Seafood display centrepiece',
      'White wine & champagne pairing',
      'Ice sculpture centrepiece',
      'Dedicated seafood sommelier',
      'Printed provenance cards',
    ],
    rating: 4.7,
    bookings: 108,
  ),
];

final List<Reservation> mockReservations = [
  const Reservation(
    id: 'res1',
    packageId: 'pkg1',
    packageName: 'Grand Wedding Banquet',
    packageImage: 'assets/images/grand_wedding_banquet.jpg',
    eventDate: '2026-06-14',
    eventTime: '19:00',
    guests: 80,
    addons: ['ao1', 'ao5'],
    basePrice: 285 * 80,
    addonsPrice: (45 + 75) * 80,
    totalPrice: 285 * 80 + (45 + 75) * 80,
    status: 'confirmed',
    bookingRef: 'VEN-2024-001',
    createdAt: '2026-03-10',
    userId: 'u-demo',
  ),
  const Reservation(
    id: 'res2',
    packageId: 'pkg4',
    packageName: 'Signature Tasting Experience',
    packageImage: 'assets/images/signature_tasting.jpg',
    eventDate: '2026-05-22',
    eventTime: '20:00',
    guests: 12,
    addons: [],
    basePrice: 165 * 12,
    addonsPrice: 0,
    totalPrice: 165 * 12,
    status: 'confirmed',
    bookingRef: 'VEN-2024-002',
    createdAt: '2026-04-01',
    userId: 'u-demo',
  ),
  const Reservation(
    id: 'res3',
    packageId: 'pkg2',
    packageName: 'Executive Corporate Dinner',
    packageImage: 'assets/images/executive_corporate_dinner.jpg',
    eventDate: '2026-02-28',
    eventTime: '19:30',
    guests: 40,
    addons: ['ao3'],
    basePrice: 245 * 40,
    addonsPrice: 1200,
    totalPrice: 245 * 40 + 1200,
    status: 'cancelled',
    bookingRef: 'VEN-2024-003',
    createdAt: '2026-01-15',
    userId: 'u-demo',
  ),
];

final List<AppUser> mockUsers = [
  const AppUser(
      id: 'u1',
      name: 'Eleanor Whitmore',
      email: 'eleanor@example.com',
      role: 'user',
      bookings: 3,
      joinedAt: '2025-11-12'),
  const AppUser(
      id: 'u2',
      name: 'James Blackwell',
      email: 'james@example.com',
      role: 'user',
      bookings: 1,
      joinedAt: '2026-01-08'),
  const AppUser(
      id: 'u3',
      name: 'Sofia Marchetti',
      email: 'sofia@example.com',
      role: 'user',
      bookings: 5,
      joinedAt: '2025-09-03'),
  const AppUser(
      id: 'u5',
      name: 'Isabelle Laurent',
      email: 'isabelle@example.com',
      role: 'user',
      bookings: 2,
      joinedAt: '2026-02-14'),
];
