import 'dart:io';

class ApiBaseUrl {
  // Emulator URL (Android emulator uses 10.0.2.2 to reach host machine)
  static const String _emulatorUrl = "http://10.0.2.2:8000/api/";

  // Real device URL (Your local network IP)
  static const String _realDeviceUrl = "http://192.168.1.67:8000/api/";

  /// Automatically selects the correct base URL based on the platform
  /// Returns emulator URL for Android emulator, real device URL otherwise
  static String get baseUrl {
    // Check if running on Android emulator
    if (Platform.isAndroid) {
      // Android emulator detection: check if it's the default AVD
      // The emulator typically has specific characteristics
      return _isEmulator ? _emulatorUrl : _realDeviceUrl;
    }
    // For iOS simulator or other platforms
    return _realDeviceUrl;
  }

  /// Detects if running on Android emulator
  static bool get _isEmulator {
    // You can also manually override this for testing
    // return true; // Force emulator mode
    // return false; // Force real device mode

    // For Android, we'll use the real device URL by default
    // and emulator URL only when explicitly needed
    // You can toggle this based on your testing needs
    return Platform.environment.containsKey('ANDROID_EMULATOR') ||
        Platform.environment.containsKey('FLUTTER_TEST');
  }

  /// Manual override for testing (call this to switch modes)
  static String getUrl({bool forceEmulator = false}) {
    return forceEmulator ? _emulatorUrl : _realDeviceUrl;
  }
}
