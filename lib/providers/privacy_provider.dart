import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyNotifier extends StateNotifier<bool> {
  PrivacyNotifier() : super(false) {
    _loadState();
  }

  static const _key = 'is_balance_hidden';

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggleVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final nextState = !state;
    await prefs.setBool(_key, nextState);
    state = nextState;
  }
}

final privacyProvider = StateNotifierProvider<PrivacyNotifier, bool>((ref) {
  return PrivacyNotifier();
});
