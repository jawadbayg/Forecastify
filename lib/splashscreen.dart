import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:forecastify/main.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      // Navigate to the next screen after 5 seconds
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => WeatherScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splashlogo.gif',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            // Your app name

            Text(
              "Forecastify",
              style: GoogleFonts.jost(
                fontWeight: FontWeight.w500,
                fontSize: 26.0,
                color: Colors.black, // Change the color to your desired color
              ),
            ),

            SizedBox(height: 26),
            // Loading animation
          ],
        ),
      ),
    );
  }
}
