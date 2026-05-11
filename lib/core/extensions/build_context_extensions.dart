import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get themeData => Theme.of(this);

  Size get mediaQuery => MediaQuery.of(this).size;

  double get width => mediaQuery.width;

  double get height => mediaQuery.height;

// ColorScheme get colorScheme => themeData.colorScheme;

// Read a provider without listening for changes
// T stateRead<T extends ChangeNotifier>() => BaseDataProvider.of<T>(this);
//
// // Watch a provider and rebuild when it changes
// T stateWatch<T extends ChangeNotifier>() => BaseDataProvider.listen<T>(this);
//
// (T, T) statePair<T extends ChangeNotifier>() => (stateWatch<T>(), stateRead<T>());
}
