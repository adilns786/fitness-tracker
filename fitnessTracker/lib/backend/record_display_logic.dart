import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecordDisplayLogic {
  final Function(String) onResultUpdate;
  String _fullResponse = '';

  RecordDisplayLogic({required this.onResultUpdate});
  String get fullResponse => _fullResponse;

  // List of all available types
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

  HealthConnectDataType? selectedDataType;
  DateTime? startTime;
  DateTime? endTime;
  TimeOfDay? startTimeOfDay;
  TimeOfDay? endTimeOfDay;

  // Variable to handle sorting order
  String sortOrder = 'Time';

  // Function to update selected data type
  void updateSelectedDataType(HealthConnectDataType newType) {
    selectedDataType = newType;
  }

  void updateDateRange(DateTime start, DateTime end) {
    startTime = start;
    endTime = end;
  }

  void updateTimeRange(TimeOfDay start, TimeOfDay end) {
    startTimeOfDay = start;
    endTimeOfDay = end;
  }

  void updateSortOrder(String newSortOrder) {
    sortOrder = newSortOrder;
  }

  // Reset function to clear all selected values
  void reset() {
    selectedDataType = null;
    startTime = null;
    endTime = null;
    startTimeOfDay = null;
    endTimeOfDay = null;
    sortOrder = 'Time';
  }

  Future<void> fetchRecords() async {
    if (selectedDataType == null) {
      onResultUpdate('Please select a data point.');
      return;
    }

    DateTime startTimeRange =
        startTime ?? DateTime.now().subtract(const Duration(days: 4));
    DateTime endTimeRange = endTime ?? DateTime.now();

    // Apply time range if specified
    if (startTimeOfDay != null && endTimeOfDay != null) {
      startTimeRange = DateTime(
        startTimeRange.year,
        startTimeRange.month,
        startTimeRange.day,
        startTimeOfDay!.hour,
        startTimeOfDay!.minute,
      );
      endTimeRange = DateTime(
        endTimeRange.year,
        endTimeRange.month,
        endTimeRange.day,
        endTimeOfDay!.hour,
        endTimeOfDay!.minute,
      );
    }

    var result = await HealthConnectFactory.getRecord(
      type: selectedDataType!,
      startTime: startTimeRange,
      endTime: endTimeRange,
    );

    if (result['records'] != null && result['records'].isNotEmpty) {
      var records = result['records'] as List;
      List<String> formattedRecords = records.map<String>((record) {
        var endTimeEpoch = DateTime.fromMillisecondsSinceEpoch(
          (record['endTime']['epochSecond'] as int) * 1000,
          isUtc: true,
        );
        var localEndTime = endTimeEpoch.toLocal();

        switch (selectedDataType) {
          case HealthConnectDataType.Steps:
            return 'Steps: ${record['count']} at ${localEndTime.toLocal()}';
          case HealthConnectDataType.HeartRate:
            return record['samples'].map<String>((sample) {
              var heartRate = sample['beatsPerMinute'];
              var sampleTimeEpoch = DateTime.fromMillisecondsSinceEpoch(
                (sample['time']['epochSecond'] as int) * 1000,
                isUtc: true,
              );
              var localSampleTime = sampleTimeEpoch.toLocal();

              return 'Heart Rate: $heartRate BPM at ${localSampleTime.toLocal()}';
            }).join('\n');
          default:
            return 'Unknown record type';
        }
      }).toList();

      // Helper method to extract DateTime from record string
      DateTime extractDateTimeFromRecord(String record) {
        // Example: "Heart Rate: 101 BPM at 2024-10-04 06:20:00.000"
        var dateTimeString =
            record.split(' at ')[1]; // Get the part after ' at '
        return DateTime.parse(
            dateTimeString); // Parse the date string to DateTime
      }

      // Sort the records based on date and time
      if (sortOrder == 'Time') {
        formattedRecords.sort((a, b) {
          // Extract date and time from the string
          DateTime aDateTime = extractDateTimeFromRecord(a);
          DateTime bDateTime = extractDateTimeFromRecord(b);

          // Sort by date and then by time, in descending order
          return bDateTime.compareTo(aDateTime); // Most recent at top
        });
      } else if (sortOrder == 'Value') {
        formattedRecords.sort((a, b) {
          var aValue = double.tryParse(a.split(' ')[2]) ?? 0;
          var bValue = double.tryParse(b.split(' ')[2]) ?? 0;
          return aValue.compareTo(bValue);
        });
      }

      // Update the results
      onResultUpdate(formattedRecords.join("\n\n"));
    } else {
      onResultUpdate('No records found for ${selectedDataType!.name}.');
    }
  }

  // Fetch all health connect data (you need to implement this based on your data structure)
  Future<List<Map<String, dynamic>>> fetchAllHealthConnectData() async {
    List<Map<String, dynamic>> allRecords = [];

    for (var dataType in types) {
      DateTime startTimeRange =
          DateTime.now().subtract(const Duration(days: 4));
      DateTime endTimeRange = DateTime.now();

      // Fetch records for the specified data type
      var result = await HealthConnectFactory.getRecord(
        type: dataType,
        startTime: startTimeRange,
        endTime: endTimeRange,
      );

      if (result['records'] != null && result['records'].isNotEmpty) {
        var records = result['records'] as List;

        // Process records for each data type
        for (var record in records) {
          Map<String, dynamic> recordMap = {
            'type': dataType.name, // Store the type of the data
            'startTime': DateTime.fromMillisecondsSinceEpoch(
              (record['startTime']['epochSecond'] as int) * 1000,
              isUtc: true,
            ).toIso8601String(), // Store start time in ISO 8601 format
            'endTime': DateTime.fromMillisecondsSinceEpoch(
              (record['endTime']['epochSecond'] as int) * 1000,
              isUtc: true,
            ).toIso8601String(), // Store end time in ISO 8601 format
          };

          // Add specific fields based on the data type
          switch (dataType) {
            case HealthConnectDataType.Steps:
              if (record['count'] != null) {
                recordMap['steps'] = record['count'];
              }
              break;
            case HealthConnectDataType.HeartRate:
              if (record['samples'] != null && record['samples'].isNotEmpty) {
                recordMap['heartRate'] = record['samples']
                    .map((sample) {
                      if (sample['beatsPerMinute'] != null) {
                        return {
                          'beatsPerMinute': sample['beatsPerMinute'],
                          'time': DateTime.fromMillisecondsSinceEpoch(
                            (sample['time']['epochSecond'] as int) * 1000,
                            isUtc: true,
                          ).toIso8601String(),
                        };
                      }
                      return null; // Return null for invalid samples
                    })
                    .where(
                        (sample) => sample != null) // Filter out null samples
                    .toList();
              }
              break;
            // Add cases for other HealthConnectDataTypes if needed
            default:
              if (record['value'] != null) {
                recordMap['value'] = record['value']; // Only add if not null
              }
          }

          // Only add to allRecords if the recordMap has at least one valid entry
          if (recordMap.length > 2) {
            // 2 is the minimum for 'type' and time fields
            allRecords.add(recordMap); // Add the record to the list
          }
        }
      }
    }

    return allRecords; // Return the list of all records
  }

  Future<String> sendAllDataToServer() async {
    try {
      // Fetch all the raw data from Health Connect
      var allData = await fetchAllHealthConnectData();

      // Check the structure of allData
      print("Raw data fetched: $allData");

      // URL of the Flask server
      String apiUrl =
          "http://192.168.41.180:5000/raw-data"; // Adjust the port if needed

      // Convert the data to JSON and send it to the server
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(allData), // Sending raw data as JSON
      );
      _fullResponse = response.body;

      // Check the response status code
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        onResultUpdate("Data sent successfully.");
        return response.body; // Return the complete response
      } else {
        print("Failed to send data. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        onResultUpdate("Failed to send data.");
        return response.body; // Return the response body for debugging
      }
    } catch (e) {
      print("Error occurred while sending data: $e");
      onResultUpdate("Error occurred while sending data.");
      return "Error: $e"; // Return the error for debugging
    }
  }
}
