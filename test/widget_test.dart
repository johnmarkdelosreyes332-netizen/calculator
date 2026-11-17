import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_calculator/calculator/calculator_provider.dart';
import 'package:gold_calculator/main.dart';
import 'package:gold_calculator/theme/app_theme.dart';
import 'package:gold_calculator/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpAnimations(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('fits the calculator on a short landscape screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CalculatorProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const GoldCalculatorApp(),
      ),
    );
    await _pumpAnimations(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('calculates from the on-screen keypad', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CalculatorProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const GoldCalculatorApp(),
      ),
    );
    await _pumpAnimations(tester);

    await tester.tap(find.text('2').last);
    await tester.tap(find.text('+'));
    await tester.tap(find.text('3').last);
    await tester.tap(find.text('='));
    await _pumpAnimations(tester);

    expect(find.text('5'), findsWidgets);
  });

  testWidgets('switches between light and dark themes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CalculatorProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const GoldCalculatorApp(),
      ),
    );
    await _pumpAnimations(tester);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await tester.tap(find.byTooltip('Switch to light mode'));
    await _pumpAnimations(tester);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);
  });

  testWidgets('selected accent color stays when switching themes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CalculatorProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const GoldCalculatorApp(),
      ),
    );
    await _pumpAnimations(tester);

    await tester.tap(find.byTooltip('Choose accent color'));
    await _pumpAnimations(tester);
    await tester.tap(find.text('Blue').last);
    await _pumpAnimations(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      materialApp.darkTheme!.extension<AppPalette>()!.accent,
      AppAccent.blue.dark,
    );
    await tester.tap(find.byTooltip('Switch to light mode'));
    await _pumpAnimations(tester);

    final lightTheme = tester
        .widget<MaterialApp>(find.byType(MaterialApp))
        .theme!;
    expect(lightTheme.extension<AppPalette>()!.accent, AppAccent.blue.light);
  });
}
