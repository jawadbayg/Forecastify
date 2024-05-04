import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:forecastify/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData.dark(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = '';
  double temperature = 0.0;
  int humidity = 0;
  String description = '';
  String icon = '';
  double minTemp = 0.0;
  double maxTemp = 0.0;
  int visibility = 0;
  double windSpeed = 0.0;
  double lon = 0.0;
  double lat = 0.0;
  DateTime sunrise = DateTime.now();
  DateTime sunset = DateTime.now();
  int pressure = 0;
  List<Map<String, dynamic>> forecastData = [];
  List<Map<String, dynamic>> filteredTemperatures = [];
  List<Map<String, dynamic>> hourlyForecastData = [];
  TextEditingController _controller = TextEditingController();
  int aqi = 0;
  String aqiLevel = '';
  Color aqiColor = Colors.black;

  @override
  void initState() {
    super.initState();
    fetchData('Faisalabad');
    fetchForecast('Faisalabad');
    // _fetchAirQualityData();
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

        // Fetch and update weather data

        // final sys = weatherData['sys'];
        final main = weatherData['main'];
        final coord = weatherData['coord'];

        // Extract lon and lat from coord
        final lon = coord['lon'];
        final lat = coord['lat'];

        setState(() {
          city = cityName;
          temperature = (main['temp'] - 273.15).toDouble();
          humidity = main['humidity'];
          description = weatherData['weather'][0]['description'];
          minTemp = (main['temp_min'] - 273.15).toDouble();
          maxTemp = (main['temp_max'] - 273.15).toDouble();
          visibility = weatherData['visibility'];
          windSpeed = weatherData['wind']['speed'];
          sunrise = DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunrise'] * 1000);
          sunset = DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunset'] * 1000);
          pressure = main['pressure'];
          this.lon = lon;
          this.lat = lat;
          fetchHourlyWeather(coord['lat'], coord['lon']);
        });

        // Fetch and update forecast data
        final List<dynamic> forecastList = forecastData['list'];
        List<Map<String, dynamic>> temperatures = [];

        for (var forecast in forecastList) {
          final DateTime forecastDateTime = DateTime.parse(forecast['dt_txt']);
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
      } else if (weatherResponse.statusCode == 404 ||
          forecastResponse.statusCode == 404) {
        // Show alert for invalid city name
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData(
                dialogBackgroundColor: Color.fromARGB(255, 24, 24, 24),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    minimumSize: Size(double.infinity, 48.0),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.0), // Button padding
                  ),
                ),
              ),
              child: AlertDialog(
                title: Text(
                  'Invalid City Name',
                  style:
                      TextStyle(color: Colors.white), // White title text color
                ),
                content: Text(
                  'The city "$cityName" was not found. Please enter a valid city name.',
                  style: TextStyle(
                      color: Colors.white), // White content text color
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.black), // Black button text color
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print(
            'Failed to fetch data: ${weatherResponse.statusCode}, ${forecastResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchForecast(String cityName) async {
    // Same as the fetchForecast method in the initState
    // It's moved here to make it accessible from anywhere in the class
  }
  Widget weatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return Image.asset('assets/images/cloudy.png');
      case 'rainy':
        return Image.asset('assets/images/rainy.png');
      case 'overcast clouds':
        return Image.asset('assets/images/fewclouds.png');
      case 'moderate rain':
        return Image.asset('assets/images/literain.png');
      default:
        return Image.asset('assets/images/scattered.png');
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

  // Future<void> _fetchAirQualityData() async {
  //   final apiKey =
  //       '2e13e7f76fed50c17ff002a3501cb525'; // Replace with your API key
  //   final url =
  //       'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final json = jsonDecode(response.body);
  //     print("API Response JSON: $json");
  //     final aqiValue = json['list'][0]['main']['aqi'];
  //     print("Extracted AQI Value: $aqiValue");
  //     setState(() {
  //       aqi = aqiValue;
  //       aqiLevel = _getAQILevel(aqi);
  //       aqiColor = _getAQIColor(aqi);
  //     });
  //   } else {
  //     throw Exception('Failed to load air quality data');
  //   }
  // }

  // String _getAQILevel(int aqiValue) {
  //   if (aqiValue == 1) {
  //     return 'Good';
  //   } else if (aqiValue == 2) {
  //     return 'Fair';
  //   } else if (aqiValue == 3) {
  //     return 'Moderate';
  //   } else if (aqiValue == 4) {
  //     return 'Poor';
  //   } else if (aqiValue == 5) {
  //     return 'Very Poor';
  //   } else {
  //     return 'Unknown';
  //   }
  // }

  // Color _getAQIColor(int aqiValue) {
  //   if (aqiValue == 1) {
  //     return Colors.green;
  //   } else if (aqiValue == 2) {
  //     return Colors.yellow;
  //   } else if (aqiValue == 3) {
  //     return Colors.orange;
  //   } else if (aqiValue == 4) {
  //     return Colors.red;
  //   } else if (aqiValue == 5) {
  //     return Colors.purple;
  //   } else {
  //     return Colors.black; // Default color for unknown values
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          // child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Container(
              // margin: EdgeInsets.all(18.0),
              // padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.all(18.0),
                      height: 500.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.lightBlueAccent,
                            const Color.fromARGB(255, 47, 157, 248)
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SafeArea(
                                child: TextField(
                              controller: _controller,
                              onSubmitted: (value) {
                                fetchData(value);
                              },
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Enter city name',
                                hintStyle: TextStyle(
                                    color: Colors
                                        .grey[400]), // Adjust hint text color
                                filled: true,
                                fillColor: Colors.white, // Background color
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none, // No border
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    fetchData(_controller.text);
                                  },
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0), // Adjust padding
                              ),
                            )),
                            SizedBox(height: 30.0),
                            Text(
                              '$city'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Longitude $lon',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                                Text(
                                  '|',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                                Text(
                                  'Latitude $lat',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.0),
                            // Image.network(
                            //   icon,
                            //   width: 100,
                            //   height: 100,
                            // ),
                            Text(
                              '${temperature.toStringAsFixed(1)}°c',
                              // style: TextStyle(
                              //     fontSize: 90.0, color: Colors.white,
                              //     ),
                              style: GoogleFonts.jost(
                                  fontWeight: FontWeight.w500, fontSize: 100.0),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              height: 80.0,
                              width: 80.0,
                              child: weatherIcon(description),
                            ),
                            Text(
                              '$description',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.only(right: 16.0, left: 16.0),
              height: 55.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HourlyForecastScreen(
                        hourlyForecastData: hourlyForecastData,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '24 Hour Weather Forecast',
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
                // First Row
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18.0),
                  height: 100.0,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Colors.grey.shade700),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/humidity.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10.0), // Add space between icon and text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Humidity",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      Text(
                                        '$humidity%',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0, // Added space between containers
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Colors.grey.shade700),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 40.0,
                                    width: 40.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/windspeed.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10.0), // Add space between icon and text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Wind Speed",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      Text(
                                        '$windSpeed Km/h',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

//doosri row---------------------------------------
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18.0),
                  height: 100.0,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Colors.grey.shade700),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/visibilty.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10.0), // Add space between icon and text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Visibility",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      Text(
                                        '$visibility m',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0, // Added space between containers
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Colors.grey.shade700),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 40.0,
                                    width: 40.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/pressure.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10.0), // Add space between icon and text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pressure",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      Text(
                                        '$pressure hPa',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //....................
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18.0),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(16.0)),
                  height: 55.0,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 27.0,
                        width: 27.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/sunrise.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        'Sunrise ${sunrise.hour.toString().padLeft(2, '0')}:${sunrise.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: const Color.fromARGB(255, 159, 159, 159)),
                      ),
                      Container(
                        height: 27.0,
                        width: 27.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/sunset.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        'Sunset ${sunset.hour.toString().padLeft(2, '0')}:${sunset.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: Text(
                    "5 days forecast",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                SizedBox(
                  height: 7.0,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: forecastData
                        .map((forecast) => ForecastCard(forecastData: forecast))
                        .toList(),
                  ),
                ),

                SizedBox(height: 20.0),
                // Center(
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         'AQ Index $aqi',
                //         style: TextStyle(fontSize: 24),
                //       ),
                //       SizedBox(height: 16),
                //       Text(
                //         'AQI Level $aqiLevel',
                //         style: TextStyle(fontSize: 24, color: aqiColor),
                //       ),
                //     ],
                //   ),
                // ),

                // SizedBox(
                //   height: 20.0,
                // ),
                // SizedBox(height: 20.0),
                // SizedBox(height: 20.0),
                // Text(
                //   'ICON $icon',
                //   style: TextStyle(fontSize: 20.0),
                // ),
              ],
            ),
          ])

          // ),
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
        centerTitle: true,
        title: Text(
          '24 Hour Weather Forecast',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: ListView.builder(
          itemCount: hourlyForecastData.length,
          itemBuilder: (context, index) {
            final forecast = hourlyForecastData[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.5),
              ),
              child: ListTile(
                trailing: _weatherIcon(forecast['description']),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getDayName(forecast['time'])}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_formatHour(forecast['time'])}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature: ${forecast['temp']} °C',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Description: ${forecast['description']}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatHour(DateTime dateTime) {
    String hour = (dateTime.hour % 12).toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _weatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
        return Image.asset(
          'assets/images/cloudy.png',
          width: 40,
          height: 40,
        );
      case 'rainy':
        return Image.asset(
          'assets/images/rainy.png',
          width: 40,
          height: 40,
        );

      // Add more cases for other weather conditions
      default:
        return Image.asset(
          'assets/images/scattered.png',
          width: 40,
          height: 40,
        );
    }
  }

  String _getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}

class ForecastScreen extends StatelessWidget {
  final List<Map<String, dynamic>> forecastData;

  const ForecastScreen({Key? key, required this.forecastData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: true,
        title: Text(
          '5 Days Forecast',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white, // Text color
          ),
        ),
      ),
      body: SizedBox(
        height: 200.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: forecastData.map((forecast) {
                final date = forecast['date'];
                final day = _getDayName(date);
                final temp = forecast['temp'] != null
                    ? (forecast['temp'] - 273.15).toStringAsFixed(1) + '°C'
                    : 'N/A';
                final description = forecast['description'] ?? 'N/A';
                final weatherDescription = description.toLowerCase();

                return SizedBox(
                  height: 200.0,
                  width: 180.0, // Adjust the width as needed
                  child: Card(
                    color: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _weatherIcon(weatherDescription),
                          SizedBox(height: 8.0),
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$date',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Temperature: $temp',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            '$description',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _weatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return Image.asset(
          'assets/images/cloudy.png',
          width: 60,
          height: 60,
        );
      case 'rainy':
        return Image.asset(
          'assets/images/rainy.png',
          width: 60,
          height: 60,
        );
      case 'overcast clouds':
        return Image.asset(
          'assets/images/cloudy.png',
          width: 60,
          height: 60,
        );
      case 'moderate rain':
        return Image.asset(
          'assets/images/literain.png',
          width: 60,
          height: 60,
        );
      default:
        return Image.asset(
          'assets/images/scattered.png',
          width: 60,
          height: 60,
        );
    }
  }

  String _getDayName(String date) {
    final DateTime dateTime = DateTime.parse(date);
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}

class ForecastCard extends StatelessWidget {
  final Map<String, dynamic> forecastData;

  const ForecastCard({Key? key, required this.forecastData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = forecastData['date'];
    final day = _getDayName(date);
    final temp = forecastData['temp'] != null
        ? (forecastData['temp'] - 273.15).toStringAsFixed(1) + '°C'
        : 'N/A';
    final description = forecastData['description'] ?? 'N/A';
    final weatherDescription = description.toLowerCase();

    return SizedBox(
      height: 200.0,
      width: 180.0, // Adjust the width as needed
      child: Card(
        color: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _weatherIcon(weatherDescription),
              SizedBox(height: 8.0),
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$date',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Temperature: $temp',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                '$description',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return Image.asset(
          'assets/images/cloudy.png',
          width: 60,
          height: 60,
        );
      case 'rainy':
        return Image.asset(
          'assets/images/rainy.png',
          width: 60,
          height: 60,
        );
      case 'overcast clouds':
        return Image.asset(
          'assets/images/cloudy.png',
          width: 60,
          height: 60,
        );
      case 'moderate rain':
        return Image.asset(
          'assets/images/literain.png',
          width: 60,
          height: 60,
        );
      default:
        return Image.asset(
          'assets/images/scattered.png',
          width: 60,
          height: 60,
        );
    }
  }

  String _getDayName(String date) {
    final DateTime dateTime = DateTime.parse(date);
    switch (dateTime.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
