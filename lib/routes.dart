import 'package:flutter/cupertino.dart';
import 'package:spitball/features/menu/presentation/pages/menu.dart';

var duration = const Duration(milliseconds: 300);

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case MainMenuScreen.routeName:
      return CupertinoPageRoute(
        builder: (_) => const MainMenuScreen(),
        settings: settings,
      );
    default:
      return CupertinoPageRoute(
        builder: (_) => const MainMenuScreen(),
        settings: settings,
      );
  }
}