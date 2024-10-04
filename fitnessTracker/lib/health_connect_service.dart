import 'package:flutter_health_connect/flutter_health_connect.dart';

class HealthConnectService {
  static Future<bool> checkPermissions(
      List<HealthConnectDataType> types, bool readOnly) async {
    return await HealthConnectFactory.hasPermissions(types, readOnly: readOnly);
  }

  static Future<bool> requestPermissions(
      List<HealthConnectDataType> types, bool readOnly) async {
    return await HealthConnectFactory.requestPermissions(types, readOnly: readOnly);
  }

  static Future<Map<String, dynamic>> getRecords(
      HealthConnectDataType type, DateTime startTime, DateTime endTime) async {
    return await HealthConnectFactory.getRecord(
      type: type,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
