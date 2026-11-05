import 'dart:math' as math;

import 'package:zedu/core/core.dart';

import '../../../helpers/helpers.dart';

/// WCAG contrast ratio between two colours; 1.0 = identical, 21 = max.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void _expectPairs(
  Map<String, ({Color fg, Color bg})> pairs,
  double minimum,
  String rule,
) {
  pairs.forEach((label, pair) {
    final ratio = _contrast(pair.fg, pair.bg);
    expect(
      ratio,
      greaterThanOrEqualTo(minimum),
      reason: '$label is ${ratio.toStringAsFixed(2)}:1, needs $rule',
    );
  });
}

void main() {
  group('AppPalette.dark', () {
    test('declares the dark brightness', () {
      expect(AppPalette.dark.brightness, Brightness.dark);
    });

    test('keeps text readable against the background (AA, 4.5:1)', () {
      _expectPairs(
        {
          'textPrimary/background': (
            fg: AppPalette.dark.textPrimary,
            bg: AppPalette.dark.background,
          ),
          'textSecondary/background': (
            fg: AppPalette.dark.textSecondary,
            bg: AppPalette.dark.background,
          ),
          'textHint/background': (
            fg: AppPalette.dark.textHint,
            bg: AppPalette.dark.background,
          ),
          'onSidebar/sidebar': (
            fg: AppPalette.dark.onSidebar,
            bg: AppPalette.dark.sidebar,
          ),
          'onPrimary/primary': (
            fg: AppPalette.dark.onPrimary,
            bg: AppPalette.dark.primary,
          ),
          'primary/background': (
            fg: AppPalette.dark.primary,
            bg: AppPalette.dark.background,
          ),
          'primary/primaryBg': (
            fg: AppPalette.dark.primary,
            bg: AppPalette.dark.primaryBg,
          ),
        },
        4.5,
        '4.5:1',
      );
    });

    test('keeps status badges readable (AA, 4.5:1)', () {
      _expectPairs(
        {
          'success/successBg': (
            fg: AppPalette.dark.success,
            bg: AppPalette.dark.successBg,
          ),
          'error/errorBg': (
            fg: AppPalette.dark.error,
            bg: AppPalette.dark.errorBg,
          ),
        },
        4.5,
        '4.5:1',
      );
    });

    test('keeps input borders distinguishable (3:1)', () {
      _expectPairs(
        {
          'borderOutline/background': (
            fg: AppPalette.dark.borderOutline,
            bg: AppPalette.dark.background,
          ),
        },
        3.0,
        '3:1',
      );
    });
  });

  group('AppPalette.light', () {
    test('declares the light brightness', () {
      expect(AppPalette.light.brightness, Brightness.light);
    });

    test('keeps main surfaces readable', () {
      _expectPairs(
        {
          'textPrimary/background': (
            fg: AppPalette.light.textPrimary,
            bg: AppPalette.light.background,
          ),
          'primary/background': (
            fg: AppPalette.light.primary,
            bg: AppPalette.light.background,
          ),
          'onSidebar/sidebar': (
            fg: AppPalette.light.onSidebar,
            bg: AppPalette.light.sidebar,
          ),
        },
        4.5,
        '4.5:1',
      );
    });

    test('differs from the dark palette', () {
      expect(AppPalette.light.background, isNot(AppPalette.dark.background));
      expect(AppPalette.light.sidebar, isNot(AppPalette.dark.sidebar));
      expect(AppPalette.light.textPrimary, isNot(AppPalette.dark.textPrimary));
    });
  });
}
