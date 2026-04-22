import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyTtsEnabled = 'tts_enabled';

class SettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true; // default: TTS enabled
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyTtsEnabled) ?? true;
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
