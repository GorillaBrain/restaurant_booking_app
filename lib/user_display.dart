/// Single visible letter for avatar chips (avoids fragile `user!` promotion).
String userAvatarLetter(String? name) {
  final t = name?.trim();
  if (t == null || t.isEmpty) return 'G';
  return t[0].toUpperCase();
}
