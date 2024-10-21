import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Locale _locale = const Locale('en'); // Default language is English
  Map<String, String> _localizedStrings = {};

  @override
  void initState() {
    super.initState();
    _loadLocalizedStrings();
  }

  void _loadLocalizedStrings() async {
    String jsonString =
        await rootBundle.loadString('lib/lang/${_locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
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
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
        Locale('es', ''),
      ],
      localizationsDelegates: const [
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
  String _city = "Saigon"; // Default city
  String _temperatureUnit = "metric"; // Default to Celsius
  String _weatherDescription = "";
  String _weatherIcon = "";
  double _temperature = 0.0;
  int _humidity = 0;
  int _pressure = 0;
  String _currentTime = "";
  String apiKey = 'dc6b82ef8b8311f032e5b7b9b4101410';

  void _fetchWeatherAndTime(String city) async {
    String weatherUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&units=$_temperatureUnit&appid=$apiKey";

    final weatherResponse = await http.get(Uri.parse(weatherUrl));

    if (weatherResponse.statusCode == 200) {
      var weatherData = jsonDecode(weatherResponse.body);
      setState(() {
        _temperature = weatherData['main']['temp'];
        _weatherDescription = weatherData['weather'][0]['description'];
        _weatherIcon = weatherData['weather'][0]['icon'];
        _humidity = weatherData['main']['humidity'];
        _pressure = weatherData['main']['pressure'];
      });

      // Get timezone offset from weather data
      int timezoneOffset = weatherData['timezone'];
      _fetchCurrentTime(timezoneOffset);
    } else {
      setState(() {
        _weatherDescription = "City not found!";
      });
    }
  }

  void _fetchCurrentTime(int timezoneOffset) async {
    // Get the current UTC time
    DateTime nowUtc = DateTime.now().toUtc();

    DateTime localTime = nowUtc.add(Duration(seconds: timezoneOffset));

    String formattedTime = DateFormat('HH:mm:ss').format(localTime);

    setState(() {
      _currentTime = formattedTime;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndTime(_city); // Fetch weather and time when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the chosen city name
          Text(
            _city,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              _city = value; // Update the city name when input changes
            },
            decoration: InputDecoration(
              labelText: widget.translate("enter_city"),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _fetchWeatherAndTime(
                  _city); // Fetch new data when user enters a new city
            },
            child: Text(widget.translate("get_weather")),
          ),
          const SizedBox(height: 20),
          // Weather Icon
          if (_weatherIcon.isNotEmpty)
            CachedNetworkImage(
              imageUrl: "http://openweathermap.org/img/wn/$_weatherIcon@2x.png",
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          const SizedBox(height: 20),
          // Weather Details
          Text("${widget.translate("temperature")}: $_temperature °C"),
          Text("${widget.translate("description")}: $_weatherDescription"),
          Text("${widget.translate("humidity")}: $_humidity%"),
          Text("${widget.translate("pressure")}: $_pressure hPa"),
          const SizedBox(height: 20),
          Text("${widget.translate("current_time")}: $_currentTime"),
          const SizedBox(height: 20),
          // Language Selector
          DropdownButton<Locale>(
            onChanged: (Locale? newValue) {
              if (newValue != null) {
                widget.onChangeLanguage(newValue);
              }
            },
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('fr'), child: Text('French')),
              DropdownMenuItem(value: Locale('es'), child: Text('Spanish')),
            ],
            hint: Text(widget.translate("select_language")),
          ),
        ],
      ),
    );
  }
}
