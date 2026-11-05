import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// Settings section that picks between following the system, light or dark.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themeModeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          title: 'Appearance',
          subtitle: 'Choose how Zedu looks on this device',
        ),
        const SizedBox(height: 28),
        ProfileCard(
          child: Column(
            children: [
              for (final option in ThemePreference.values) ...[
                _AppearanceOption(
                  option: option,
                  selected: option == preference,
                  onTap: () => ref
                      .read(themeModeControllerProvider.notifier)
                      .set(option),
                ),
                if (option != ThemePreference.values.last)
                  Divider(height: 1, color: context.colors.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ThemePreference option;
  final bool selected;
  final VoidCallback onTap;

  static const _descriptions = {
    ThemePreference.system: 'Follow your operating system',
    ThemePreference.light: 'Always use the light theme',
    ThemePreference.dark: 'Always use the dark theme',
  };

  static const _icons = {
    ThemePreference.system: Icons.brightness_auto_outlined,
    ThemePreference.light: Icons.light_mode_outlined,
    ThemePreference.dark: Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(_icons[option], color: colors.textPrimary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _descriptions[option]!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? colors.primary : colors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
