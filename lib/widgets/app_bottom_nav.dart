import 'package:flutter/material.dart';

import '../app_state.dart';
import '../navigation.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever [appState] notifies; otherwise the const instance
    // (used by [MaterialApp.builder]) would never pick up route changes.
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => _buildBar(context),
    );
  }

  Widget _buildBar(BuildContext context) {
    final user = appState.currentUser;
    final route = appState.currentRouteName;

    final items = user?.role == 'admin'
        ? const [
            _NavSpec('/admin', 'Dashboard', _gridIcon),
            _NavSpec('/profile', 'Profile', _userIcon),
          ]
        : const [
            _NavSpec('/menu', 'Explore', _homeIcon),
            _NavSpec('/reservations', 'My Reservation', _calendarIcon),
            _NavSpec('/profile', 'Profile', _userIcon),
          ];

    // [Material] ancestor is required by [InkWell] below; the bottom nav lives
    // inside [MaterialApp.builder] which has no Scaffold/Material above it.
    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF0C0A06), Color(0xFF111008)],
        ),
        border: Border(top: BorderSide(color: Color.fromRGBO(201, 168, 76, 0.15))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((spec) {
              final active = route == spec.path;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    final nav = rootNavigatorKey.currentState;
                    if (nav != null) {
                      nav.pushReplacementNamed(spec.path);
                    } else {
                      Navigator.of(context).pushReplacementNamed(spec.path);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      spec.iconBuilder(active),
                      const SizedBox(height: 4),
                      Text(
                        spec.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          letterSpacing: 0.5,
                          color: active ? AppColors.gold : AppColors.muted,
                        ),
                      ),
                      if (active)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 20,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.path, this.label, this.iconBuilder);

  final String path;
  final String label;
  final Widget Function(bool active) iconBuilder;
}

Color _iconColor(bool active) => active ? AppColors.gold : AppColors.muted;
double _stroke(bool active) => active ? 1.8 : 1.5;

Widget _homeIcon(bool active) {
  final c = _iconColor(active);
  return CustomPaint(
    size: const Size(22, 22),
    painter: _HomePainter(color: c, stroke: _stroke(active), fill: active),
  );
}

Widget _calendarIcon(bool active) {
  final c = _iconColor(active);
  return CustomPaint(
    size: const Size(22, 22),
    painter: _CalendarPainter(color: c, stroke: _stroke(active), fill: active),
  );
}

Widget _userIcon(bool active) {
  final c = _iconColor(active);
  return CustomPaint(
    size: const Size(22, 22),
    painter: _UserPainter(color: c, stroke: _stroke(active), fill: active),
  );
}

Widget _gridIcon(bool active) {
  final c = _iconColor(active);
  return CustomPaint(
    size: const Size(22, 22),
    painter: _GridPainter(color: c, stroke: _stroke(active), fill: active),
  );
}

class _HomePainter extends CustomPainter {
  _HomePainter({required this.color, required this.stroke, required this.fill});

  final Color color;
  final double stroke;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(3, 9.5)
      ..lineTo(12, 3)
      ..lineTo(21, 9.5)
      ..lineTo(21, 20)
      ..quadraticBezierTo(21, 21, 20, 21)
      ..lineTo(15, 21)
      ..lineTo(15, 16)
      ..lineTo(9, 16)
      ..lineTo(9, 21)
      ..lineTo(4, 21)
      ..quadraticBezierTo(3, 21, 3, 20)
      ..close();

    if (fill) {
      canvas.drawPath(path, Paint()..color = AppColors.gold.withOpacity(0.1));
    }
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _HomePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke || oldDelegate.fill != fill;
}

class _CalendarPainter extends CustomPainter {
  _CalendarPainter({required this.color, required this.stroke, required this.fill});

  final Color color;
  final double stroke;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final r = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4, 18, 18), const Radius.circular(2));
    if (fill) {
      canvas.drawRRect(r, Paint()..color = AppColors.gold.withOpacity(0.1));
    }
    canvas.drawRRect(r, p..style = PaintingStyle.stroke);

    canvas.drawLine(const Offset(8, 2), const Offset(8, 6), p);
    canvas.drawLine(const Offset(16, 2), const Offset(16, 6), p);
    canvas.drawLine(const Offset(3, 10), const Offset(21, 10), p);

    canvas.drawCircle(const Offset(12, 15), 1.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CalendarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke || oldDelegate.fill != fill;
}

class _UserPainter extends CustomPainter {
  _UserPainter({required this.color, required this.stroke, required this.fill});

  final Color color;
  final double stroke;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    if (fill) {
      canvas.drawCircle(const Offset(12, 8), 4, Paint()..color = AppColors.gold.withOpacity(0.1));
    }
    canvas.drawCircle(const Offset(12, 8), 4, p);

    final body = Path()..moveTo(4, 20);
    body.cubicTo(4, 17, 7.58, 14, 12, 14);
    body.cubicTo(16.42, 14, 20, 17, 20, 20);
    canvas.drawPath(body, p);
  }

  @override
  bool shouldRepaint(covariant _UserPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke || oldDelegate.fill != fill;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color, required this.stroke, required this.fill});

  final Color color;
  final double stroke;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    void cell(double x, double y) {
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 7, 7), const Radius.circular(1));
      if (fill) {
        canvas.drawRRect(r, Paint()..color = AppColors.gold.withOpacity(0.1));
      }
      canvas.drawRRect(r, p);
    }

    cell(3, 3);
    cell(14, 3);
    cell(3, 14);
    cell(14, 14);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke || oldDelegate.fill != fill;
}
