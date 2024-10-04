import 'package:flutter/material.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

class PermissionButtons extends StatelessWidget {
  final Function(String) onResultUpdate;
  final bool readOnly;

  const PermissionButtons({
    super.key,
    required this.onResultUpdate,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    List<HealthConnectDataType> types = [
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
      //HealthConnectDataType.Exercise, // May not exist in API or might have a different name
      HealthConnectDataType.FloorsClimbed,
      HealthConnectDataType.HeartRate,
      HealthConnectDataType.Height,
      HealthConnectDataType.Hydration,
      HealthConnectDataType.LeanBodyMass,
      //HealthConnectDataType.Menstruation, // Commented out due to potential naming issues
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
      //HealthConnectDataType.VO2Max, // Commented out due to potential naming issues
      HealthConnectDataType.Weight,
      HealthConnectDataType.WheelchairPushes,
    ];

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            var result = await HealthConnectFactory.isApiSupported();
            onResultUpdate('isApiSupported: $result');
          },
          child: const Text('isApiSupported'),
        ),
        ElevatedButton(
          onPressed: () async {
            var result = await HealthConnectFactory.isAvailable();
            onResultUpdate('isAvailable: $result');
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
              onResultUpdate(
                  'Permissions not granted. Requesting permissions...');
              var requested = await HealthConnectFactory.requestPermissions(
                types,
                readOnly: readOnly,
              );

              if (requested) {
                onResultUpdate('Permissions successfully granted!');
              } else {
                onResultUpdate('Permissions request failed or denied.');
              }
            } else {
              onResultUpdate('Permissions are already granted.');
            }
          },
          child: const Text('Check & Request Permissions'),
        ),
      ],
    );
  }
}
