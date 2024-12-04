import 'package:flutter/material.dart';
import 'record_display_logic.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

class RecordDisplay extends StatefulWidget {
  final Function(String) onResultUpdate;

  const RecordDisplay({super.key, required this.onResultUpdate});

  @override
  _RecordDisplayState createState() => _RecordDisplayState();
}

class _RecordDisplayState extends State<RecordDisplay> {
  late RecordDisplayLogic _logic;
  String serverResponse = ''; // Variable to hold the server response

  @override
  void initState() {
    super.initState();
    _logic = RecordDisplayLogic(onResultUpdate: widget.onResultUpdate);
  }

  // Method to select time
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _logic.startTimeOfDay = picked;
        } else {
          _logic.endTimeOfDay = picked;
        }
      });
    }
  }

  // Method to send data to server and update response
  Future<void> _sendDataToServer() async {
    String responseMessage = await _logic.sendAllDataToServer();
    setState(() {
      serverResponse = responseMessage; // Set success message
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Display',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dropdown for selecting data type
            DropdownButtonFormField<HealthConnectDataType>(
              value: _logic.selectedDataType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _logic.types.map((type) {
                return DropdownMenuItem<HealthConnectDataType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _logic.updateSelectedDataType(newValue!);
                });
              },
              hint: const Text('Select Data Type'),
            ),
            const SizedBox(height: 16),

            // Date range and time selection
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _logic.updateDateRange(picked.start, picked.end);
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: const Text('Select Date Range'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time picker
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Time:'),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: const Text('Select Start Time'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Time:'),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: const Text('Select End Time'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown for sorting order
            DropdownButtonFormField<String>(
              value: _logic.sortOrder,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: ['Time', 'Value'].map((order) {
                return DropdownMenuItem<String>(
                  value: order,
                  child: Text(order),
                );
              }).toList(),
              onChanged: (newOrder) {
                setState(() {
                  _logic.updateSortOrder(newOrder!);
                });
              },
              hint: const Text('Sort By'),
            ),
            const SizedBox(height: 16),

            // Buttons for "Read", "Reset", and "Send Data"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _logic.fetchRecords();
                  },
                  child: const Text('Read'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _logic.reset();
                    });
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _sendDataToServer();
                  },
                  child: const Text('Send Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display server response
            Text(
              serverResponse,
              style: const TextStyle(color: Colors.green, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Display full response from the server
            // Text(
            //   'Full Server Response: ${_logic.fullResponse}', // Update this to use your response variable
            //   style: const TextStyle(color: Colors.blue, fontSize: 16),
            // ),
          ],
        ),
      ),
    );
  }
}
