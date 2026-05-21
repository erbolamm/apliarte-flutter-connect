/// Method and event channel names for protocol v1.
final class ConnectChannelNames {
  const ConnectChannelNames._();

  static const String methods = 'com.apliarte.flutter_connect/methods';
  static const String discoveryEvents =
      'com.apliarte.flutter_connect/discovery_events';
  static const String sessionEvents =
      'com.apliarte.flutter_connect/session_events';
  static const String diagnostics = 'com.apliarte.flutter_connect/diagnostics';
}

/// Method names supported by the native protocol v1 skeleton.
final class ConnectMethodNames {
  const ConnectMethodNames._();

  static const String initialize = 'initialize';
  static const String getCapabilities = 'getCapabilities';
  static const String checkPermissions = 'checkPermissions';
  static const String requestPermissions = 'requestPermissions';
  static const String startDiscovery = 'startDiscovery';
  static const String stopDiscovery = 'stopDiscovery';
  static const String connect = 'connect';
  static const String sendFrame = 'sendFrame';
  static const String closeSession = 'closeSession';
  static const String dispose = 'dispose';
}

/// Shared payload keys for method-channel messages.
final class ConnectPayloadKeys {
  const ConnectPayloadKeys._();

  static const String config = 'config';
  static const String useCase = 'useCase';
  static const String query = 'query';
  static const String device = 'device';
  static const String sessionId = 'sessionId';
  static const String frame = 'frame';
}
