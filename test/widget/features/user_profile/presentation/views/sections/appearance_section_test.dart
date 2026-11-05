import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../../helpers/helpers.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

Widget _buildUnderTest({ThemeMode themeMode = ThemeMode.light}) {
  return ProviderScope(
    child: buildTestMaterialApp(
      const Scaffold(body: SingleChildScrollView(child: AppearanceSection())),
      themeMode: themeMode,
    ),
  );
}

/// The [Icons.check_circle] inside the option row that holds [label].
Finder _checkIn(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
  matching: find.byIcon(Icons.check_circle),
);

void main() {
  group('AppearanceSection', () {
    testWidgets('shows System, Light and Dark with descriptions', (
      tester,
    ) async {
      await tester.pumpWidget(_buildUnderTest());

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Choose how Zedu looks on this device'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Follow your operating system'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Always use the light theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Always use the dark theme'), findsOneWidget);
    });

    testWidgets('starts on System when nothing is saved', (tester) async {
      final storage = MockSecureStorageService();
      locator.registerSingleton<SecureStorageService>(storage);
      addTearDown(locator.reset);
      when(() => storage.readData(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildUnderTest());
      await tester.pumpAndSettle();

      expect(_checkIn('System'), findsOneWidget);
      expect(_checkIn('Light'), findsNothing);
      expect(_checkIn('Dark'), findsNothing);
    });

    testWidgets('tapping Dark selects it and persists the choice', (
      tester,
    ) async {
      final storage = MockSecureStorageService();
      locator.registerSingleton<SecureStorageService>(storage);
      addTearDown(locator.reset);
      when(() => storage.readData(any())).thenAnswer((_) async => null);
      when(() => storage.writeData(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(_checkIn('System'), findsNothing);
      expect(_checkIn('Dark'), findsOneWidget);
      verify(
        () => storage.writeData('theme_mode_preference', 'dark'),
      ).called(1);
    });

    testWidgets('dark theme reaches context.colors', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        ProviderScope(
          child: buildTestMaterialApp(
            Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.shrink();
              },
            ),
            themeMode: ThemeMode.dark,
          ),
        ),
      );

      expect(Theme.of(captured).brightness, Brightness.dark);
      expect(captured.colors.background, AppPalette.dark.background);
      expect(captured.colors.textPrimary, AppPalette.dark.textPrimary);
    });

    testWidgets('light theme keeps its palette by default', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        ProviderScope(
          child: buildTestMaterialApp(
            Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(Theme.of(captured).brightness, Brightness.light);
      expect(captured.colors.background, AppPalette.light.background);
    });
  });
}
