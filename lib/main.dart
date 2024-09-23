import 'package:flutter/material.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/custom_navbar.dart';
import 'pages/dashboard_page.dart';
import 'pages/stats_page.dart';
import 'pages/tune_page.dart';
import 'pages/etc_page.dart';
// import 'pages/tentang.dart';  // Import Tentang page
import 'splash.dart';  // Import splash screen
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splash(), // Use SplashScreen from splash.dart
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late Stream<Map<String, dynamic>> _sensorDataStream;

  @override
  void initState() {
    super.initState();
    _sensorDataStream = _sensorDataPeriodicStream();
  }

  Stream<Map<String, dynamic>> _sensorDataPeriodicStream() async* {
    while (true) {
      yield await fetchSensorData();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<Map<String, dynamic>> fetchSensorData() async {
    final response = await http.get(Uri.parse('https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/sensor_data/sensor_test.json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 3 ? null : CustomAppBar(currentIndex: _currentIndex), // Hide AppBar for index 3 (Tentang)
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: _sensorDataStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final sensorData = snapshot.data!;
                return DashboardPage(
                  level: sensorData['level'] ?? 0.0,
                  amperage: sensorData['current'] ?? 0,
                  batteryHealth: sensorData['batteryHealth'] ?? 'Unknown',
                  voltage: sensorData['voltage'] ?? 0,
                  temperature: sensorData['temp'] ?? 0,
                );
              } else {
                return Center(child: Text('No data available'));
              }
            },
          ),
          StatsPage(),
          TunePage(),
          Tentang(), // This will be shown without AppBar
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
