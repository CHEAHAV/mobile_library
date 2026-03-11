import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class Device{
  static Future<bool> _isEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return !info.isPhysicalDevice;
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return !info.isPhysicalDevice;
    }
    return false;
  }

  static Future<String> get localUrl async {
    if (Platform.isAndroid || Platform.isIOS) {
      final emulator = await _isEmulator();
      if (Platform.isAndroid) {
        return emulator
            ? 'http://10.0.2.2:8000'       // Android emulator
            : 'http://192.168.1.13:8000';  // Android real device
      }
      return emulator
          ? 'http://localhost:8000'         // iOS simulator
          : 'http://192.168.1.13:8000';    // iOS real device
    }
    return 'http://localhost:8000';         // Desktop / Web
  }
}