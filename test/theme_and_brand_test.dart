import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pray_then_play/app/theme.dart';
import 'package:pray_then_play/core/constants/app_constants.dart';
import 'package:pray_then_play/core/widgets/app_logo_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Pray Then Play Rebrand & Theme Matrix Tests', () {
    test('App constants reflect Pray Then Play brand identity', () {
      expect(AppConstants.appName, equals('Pray Then Play'));
      expect(AppConstants.tagline,
          equals('Stay on time. Play with peace of mind.'));
      expect(AppConstants.version, equals('2.0.0'));
    });

    test('11-Theme Matrix has exactly 5 Dark, 5 Light, and 1 Special theme', () {
      const allThemes = AppGamingTheme.values;
      expect(allThemes.length, equals(11));

      final darkThemes = allThemes.where((t) => !t.isLight && t != AppGamingTheme.tactical).toList();
      final lightThemes = allThemes.where((t) => t.isLight).toList();
      final specialThemes = allThemes.where((t) => t == AppGamingTheme.tactical || t == AppGamingTheme.oled).toList();

      expect(darkThemes.length, equals(5)); // midnight, oled, crimson, forest, ember
      expect(lightThemes.length, equals(5)); // dawn, arctic, sand, sky, lavender
      expect(specialThemes.contains(AppGamingTheme.tactical), isTrue);
      expect(specialThemes.contains(AppGamingTheme.oled), isTrue);
    });

    testWidgets(
        'All 11 themes have unique backgrounds and properly contrasted typography',
        (WidgetTester tester) async {
      final bgColors = <int>{};

      for (final theme in AppGamingTheme.values) {
        // Unique background
        expect(bgColors.contains(theme.background.toARGB32()), isFalse,
            reason: '${theme.displayName} has duplicate background color');
        bgColors.add(theme.background.toARGB32());

        // Light vs Dark typography contrast
        if (theme.isLight) {
          expect(theme.isLight, isTrue);
          expect(theme.textPrimary.computeLuminance() < 0.3, isTrue,
              reason:
                  '${theme.displayName} is light theme but textPrimary is not dark enough');
        } else {
          expect(theme.isLight, isFalse);
          expect(theme.textPrimary.computeLuminance() > 0.7, isTrue,
              reason:
                  '${theme.displayName} is dark theme but textPrimary is not light enough');
        }

        // Semantic tokens isolation
        final tokens = theme.tokens;
        expect(tokens.semanticSuccess, isNotNull);
        expect(tokens.semanticWarning, isNotNull);
        expect(tokens.semanticDanger, isNotNull);
        expect(tokens.semanticPrayer, isNotNull);
      }
    });

    testWidgets('AppLogoWidget renders in iconOnly, compact, and horizontal lockups',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppLogoWidget(size: 40, variant: AppLogoVariant.iconOnly),
                AppLogoWidget(size: 40, variant: AppLogoVariant.compact),
                AppLogoWidget(size: 40, variant: AppLogoVariant.horizontal),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppLogoWidget), findsNWidgets(3));
      expect(find.text('PTP', findRichText: true), findsOneWidget);
      expect(find.text('Pray Then Play', findRichText: true), findsOneWidget);
    });
  });
}
