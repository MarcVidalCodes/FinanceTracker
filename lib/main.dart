import 'package:finance_tracker/helpers/constants.dart';
import 'package:finance_tracker/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CashCompass());
}

class CashCompass extends StatelessWidget {
  const CashCompass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      useMaterial3: false,
      primarySwatch: Colors.green,
      colorScheme: const ColorScheme.light().copyWith(
        primary: customColorPrimary,
        secondary: customColorPrimary,
        tertiary: customColorPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'Finance Tracker',
      theme: theme,
      home: const MainScreen(), // Directly set MainScreen as the home
      debugShowCheckedModeBanner: false,
    );
  }
}
