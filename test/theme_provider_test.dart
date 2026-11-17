import 'package:flutter_test/flutter_test.dart';
import 'package:gold_calculator/theme/app_theme.dart';
import 'package:gold_calculator/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads and persists the selected theme', () async {
    SharedPreferences.setMockInitialValues({'is_dark_mode': false});
    final themeProvider = ThemeProvider();
    await themeProvider.ready;

    expect(themeProvider.isDarkMode, isFalse);

    expect(await themeProvider.toggleTheme(), isTrue);
    expect(themeProvider.isDarkMode, isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('is_dark_mode'), isTrue);
    themeProvider.dispose();
  });

  test('loads and persists the selected accent color', () async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();
    await themeProvider.ready;

    expect(await themeProvider.setAccent(AppAccent.blue), isTrue);
    expect(themeProvider.accent, AppAccent.blue);
    expect(await themeProvider.toggleTheme(), isTrue);
    expect(themeProvider.accent, AppAccent.blue);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('accent_color'), 'blue');
    themeProvider.dispose();

    final restoredProvider = ThemeProvider();
    await restoredProvider.ready;
    expect(restoredProvider.accent, AppAccent.blue);
    restoredProvider.dispose();
  });
}
