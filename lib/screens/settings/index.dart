import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spitball/screens/settings/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Swipe Mode'),
            subtitle: const Text('Enable swipe gestures for moves instead of two taps.'),
            value: settings.swipeMode,
            onChanged: (bool value) {
              settingsNotifier.setSwipeMode(value);
            },
          ),
          SwitchListTile(
            title: const Text('Bouncing Balls Animation'),
            subtitle: const Text('Enable bouncing animation for selected balls.'),
            value: settings.bouncingBalls,
            onChanged: (bool value) {
              settingsNotifier.setBouncingBalls(value);
            },
          ),
          // Add more settings here if needed
        ],
      ),
    );
  }
}
