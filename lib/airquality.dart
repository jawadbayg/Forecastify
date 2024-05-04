// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AirQualityScreen extends StatefulWidget {
//   final double latitude;
//   final double longitude;

//   const AirQualityScreen(
//       {Key? key, required this.latitude, required this.longitude})
//       : super(key: key);

//   @override
//   _AirQualityScreenState createState() => _AirQualityScreenState();
// }

// class _AirQualityScreenState extends State<AirQualityScreen> {
//   late int aqi;
//   late String aqiLevel;
//   late Color aqiColor;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAirQualityData();
//   }

//   Future<void> _fetchAirQualityData() async {
//     final apiKey = 'YOUR_API_KEY'; // Replace with your API key
//     final url =
//         'https://api.openweathermap.org/data/2.5/air_pollution?lat=${widget.latitude}&lon=${widget.longitude}&appid=$apiKey';

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       final aqiValue = json['list'][0]['main']['aqi'];
//       setState(() {
//         aqi = aqiValue;
//         aqiLevel = _getAQILevel(aqi);
//         aqiColor = _getAQIColor(aqi);
//       });
//     } else {
//       throw Exception('Failed to load air quality data');
//     }
//   }

//   String _getAQILevel(int aqiValue) {
//     if (aqiValue >= 0 && aqiValue <= 50) {
//       return 'Good';
//     } else if (aqiValue >= 51 && aqiValue <= 100) {
//       return 'Moderate';
//     } else if (aqiValue >= 101 && aqiValue <= 150) {
//       return 'Unhealthy for sensitive groups';
//     } else if (aqiValue >= 151 && aqiValue <= 200) {
//       return 'Unhealthy';
//     } else if (aqiValue >= 201 && aqiValue <= 300) {
//       return 'Very unhealthy';
//     } else if (aqiValue >= 301 && aqiValue <= 500) {
//       return 'Hazardous';
//     } else {
//       return 'Unknown';
//     }
//   }

//   Color _getAQIColor(int aqiValue) {
//     if (aqiValue >= 0 && aqiValue <= 50) {
//       return Colors.green;
//     } else if (aqiValue >= 51 && aqiValue <= 100) {
//       return Colors.yellow;
//     } else if (aqiValue >= 101 && aqiValue <= 150) {
//       return Colors.orange;
//     } else if (aqiValue >= 151 && aqiValue <= 200) {
//       return Colors.red;
//     } else if (aqiValue >= 201 && aqiValue <= 300) {
//       return Colors.purple;
//     } else if (aqiValue >= 301 && aqiValue <= 500) {
//       return const Color.fromARGB(255, 107, 7, 0);
//     } else {
//       return Colors.black;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Air Quality'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Air Quality Index: $aqi',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'AQI Level: $aqiLevel',
//               style: TextStyle(fontSize: 24, color: aqiColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
