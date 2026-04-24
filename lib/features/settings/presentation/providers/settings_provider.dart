import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyTtsEnabled = 'tts_enabled';
const _keyTtsVolume = 'tts_volume';

class SettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyTtsEnabled) ?? false;
  }

  Future<void> setTtsEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTtsEnabled, value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, bool>(
  SettingsNotifier.new,
);

class TtsVolumeNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_keyTtsVolume) ?? 1.0;
  }

  Future<void> setVolume(double value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTtsVolume, value);
  }
}

final ttsVolumeProvider = NotifierProvider<TtsVolumeNotifier, double>(
  TtsVolumeNotifier.new,
);
