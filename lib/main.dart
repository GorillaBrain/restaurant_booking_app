import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_state.dart';
import 'navigation.dart';
import 'theme/app_colors.dart';
import 'theme/venera_theme.dart';
import 'widgets/app_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  runApp(const VeneraApp());
}

class VeneraApp extends StatelessWidget {
  const VeneraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'Venera Private Dining',
          debugShowCheckedModeBanner: false,
          theme: buildVeneraTheme(),
          initialRoute: '/',
          onGenerateRoute: onGenerateAppRoute,
          builder: (context, child) {
            final showNav = shouldShowBottomNav(appState.currentRouteName);
            return ColoredBox(
              color: AppColors.outerBg,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: DecoratedBox(
                    decoration: phoneFrameDecoration(),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: showNav ? 72 : 0),
                          child: child ?? const SizedBox.shrink(),
                        ),
                        if (showNav)
                          const Align(
                              alignment: Alignment.bottomCenter,
                              child: AppBottomNav()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
