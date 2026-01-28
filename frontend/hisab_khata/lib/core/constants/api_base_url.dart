import 'dart:io';

class ApiBaseUrl {
  // Emulator URL (Android emulator uses 10.0.2.2 to reach host machine)
  static const String _emulatorUrl = "http://10.0.2.2:8000/api/";

  // Real device URL (Your local network IP)
  static const String _realDeviceUrl = "http://192.168.1.67:8000/api/";

  static String get baseUrl {
    if (Platform.isAndroid) {
      return _isEmulator ? _emulatorUrl : _realDeviceUrl;
    }
    return _realDeviceUrl;
  }

  static bool get _isEmulator {
    return true;
  }

  static String getUrl({bool forceEmulator = false}) {
    return forceEmulator ? _emulatorUrl : _realDeviceUrl;
  }
}
