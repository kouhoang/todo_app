import 'dart:convert';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class DeviceUtils {
  static const String _deviceIdKey = 'persistent_device_id_v2';

  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<String> getDeviceId() async {
    try {
      String? storedDeviceId = await _secureStorage.read(key: _deviceIdKey);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        return storedDeviceId;
      }

      final newDeviceId = await _generatePersistentDeviceId();
      await _storeDeviceIdWithRetry(newDeviceId);

      return newDeviceId;
    } catch (e) {
      return await _createEmergencyDeviceId();
    }
  }

  static Future<String> _generatePersistentDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      final iosInfo = await deviceInfo.iosInfo;

      final hardwareFingerprint = [
        iosInfo.utsname.machine,
        iosInfo.model,
        iosInfo.systemName,
        iosInfo.localizedModel,
        iosInfo.isPhysicalDevice.toString(),
      ].where((element) => element.isNotEmpty).join('|');

      final bytes = utf8.encode(hardwareFingerprint);
      final digest = sha256.convert(bytes);
      final baseId = digest.toString().substring(0, 20);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      return 'ios_hw_${baseId}_${timestamp.substring(timestamp.length - 6)}';
    } catch (e) {
      final random = Random();
      final randomId = List.generate(
        16,
        (_) => random.nextInt(36).toRadixString(36),
      ).join();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      return 'ios_rnd_${randomId}_${timestamp.substring(timestamp.length - 8)}';
    }
  }

  static Future<void> _storeDeviceIdWithRetry(String deviceId) async {
    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _secureStorage.write(key: _deviceIdKey, value: deviceId);

        final verified = await _secureStorage.read(key: _deviceIdKey);
        if (verified == deviceId) {
          return;
        } else {
          throw Exception('Storage verification failed');
        }
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  static Future<String> _createEmergencyDeviceId() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random();
    final randomPart = List.generate(
      12,
      (_) => random.nextInt(36).toRadixString(36),
    ).join();

    return 'ios_emergency_${randomPart}_${timestamp.substring(timestamp.length - 8)}';
  }

  static Future<void> resetDeviceId() async {
    try {
      await _secureStorage.delete(key: _deviceIdKey);
    } catch (e) {
      // Silent fail for reset operation
    }
  }

  static Future<bool> hasStoredDeviceId() async {
    try {
      final storedId = await _secureStorage.read(key: _deviceIdKey);
      return storedId != null && storedId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, String>> getAllStoredData() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      return {};
    }
  }

  static Future<bool> testKeychainAccess() async {
    const testKey = 'keychain_test';
    final testValue = 'test_value_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _secureStorage.write(key: testKey, value: testValue);
      final readValue = await _secureStorage.read(key: testKey);
      await _secureStorage.delete(key: testKey);

      return readValue == testValue;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDetailedDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final deviceId = await getDeviceId();
    final hasStored = await hasStoredDeviceId();
    final keychainTest = await testKeychainAccess();
    final allData = await getAllStoredData();

    try {
      final iosInfo = await deviceInfo.iosInfo;

      return {
        'deviceId': deviceId,
        'hasStoredId': hasStored,
        'keychainWorking': keychainTest,
        'storedKeysCount': allData.length,
        'storedKeys': allData.keys.toList(),
        'platform': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'identifierForVendor': iosInfo.identifierForVendor,
        'localizedModel': iosInfo.localizedModel,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
        'hardware': {
          'machine': iosInfo.utsname.machine,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'sysname': iosInfo.utsname.sysname,
          'version': iosInfo.utsname.version,
        },
      };
    } catch (e) {
      return {
        'deviceId': deviceId,
        'hasStoredId': hasStored,
        'keychainWorking': keychainTest,
        'platform': 'iOS',
        'error': e.toString(),
      };
    }
  }
}
