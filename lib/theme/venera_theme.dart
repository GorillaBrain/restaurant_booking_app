import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildVeneraTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: AppColors.canvas,
    splashColor: AppColors.gold.withOpacity(0.12),
    highlightColor: AppColors.gold.withOpacity(0.08),
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.cream,
    displayColor: AppColors.cream,
  );

  final display = GoogleFonts.cormorantGaramondTextTheme(textTheme).copyWith(
    displayLarge: GoogleFonts.cormorantGaramond(
      fontWeight: FontWeight.w300,
      color: AppColors.cream,
    ),
    headlineMedium: GoogleFonts.cormorantGaramond(
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
    ),
    titleLarge: GoogleFonts.cormorantGaramond(
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
    ),
  );

  return base.copyWith(
    textTheme: textTheme.copyWith(
      displayLarge: display.displayLarge,
      headlineMedium: display.headlineMedium,
      titleLarge: display.titleLarge,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.goldLight,
      surface: AppColors.card,
      onPrimary: AppColors.canvas,
      onSurface: AppColors.cream,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      foregroundColor: AppColors.cream,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.5)),
      ),
      labelStyle: TextStyle(
        color: AppColors.cream.withOpacity(0.4),
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.gold,
      inactiveTrackColor: AppColors.gold.withOpacity(0.2),
      thumbColor: AppColors.gold,
      overlayColor: AppColors.gold.withOpacity(0.12),
    ),
  );
}

/// `en-GB` style long dates used by the React app.
String formatDateLongGb(String isoDate) {
  final d = DateTime.tryParse(isoDate);
  if (d == null) return isoDate;
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final wd = weekdays[d.weekday - 1];
  final m = months[d.month - 1];
  return '$wd, ${d.day} $m ${d.year}';
}

String formatDateShortGb(String isoDate) {
  final d = DateTime.tryParse(isoDate);
  if (d == null) return isoDate;
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

LinearGradient goldGradient() {
  return const LinearGradient(
    colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

Widget goldGradientText(String text, {TextStyle? style, TextAlign? textAlign}) {
  return ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => goldGradient().createShader(bounds),
    child: Text(text, style: style, textAlign: textAlign),
  );
}

BoxDecoration phoneFrameDecoration() {
  return BoxDecoration(
    color: AppColors.canvas,
    border: Border.all(color: AppColors.gold.withOpacity(0.05)),
    boxShadow: [
      BoxShadow(
        color: AppColors.gold.withOpacity(0.06),
        blurRadius: 80,
        spreadRadius: 0,
      ),
    ],
  );
}
