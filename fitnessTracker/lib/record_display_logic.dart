import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:flutter/material.dart';

class RecordDisplayLogic {
  final Function(String) onResultUpdate;

  RecordDisplayLogic({required this.onResultUpdate});

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
      DateTime _extractDateTimeFromRecord(String record) {
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
          DateTime aDateTime = _extractDateTimeFromRecord(a);
          DateTime bDateTime = _extractDateTimeFromRecord(b);

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
}
