import 'package:flutter/material.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: forecastData.length,
                itemBuilder: (context, index) {
                  final forecast = forecastData[index];
                  final date = forecast['date'];
                  final day = _getDayName(date);
                  final temp = forecast['temp'] != null
                      ? (forecast['temp'] - 273.15).toStringAsFixed(1) + '°C'
                      : 'N/A';
                  final description = forecast['description'] ?? 'N/A';
                  final weatherDescription = description.toLowerCase();

                  return Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                      trailing: _weatherIcon(weatherDescription),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                  );
                },
              ),
            ),
          ],
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
          'assets/images/fewclouds.png',
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
