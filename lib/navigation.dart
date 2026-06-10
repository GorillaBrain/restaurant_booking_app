import 'package:flutter/material.dart';

/// Stable across [MaterialApp] rebuilds (e.g. when [AppState] notifies listeners).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
