import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

part 'translations.g.dart';

class AppTranslationPattern {
  AppTranslationPattern(this.source, this.values);

  final RegExp source;
  final Map<String, String> values;
}

class AppTranslations extends Translations {
  static const supportedLanguageCodes = <String>[
    'en',
    'zh',
    'hi',
    'es',
    'fr',
    'bn',
    'pt',
    'ru',
    'id',
  ];

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('hi'),
    Locale('es'),
    Locale('fr'),
    Locale('bn'),
    Locale('pt'),
    Locale('ru'),
    Locale('id'),
  ];

  static const languageNames = <String, String>{
    'en': 'English',
    'zh': '简体中文',
    'hi': 'हिन्दी',
    'es': 'Español',
    'fr': 'Français',
    'bn': 'বাংলা',
    'pt': 'Português',
    'ru': 'Русский',
    'id': 'Bahasa Indonesia',
  };

  @override
  Map<String, Map<String, String>> get keys => appTranslationKeys;

  static Locale resolveLocale(String? savedLanguageCode, Locale? deviceLocale) {
    if (savedLanguageCode != null &&
        supportedLanguageCodes.contains(savedLanguageCode)) {
      return Locale(savedLanguageCode);
    }

    final deviceLanguageCode = deviceLocale?.languageCode.toLowerCase();
    if (deviceLanguageCode != null &&
        supportedLanguageCodes.contains(deviceLanguageCode)) {
      return Locale(deviceLanguageCode);
    }

    return const Locale('en');
  }

  static String translate(String key) {
    final languageCode = Get.locale?.languageCode ?? 'en';
    return translateForLanguage(key, languageCode);
  }

  static String translateForLanguage(String key, String languageCode) {
    final exact =
        appTranslationKeys[languageCode]?[key] ??
        appTranslationKeys['en']?[key];
    if (exact != null) {
      return exact;
    }

    for (final pattern in appTranslationPatterns) {
      final match = pattern.source.firstMatch(key);
      if (match == null) {
        continue;
      }
      var translated =
          pattern.values[languageCode] ?? pattern.values['en'] ?? key;
      for (var index = 1; index <= match.groupCount; index++) {
        translated = translated.replaceAll(
          '@p${index - 1}',
          translateForLanguage(match.group(index) ?? '', languageCode),
        );
      }
      return translated;
    }

    return key;
  }
}

extension AppTranslationStringX on String {
  String get tx => AppTranslations.translate(this);

  String txParams(Map<String, Object> parameters) {
    var result = tx;
    for (final entry in parameters.entries) {
      result = result.replaceAll('@${entry.key}', entry.value.toString());
    }
    return result;
  }
}
