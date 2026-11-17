import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calculator/calculator_provider.dart';
import 'screens/calculator_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const GoldCalculatorApp(),
    ),
  );
}

class GoldCalculatorApp extends StatelessWidget {
  const GoldCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Calculator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(themeProvider.accent),
        darkTheme: AppTheme.dark(themeProvider.accent),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeAnimationDuration: const Duration(milliseconds: 250),
        home: const CalculatorScreen(),
      ),
    );
  }
}
                                                                                                           