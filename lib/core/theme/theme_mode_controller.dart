import 'package:zedu/core/core.dart';

/// How the app picks between the light and dark themes.
enum ThemePreference { system, light, dark }

extension ThemePreferenceX on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  String get label => switch (this) {
    ThemePreference.system => 'System',
    ThemePreference.light => 'Light',
    ThemePreference.dark => 'Dark',
  };
}

/// Persists the theme preference device-locally so the choice survives a
/// restart. Defaults to following the system.
class ThemeModeController extends Notifier<ThemePreference> {
  static const _storageKey = 'theme_mode_preference';

  @override
  ThemePreference build() {
    _load();
    return ThemePreference.system;
  }

  Future<void> _load() async {
    try {
      final saved = await locator<SecureStorageService>().readData(_storageKey);
      final preference = ThemePreference.values
          .where((p) => p.name == saved)
          .firstOrNull;
      if (preference != null && ref.mounted) state = preference;
    } catch (_) {
      // A missing or unreadable preference falls back to system.
    }
  }

  Future<void> set(ThemePreference preference) async {
    state = preference;
    try {
      await locator<SecureStorageService>().writeData(
        _storageKey,
        preference.name,
      );
    } catch (_) {
      // The choice still applies for this session.
    }
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemePreference>(
      ThemeModeController.new,
    );

/// The [ThemeMode] to hand to [MaterialApp.router], kept in its own provider
/// so widgets that only need the mode do not rebuild on storage writes.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(themeModeControllerProvider).themeMode,
);
