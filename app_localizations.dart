import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';  // Import for handling pluralization and gender-specific formats

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Retrieve the localization instance
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String>? _localizedStrings;

  // Load the JSON language file
  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/i10n/intl_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // Basic translation function
  String? translate(String key) {
    return _localizedStrings![key];
  }

  // Function for handling translations with arguments
  String translateWithArgs(String key, Map<String, dynamic> args) {
    String value = _localizedStrings![key]!;
    args.forEach((k, v) {
      value = value.replaceAll('{$k}', v.toString());
    });
    return value;
  }

  // Handle pluralization
  String plural(String key, int count) {
    return Intl.plural(count,
        one: translateWithArgs(key, {'howMany': 1}),
        other: translateWithArgs(key, {'howMany': count}),
        locale: locale.toString());
  }

  // Handle gender-specific translations
  String gender(String key, String gender) {
    return Intl.gender(gender,
        male: translateWithArgs(key, {'gender': 'male'}),
        female: translateWithArgs(key, {'gender': 'female'}),
        other: translateWithArgs(key, {'gender': 'other'}),
        locale: locale.toString());
  }
}

// Localization delegate for loading the right localization data
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
