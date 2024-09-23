// import 'package:health_connect/health_connect.dart';

// class HealthConnectManager {
//   static final HealthConnectManager _instance =
//       HealthConnectManager._internal();
//   factory HealthConnectManager() => _instance;

//   HealthConnectManager._internal();

//   late HealthConnect _healthConnect;
//   bool _isInitialized = false;

//   Future<void> initialize() async {
//     if (!_isInitialized) {
//       try {
//         _healthConnect = await HealthConnect.initialize();
//         _isInitialized = true;
//         print('Health Connect initialized successfully');
//       } catch (error) {
//         print('Error initializing Health Connect: $error');
//       }
//     }
//   }

//   Future<bool> checkAvailability() async {
//     return await HealthConnect.isAvailable();
//   }

//   Future<List<HealthPermission>> requestPermissions(
//       List<HealthPermission> permissions) async {
//     return await _healthConnect.requestPermissions(permissions);
//   }

//   // Example method for getting steps
//   Future<int> getSteps(DateTime startTime, DateTime endTime) async {
//     if (!_isInitialized) await initialize();
//     final records = await _healthConnect.getRecords(
//       type: HealthRecordType.STEPS,
//       dateFrom: startTime,
//       dateTo: endTime,
//     );
//     return records.fold<int>(0, (sum, record) => sum + (record.value as int));
//   }

//   // Add more methods for other health data types as needed
// }
