import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen_test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Directionality(
        textDirection:
            TextDirection.ltr, // Adjust this based on your app's text direction
        child: WSAPIs(),
      ),
    );
  }
}

class WSAPIs extends StatefulWidget {
  @override
  _WSAPIsState createState() => _WSAPIsState();
}

class _WSAPIsState extends State<WSAPIs> {
  String city = '';
  double temperature = 0.0;
  int humidity = 0;
  String description = '';
  double windSpeed = 0.0;
  DateTime sunrise = DateTime.now();
  DateTime sunset = DateTime.now();
  List<Map<String, dynamic>> forecastData = [];
  List<Map<String, dynamic>> hourlyForecastData = [];

  @override
  void initState() {
    super.initState();
    fetchData('Faisalabad');
  }

  Future<void> fetchData(String cityName) async {
    final apiKey = '2e13e7f76fed50c17ff002a3501cb525';
    final weatherApiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';
    final forecastApiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey';

    try {
      final weatherResponse = await http.get(Uri.parse(weatherApiUrl));
      final forecastResponse = await http.get(Uri.parse(forecastApiUrl));

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final Map<String, dynamic> weatherData =
            jsonDecode(weatherResponse.body);
        final Map<String, dynamic> forecastData =
            jsonDecode(forecastResponse.body);

        final main = weatherData['main']; // Main weather info
        final sys = weatherData['sys']; // Sunrise and Sunset data
        final coord = weatherData['coord']; // City coordinates

        setState(() {
          city = cityName;
          temperature = main['temp'] - 273.15;
          humidity = main['humidity'];
          description = weatherData['weather'][0]['description'];
          windSpeed = weatherData['wind']['speed'];
          sunrise = DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000);
          sunset = DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000);
          // Extracting latitude and longitude
          fetchHourlyWeather(coord['lat'], coord['lon']);
        });

        final List<dynamic> forecastList = forecastData['list'];
        List<Map<String, dynamic>> temperatures = [];

        for (var forecast in forecastList) {
          final DateTime forecastDateTime =
              DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
          if (forecastDateTime.hour == 12) {
            final temperatureData = {
              'date': forecastDateTime.toString().substring(0, 10),
              'temp': forecast['main']['temp'],
              'description': forecast['weather'][0]['description'],
            };
            temperatures.add(temperatureData);
          }
        }

        setState(() {
          this.forecastData = temperatures;
        });
      } else {
        print(
            'Failed to fetch data: ${weatherResponse.statusCode}, ${forecastResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Define a list to store hourly forecast data
  Future<void> fetchHourlyWeather(double lat, double lon) async {
    final hourlyWeatherApiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,rain,cloud_cover_high';

    try {
      final response = await http.get(Uri.parse(hourlyWeatherApiUrl));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final hourlyData = jsonData['hourly'];

        // Clear previous data
        if (mounted) {
          setState(() {
            hourlyForecastData.clear();
          });
        }

        // Populate hourlyForecastData with parsed hourly weather data for the current day
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        for (int i = 0; i < hourlyData['time'].length; i++) {
          final DateTime forecastTime = DateTime.parse(hourlyData['time'][i]);
          // Filter only the data for the current day (next 24 hours)
          if (forecastTime.isAfter(now) &&
              forecastTime.isBefore(today.add(Duration(days: 1)))) {
            final forecastData = {
              'time': forecastTime,
              'temp': hourlyData['temperature_2m'][i],
              'description': hourlyData['cloud_cover_high'][i] >= 50
                  ? 'Cloudy'
                  : 'Clear', // Adjust based on actual weather data
            };
            if (mounted) {
              setState(() {
                hourlyForecastData.add(forecastData);
              });
            }
          }
        }
      } else {
        print('Failed to fetch hourly weather data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching hourly weather data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Current Weather',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('City: $city'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Temperature: $temperature °C'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Description: $description'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Humidity: $humidity%'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Wind Speed: $windSpeed m/s'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Sunrise: ${sunrise.hour}:${sunrise.minute}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Sunset: ${sunset.hour}:${sunset.minute}'),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: hourlyForecastData.length,
            //   itemBuilder: (context, index) {
            //     final forecast = hourlyForecastData[index];
            //     return ListTile(
            //       title: Text(
            //         '${forecast['time'].hour}:${forecast['time'].minute}',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //       subtitle: Text(
            //         'Temperature: ${forecast['temp']} °C\n'
            //         'Description: ${forecast['description']}',
            //       ),
            //     );
            //   },
            // ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HourlyForecastScreen(
                          hourlyForecastData: hourlyForecastData),
                    ),
                  );
                },
                child: Text('24 Hour Weather Forecast'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HourlyForecastScreen extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyForecastData;

  const HourlyForecastScreen({Key? key, required this.hourlyForecastData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('24 Hour Weather Forecast'),
      ),
      body: ListView.builder(
        itemCount: hourlyForecastData.length,
        itemBuilder: (context, index) {
          final forecast = hourlyForecastData[index];
          return ListTile(
            title: Text(
              '${forecast['time'].hour}:${forecast['time'].minute}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Temperature: ${forecast['temp']} °C\n'
              'Description: ${forecast['description']}',
            ),
          );
        },
      ),
    );
  }
}
