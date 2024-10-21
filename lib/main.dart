import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Locale _locale = Locale('en');  // Default language is English
  Map<String, String> _localizedStrings = {};

  @override
  void initState() {
    super.initState();
    _loadLocalizedStrings();
  }

  void _loadLocalizedStrings() async {
    String jsonString = await rootBundle.loadString('lib/lang/${_locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
      _loadLocalizedStrings();
    });
  }

  String _translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: [
        Locale('en', ''),
        Locale('fr', ''),
        Locale('es', ''),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppBar(
          title: Text(_translate("app_title")),
        ),
        body: WeatherScreen(
          onChangeLanguage: _changeLanguage,
          translate: _translate,
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final Function(Locale) onChangeLanguage;
  final String Function(String) translate;

  WeatherScreen({required this.onChangeLanguage, required this.translate});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _city = "New York";
  String _temperatureUnit = "metric"; // Default to Celsius
  String _weatherDescription = "";
  double _temperature = 0.0;
  int _humidity = 0;
  int _pressure = 0;
  String _currentTime = "";

  final String apiKey = '961753dcbebe7804a0ab5a3bf41bdc5e';

  void _fetchWeatherAndTime() async {
    String weatherUrl = "https://api.openweathermap.org/data/2.5/weather?q=$_city&units=$_temperatureUnit&appid=$apiKey";
    String timeUrl = "http://worldtimeapi.org/api/timezone/America/New_York";  // Adjust according to the city

    final weatherResponse = await http.get(Uri.parse(weatherUrl));
    final timeResponse = await http.get(Uri.parse(timeUrl));

    if (weatherResponse.statusCode == 200) {
      var weatherData = jsonDecode(weatherResponse.body);
      setState(() {
        _temperature = weatherData['main']['temp'];
        _weatherDescription = weatherData['weather'][0]['description'];
        _humidity = weatherData['main']['humidity'];
        _pressure = weatherData['main']['pressure'];
      });
    }

    if (timeResponse.statusCode == 200) {
      var timeData = jsonDecode(timeResponse.body);
      setState(() {
        _currentTime = timeData['datetime'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndTime();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            onChanged: (value) {
              _city = value;
            },
            decoration: InputDecoration(
              labelText: widget.translate("enter_city"),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchWeatherAndTime,
            child: Text(widget.translate("app_title")),
          ),
          SizedBox(height: 20),
          Text("${widget.translate("temperature")}: $_temperature °C"),
          Text("${widget.translate("description")}: $_weatherDescription"),
          Text("${widget.translate("humidity")}: $_humidity%"),
          Text("${widget.translate("pressure")}: $_pressure hPa"),
          SizedBox(height: 20),
          Text("${widget.translate("current_time")}: $_currentTime"),
          SizedBox(height: 20),
          DropdownButton<Locale>(
            onChanged: (Locale? newValue) {
              if (newValue != null) {
                widget.onChangeLanguage(newValue);
              }
            },
            items: const [
              DropdownMenuItem(child: Text('English'), value: Locale('en')),
              DropdownMenuItem(child: Text('French'), value: Locale('fr')),
              DropdownMenuItem(child: Text('Spanish'), value: Locale('es')),
            ],
            hint: Text(widget.translate("select_language")),
          ),
        ],
      ),
    );
  }
}
