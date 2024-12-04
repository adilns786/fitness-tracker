import 'package:flutter/material.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import '../screens/home/home.dart';

class Permissions extends StatefulWidget {
  const Permissions({super.key});

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<Permissions> {
  final List<HealthConnectDataType> types = [
    HealthConnectDataType.ActiveCaloriesBurned,
    HealthConnectDataType.BasalBodyTemperature,
    HealthConnectDataType.BasalMetabolicRate,
    HealthConnectDataType.BloodGlucose,
    HealthConnectDataType.BloodPressure,
    HealthConnectDataType.BodyFat,
    HealthConnectDataType.BodyTemperature,
    HealthConnectDataType.BoneMass,
    HealthConnectDataType.CervicalMucus,
    HealthConnectDataType.Distance,
    HealthConnectDataType.ElevationGained,
    HealthConnectDataType.FloorsClimbed,
    HealthConnectDataType.HeartRate,
    HealthConnectDataType.Height,
    HealthConnectDataType.Hydration,
    HealthConnectDataType.LeanBodyMass,
    HealthConnectDataType.Nutrition,
    HealthConnectDataType.OvulationTest,
    HealthConnectDataType.OxygenSaturation,
    HealthConnectDataType.Power,
    HealthConnectDataType.RespiratoryRate,
    HealthConnectDataType.RestingHeartRate,
    HealthConnectDataType.SexualActivity,
    HealthConnectDataType.SleepSession,
    HealthConnectDataType.Speed,
    HealthConnectDataType.Steps,
    HealthConnectDataType.TotalCaloriesBurned,
    HealthConnectDataType.Weight,
    HealthConnectDataType.WheelchairPushes,
  ];

  @override
  void initState() {
    super.initState();
    // Delay the permission check until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndHandlePermissions();
    });
  }

  Future<void> _checkAndHandlePermissions() async {
    // Check if the Health Connect API is supported
    bool isApiSupported = await HealthConnectFactory.isApiSupported();
    if (!isApiSupported) {
      _showPopup('Health Connect API is not supported on this device.');
      return;
    }

    // Check if Health Connect is available
    bool isAvailable = await HealthConnectFactory.isAvailable();
    if (!isAvailable) {
      _showPopup('Health Connect is not installed. Please install it.');
      await HealthConnectFactory.installHealthConnect();
      return;
    }

    // Check if permissions are granted
    bool hasPermissions = await HealthConnectFactory.hasPermissions(types);
    if (!hasPermissions) {
      bool requested = await HealthConnectFactory.requestPermissions(types);
      if (!requested) {
        _showPopup('Permissions request failed or denied.');
        return;
      }
    }

    // If everything is fine, do not navigate to the permission page
    // Navigate to the main content page or load the main UI
    _navigateToMainContent();
  }

  void _navigateToMainContent() {
    // Implement navigation to the main page of your app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const HomeScreen(), // Replace with your main content widget
      ),
    );
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Health Connect Status'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// class MainContentPage extends StatelessWidget {
//   const MainContentPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return HomeScreen();
//   }
// }
