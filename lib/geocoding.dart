// import 'package:flutter/material.dart';
// import 'package:location/location.dart' as location;
// import 'package:permission_handler/permission_handler.dart'
//     as permission_handler;

// class WeatherScreengeo extends StatefulWidget {
//   @override
//   _WeatherScreengeoState createState() => _WeatherScreengeoState();
// }

// class _WeatherScreengeoState extends State<WeatherScreengeo> {
//   location.Location locationService =
//       location.Location(); // Renaming the variable
//   late Map<String, double> _currentLocation;

//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//   }

//   Future<void> _getLocation() async {
//     bool _serviceEnabled;
//     permission_handler.PermissionStatus _permissionGranted;
//     location.LocationData? _locationData;

//     _serviceEnabled =
//         await locationService.serviceEnabled(); // Updated reference
//     if (!_serviceEnabled) {
//       _serviceEnabled =
//           await locationService.requestService(); // Updated reference
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await permission_handler.Permission.location.status;
//     if (_permissionGranted != permission_handler.PermissionStatus.granted) {
//       _permissionGranted =
//           await permission_handler.Permission.location.request();
//       if (_permissionGranted != permission_handler.PermissionStatus.granted) {
//         return;
//       }
//     }

//     _locationData = await locationService.getLocation(); // Updated reference
//     setState(() {
//       _currentLocation = {
//         'latitude': _locationData?.latitude ?? 0.0,
//         'longitude': _locationData?.longitude ?? 0.0,
//       };
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Weather Screen'),
//       ),
//       body: Center(
//         child: _currentLocation != null
//             ? Text(
//                 'Latitude: ${_currentLocation['latitude']}, Longitude: ${_currentLocation['longitude']}')
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
// }
