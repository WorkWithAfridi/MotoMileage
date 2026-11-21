import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:motomileage/app/localization/localized_text.dart';
import 'package:motomileage/app/models/app_settings.dart';

void main() {
  group('locale resolution', () {
    test('uses a supported saved language before the device language', () {
      expect(
        AppTranslations.resolveLocale('fr', const Locale('es')),
        const Locale('fr'),
      );
    });

    test('uses a supported device language when no preference is saved', () {
      expect(
        AppTranslations.resolveLocale(null, const Locale('bn', 'BD')),
        const Locale('bn'),
      );
    });

    test('falls back to English for an unsupported device language', () {
      expect(
        AppTranslations.resolveLocale(null, const Locale('ar')),
        const Locale('en'),
      );
    });
  });

  group('translation catalogs', () {
    test('every supported locale has complete static key coverage', () {
      final englishKeys = appTranslationKeys['en']!.keys.toSet();
      const criticalSingleWordLabels = {
        'Dashboard',
        'Fuel',
        'Maintenance',
        'Settings',
        'Edit',
        'Delete',
        'Cancel',
        'Restore',
      };

      expect(englishKeys, containsAll(criticalSingleWordLabels));

      for (final code in AppTranslations.supportedLanguageCodes) {
        expect(
          appTranslationKeys[code]!.keys.toSet(),
          englishKeys,
          reason: 'Static translation coverage differs for $code.',
        );
        expect(
          appTranslationKeys[code]!.values.any((value) => value.isEmpty),
          isFalse,
          reason: 'Empty translation found for $code.',
        );
      }
    });

    test('translated parameterized strings preserve runtime values', () {
      final spanish = AppTranslations.translateForLanguage(
        '3 maintenance reminder(s)',
        'es',
      );
      final bengali = AppTranslations.translateForLanguage(
        'Saved backup from ১২ আগস্ট ২০২৬',
        'bn',
      );

      expect(spanish, contains('3'));
      expect(spanish, isNot('3 maintenance reminder(s)'));
      expect(
        AppTranslations.translateForLanguage('Settings', 'es'),
        isNot('Settings'),
      );
      expect(bengali, contains('১২ আগস্ট ২০২৬'));
      expect(bengali, isNot('Saved backup from ১২ আগস্ট ২০২৬'));
    });

    test('generated translations contain no transport placeholders', () {
      for (final locale in appTranslationKeys.values) {
        for (final value in locale.values) {
          expect(value, isNot(contains('ZXQ')));
          expect(value, isNot(contains('928374650192837465')));
        }
      }
    });
  });

  test('language preference serializes and can return to system default', () {
    final spanish = AppSettings.defaults.copyWith(languageCode: 'es');
    final restored = AppSettings.fromMap(spanish.toMap());
    final system = restored.copyWith(clearLanguageCode: true);

    expect(restored.languageCode, 'es');
    expect(system.languageCode, isNull);
  });

  testWidgets('translated text follows the active app locale', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('es'),
        fallbackLocale: const Locale('en'),
        home: const Directionality(
          textDirection: TextDirection.ltr,
          child: TrText('Settings'),
        ),
      ),
    );

    expect(
      find.text(AppTranslations.translateForLanguage('Settings', 'es')),
      findsOneWidget,
    );
  });
}
