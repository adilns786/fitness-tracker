import 'package:flutter/material.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<HealthConnectDataType> types = [
    HealthConnectDataType.Steps,
    HealthConnectDataType.HeartRate,
    HealthConnectDataType.SleepSession,
    HealthConnectDataType.OxygenSaturation,
    HealthConnectDataType.RespiratoryRate,
  ];

  bool readOnly = false;
  String resultText = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Connect'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton(
              onPressed: () async {
                var result = await HealthConnectFactory.isApiSupported();
                resultText = 'isApiSupported: $result';
                _updateResultText();
              },
              child: const Text('isApiSupported'),
            ),
            ElevatedButton(
              onPressed: () async {
                var result = await HealthConnectFactory.isAvailable();
                resultText = 'isAvailable: $result';
                _updateResultText();
              },
              child: const Text('Check installed'),
            ),
            ElevatedButton(
              onPressed: () async {
                await HealthConnectFactory.installHealthConnect();
              },
              child: const Text('Install Health Connect'),
            ),
            ElevatedButton(
              onPressed: () async {
                await HealthConnectFactory.openHealthConnectSettings();
              },
              child: const Text('Open Health Connect Settings'),
            ),
            ElevatedButton(
              onPressed: () async {
                var hasPermissions = await HealthConnectFactory.hasPermissions(
                  types,
                  readOnly: readOnly,
                );

                if (!hasPermissions) {
                  resultText =
                      'Permissions not granted. Requesting permissions...';
                  _updateResultText();

                  var requested = await HealthConnectFactory.requestPermissions(
                    types,
                    readOnly: readOnly,
                  );

                  if (requested) {
                    resultText = 'Permissions successfully granted!';
                  } else {
                    resultText = 'Permissions request failed or denied.';
                  }
                } else {
                  resultText = 'Permissions are already granted.';
                }

                _updateResultText();
              },
              child: const Text('Check & Request Permissions'),
            ),
            ElevatedButton(
              onPressed: () async {
                var startTime =
                    DateTime.now().subtract(const Duration(days: 4));
                var endTime = DateTime.now();
                var results = {};

                for (var type in types) {
                  var result = await HealthConnectFactory.getRecord(
                    type: type, // Pass each HealthConnectDataType individually
                    startTime: startTime,
                    endTime: endTime,
                  );
                  results[type.name] = result;
                }

                resultText = 'Results:\n\n$results';
                _updateResultText();
              },
              child: const Text('Get Record'),
            ),
            Text(resultText),
          ],
        ),
      ),
    );
  }

  void _updateResultText() {
    setState(() {});
  }
}
