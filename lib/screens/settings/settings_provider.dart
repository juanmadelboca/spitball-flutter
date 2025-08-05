import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for shared preferences
const String swipeModeKey = 'settings_swipeMode';
const String bouncingBallsKey = 'settings_bouncingBalls';

// Notifier for settings state
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      swipeMode: prefs.getBool(swipeModeKey) ?? true, // Default to true
      bouncingBalls: prefs.getBool(bouncingBallsKey) ?? true, // Default to true
    );
  }

  Future<void> setSwipeMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(swipeModeKey, value);
    state = state.copyWith(swipeMode: value);
  }

  Future<void> setBouncingBalls(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(bouncingBallsKey, value);
    state = state.copyWith(bouncingBalls: value);
  }
}

// State class for app settings
class AppSettings {
  final bool swipeMode;
  final bool bouncingBalls;

  const AppSettings({this.swipeMode = true, this.bouncingBalls = true});

  AppSettings copyWith({
    bool? swipeMode,
    bool? bouncingBalls,
  }) {
    return AppSettings(
      swipeMode: swipeMode ?? this.swipeMode,
      bouncingBalls: bouncingBalls ?? this.bouncingBalls,
    );
  }
}

// Provider for SettingsNotifier
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
