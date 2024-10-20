import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';  // Import for internationalization
import 'app_localizations.dart';  // Import our custom localization class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');  // Default locale is set to English

  // Function to change the locale dynamically
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,  // Our custom localizations delegate
        GlobalMaterialLocalizations.delegate,  // Flutter's material localization delegate
        GlobalWidgetsLocalizations.delegate,  // Widget-specific localization delegate
        GlobalCupertinoLocalizations.delegate,  // For iOS-style widgets
      ],
      supportedLocales: const [
        Locale('en', ''),  // English
        Locale('es', ''),  // Spanish
        Locale('fr', ''),  // French
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;  // Default to the first locale if none match
      },
      home: MyHomePage(onLocaleChange: _changeLanguage),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  MyHomePage({required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    // Access the localization class
    final appLocalization = AppLocalizations.of(context);

    // Format a date and price based on the current locale
    final price = 1234.56;
    String formattedDate = DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
        .format(DateTime.now());
    String formattedPrice = NumberFormat.currency(
            locale: Localizations.localeOf(context).languageCode, symbol: "\$")
        .format(price);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization!.translate('title') ?? ''),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String locale) {
              onLocaleChange(Locale(locale));
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'es', child: Text('Español')),
                PopupMenuItem(value: 'fr', child: Text('Français')),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLocalization.translate('greetingMessage') ?? ''),
            SizedBox(height: 10),
            Text("${appLocalization.translate('currentDate')}: $formattedDate"),
            SizedBox(height: 10),
            Text(appLocalization.translate('currencyMessage')!.replaceFirst('{price}', formattedPrice)),
            SizedBox(height: 20),
            Text(appLocalization.plural('items', 1)),  // Plural example: 1 item
            Text(appLocalization.plural('items', 5)),  // Plural example: 5 items
            SizedBox(height: 20),
            Text(appLocalization.gender('genderMessage', 'male')),  // Gender-specific message
            Text(appLocalization.gender('genderMessage', 'female')),  // Gender-specific message
          ],
        ),
      ),
    );
  }
}
