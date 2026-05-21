import '../errors/connect_exception.dart';

/// Runtime configuration for the connection facade.
final class ConnectConfig {
  factory ConnectConfig({
    required String appId,
    String serviceType = defaultServiceType,
    int defaultPort = defaultConnectPort,
    int protocolVersion = defaultProtocolVersion,
    bool diagnosticsEnabled = false,
    Duration operationTimeout = const Duration(seconds: 5),
    int maxFrameBytes = defaultMaxFrameBytes,
  }) {
    _validate(
      appId: appId,
      serviceType: serviceType,
      defaultPort: defaultPort,
      protocolVersion: protocolVersion,
      operationTimeout: operationTimeout,
      maxFrameBytes: maxFrameBytes,
    );
    return ConnectConfig._(
      appId: appId,
      serviceType: serviceType,
      defaultPort: defaultPort,
      protocolVersion: protocolVersion,
      diagnosticsEnabled: diagnosticsEnabled,
      operationTimeout: operationTimeout,
      maxFrameBytes: maxFrameBytes,
    );
  }

  const ConnectConfig._({
    required this.appId,
    required this.serviceType,
    required this.defaultPort,
    required this.protocolVersion,
    required this.diagnosticsEnabled,
    required this.operationTimeout,
    required this.maxFrameBytes,
  });

  static const String defaultServiceType = '_apliarte-connect._tcp';
  static const int defaultConnectPort = 8080;
  static const int defaultProtocolVersion = 1;
  static const int defaultMaxFrameBytes = 5 * 1024 * 1024;

  final String appId;
  final String serviceType;
  final int defaultPort;
  final int protocolVersion;
  final bool diagnosticsEnabled;
  final Duration operationTimeout;
  final int maxFrameBytes;

  ConnectConfig copyWith({
    String? appId,
    String? serviceType,
    int? defaultPort,
    int? protocolVersion,
    bool? diagnosticsEnabled,
    Duration? operationTimeout,
    int? maxFrameBytes,
  }) {
    return ConnectConfig(
      appId: appId ?? this.appId,
      serviceType: serviceType ?? this.serviceType,
      defaultPort: defaultPort ?? this.defaultPort,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      diagnosticsEnabled: diagnosticsEnabled ?? this.diagnosticsEnabled,
      operationTimeout: operationTimeout ?? this.operationTimeout,
      maxFrameBytes: maxFrameBytes ?? this.maxFrameBytes,
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'appId': appId,
      'serviceType': serviceType,
      'defaultPort': defaultPort,
      'protocolVersion': protocolVersion,
      'diagnosticsEnabled': diagnosticsEnabled,
      'operationTimeoutMillis': operationTimeout.inMilliseconds,
      'maxFrameBytes': maxFrameBytes,
    };
  }

  static void _validate({
    required String appId,
    required String serviceType,
    required int defaultPort,
    required int protocolVersion,
    required Duration operationTimeout,
    required int maxFrameBytes,
  }) {
    if (appId.trim().isEmpty) {
      throw const ConnectException(
        ConnectErrorCode.invalidConfiguration,
        'appId must not be empty.',
      );
    }
    if (!RegExp(r'^_[a-zA-Z0-9-]+\._(tcp|udp)$').hasMatch(serviceType)) {
      throw ConnectException(
        ConnectErrorCode.invalidConfiguration,
        'serviceType must look like _service._tcp or _service._udp: $serviceType.',
      );
    }
    if (defaultPort < 1 || defaultPort > 65535) {
      throw const ConnectException(
        ConnectErrorCode.invalidConfiguration,
        'defaultPort must be between 1 and 65535.',
      );
    }
    if (protocolVersion < 1) {
      throw const ConnectException(
        ConnectErrorCode.invalidConfiguration,
        'protocolVersion must be positive.',
      );
    }
    if (operationTimeout <= Duration.zero) {
      throw const ConnectException(
        ConnectErrorCode.invalidConfiguration,
        'operationTimeout must be positive.',
      );
    }
    if (maxFrameBytes < 1) {
      throw const ConnectException(
        ConnectErrorCode.invalidConfiguration,
        'maxFrameBytes must be positive.',
      );
    }
  }
}
