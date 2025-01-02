import 'package:flutter/material.dart';

class ThemeProvider extends InheritedWidget {
  final ThemeData themeData;
  final Function(ThemeData) updateTheme;

  const ThemeProvider({
    super.key,
    required this.themeData,
    required this.updateTheme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final ThemeProvider? result = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeData != oldWidget.themeData;
  }
}
