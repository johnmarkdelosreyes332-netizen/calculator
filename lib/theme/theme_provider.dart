import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'is_dark_mode';
  static const _accentKey = 'accent_color';

  late final Future<void> _ready;
  bool _isDarkMode = true;
  AppAccent _accent = AppAccent.gold;
  bool _isDisposed = false;
  String? _error;

  ThemeProvider() {
    _ready = _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  AppAccent get accent => _accent;
  String? get error => _error;
  Future<void> get ready => _ready;

  Future<bool> toggleTheme() async {
    await _ready;
    _isDarkMode = !_isDarkMode;
    _error = null;
    _notifyIfAlive();

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setBool(_themeKey, _isDarkMode);
      if (!saved) {
        _error = 'Theme preference could not be saved.';
        _notifyIfAlive();
        return false;
      }
      return true;
    } on PlatformException catch (error, stackTrace) {
      _reportError(error, stackTrace);
      return false;
    } on MissingPluginException catch (error, stackTrace) {
      _reportError(error, stackTrace);
      return false;
    }
  }

  Future<bool> setAccent(AppAccent accent) async {
    await _ready;
    _accent = accent;
    _error = null;
    _notifyIfAlive();

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(_accentKey, accent.name);
      if (!saved) {
        _error = 'Color preference could not be saved.';
        _notifyIfAlive();
        return false;
      }
      return true;
    } on PlatformException catch (error, stackTrace) {
      _reportError(error, stackTrace);
      return false;
    } on MissingPluginException catch (error, stackTrace) {
      _reportError(error, stackTrace);
      return false;
    }
  }

  Future<void> _loadTheme() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _isDarkMode = preferences.getBool(_themeKey) ?? true;
      final savedAccent = preferences.getString(_accentKey);
      _accent = AppAccent.values.firstWhere(
        (accent) => accent.name == savedAccent,
        orElse: () => AppAccent.gold,
      );
      _notifyIfAlive();
    } on PlatformException catch (error, stackTrace) {
      _reportError(error, stackTrace);
    } on MissingPluginException catch (error, stackTrace) {
      _reportError(error, stackTrace);
    }
  }

  void _reportError(Object error, StackTrace stackTrace) {
    debugPrint('Could not access saved theme preference: $error\n$stackTrace');
    _error = 'Theme preference could not be saved.';
    _notifyIfAlive();
  }

  void _notifyIfAlive() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
