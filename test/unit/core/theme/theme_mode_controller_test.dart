import 'package:zedu/core/core.dart';

import '../../../helpers/helpers.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

Future<void> _flushAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

/// Registers [storage] and returns a fresh container watching the theme.
ProviderContainer _containerWith(MockSecureStorageService storage) {
  locator.registerSingleton<SecureStorageService>(storage);
  addTearDown(locator.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ThemeModeController', () {
    test('defaults to following the system when nothing is saved', () async {
      final storage = MockSecureStorageService();
      when(() => storage.readData(any())).thenAnswer((_) async => null);
      final container = _containerWith(storage);

      expect(
        container.read(themeModeControllerProvider),
        ThemePreference.system,
      );
      await _flushAsync();
      expect(
        container.read(themeModeControllerProvider),
        ThemePreference.system,
      );
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('loads the saved preference from storage', () async {
      final storage = MockSecureStorageService();
      when(
        () => storage.readData('theme_mode_preference'),
      ).thenAnswer((_) async => 'dark');
      final container = _containerWith(storage);

      container.read(themeModeControllerProvider);
      await _flushAsync();

      expect(container.read(themeModeControllerProvider), ThemePreference.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('falls back to system for an unknown saved value', () async {
      final storage = MockSecureStorageService();
      when(
        () => storage.readData('theme_mode_preference'),
      ).thenAnswer((_) async => 'neon');
      final container = _containerWith(storage);

      container.read(themeModeControllerProvider);
      await _flushAsync();

      expect(
        container.read(themeModeControllerProvider),
        ThemePreference.system,
      );
    });

    test('set applies the preference and persists it', () async {
      final storage = MockSecureStorageService();
      when(() => storage.readData(any())).thenAnswer((_) async => null);
      when(() => storage.writeData(any(), any())).thenAnswer((_) async {});
      final container = _containerWith(storage);

      final notifier = container.read(themeModeControllerProvider.notifier);
      await _flushAsync();

      await notifier.set(ThemePreference.light);

      expect(
        container.read(themeModeControllerProvider),
        ThemePreference.light,
      );
      expect(container.read(themeModeProvider), ThemeMode.light);
      verify(
        () => storage.writeData('theme_mode_preference', 'light'),
      ).called(1);
    });

    test('storage failures never block changing the theme', () async {
      final storage = MockSecureStorageService();
      when(() => storage.readData(any())).thenThrow(Exception('unavailable'));
      when(
        () => storage.writeData(any(), any()),
      ).thenThrow(Exception('unavailable'));
      final container = _containerWith(storage);

      final notifier = container.read(themeModeControllerProvider.notifier);
      await _flushAsync();
      expect(
        container.read(themeModeControllerProvider),
        ThemePreference.system,
      );

      await notifier.set(ThemePreference.dark);

      expect(container.read(themeModeControllerProvider), ThemePreference.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
