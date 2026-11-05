import 'package:zedu/core/core.dart';

Widget buildTestMaterialApp(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: child,
  );
}
