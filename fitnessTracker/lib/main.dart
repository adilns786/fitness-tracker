import 'package:flutter/material.dart';
import 'record_display_ui.dart'; // Importing the UI part of the RecordDisplay
import 'permissions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
            // Permission buttons
            PermissionButtons(
              onResultUpdate: (result) {
                setState(() {
                  resultText = result;
                });
              },
              readOnly: readOnly,
            ),
            // RecordDisplay widget
            RecordDisplay(
              onResultUpdate: (result) {
                setState(() {
                  resultText =
                      result; // Update resultText based on the record display logic
                });
              },
            ),
            // Displaying results
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(resultText),
            ),
          ],
        ),
      ),
    );
  }
}
