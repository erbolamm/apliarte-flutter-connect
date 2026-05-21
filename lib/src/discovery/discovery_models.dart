import '../config/connect_config.dart';
import '../errors/connect_exception.dart';
import '../session/connect_role.dart';

/// A connectable device discovered on the local network.
final class ConnectDevice {
  factory ConnectDevice({
    required String id,
    required String displayName,
    required String serviceType,
    required String ipAddress,
    required int port,
    String? hostname,
    required ConnectRole advertisedRole,
    Map<String, String> txt = const <String, String>{},
    DateTime? resolvedAt,
  }) {
    _validate(
      id: id,
      displayName: displayName,
      serviceType: serviceType,
      ipAddress: ipAddress,
      port: port,
    );
    return ConnectDevice._(
      id: id,
      displayName: displayName,
      serviceType: serviceType,
      ipAddress: ipAddress,
      port: port,
      hostname: hostname,
      advertisedRole: advertisedRole,
      txt: Map<String, String>.unmodifiable(txt),
      resolvedAt: resolvedAt ?? DateTime.now().toUtc(),
    );
  }

  const ConnectDevice._({
    required this.id,
    required this.displayName,
    required this.serviceType,
    required this.ipAddress,
    required this.port,
    required this.hostname,
    required this.advertisedRole,
    required this.txt,
    required this.resolvedAt,
  });

  final String id;
  final String displayName;
  final String serviceType;
  final String ipAddress;
  final int port;
  final String? hostname;
  final ConnectRole advertisedRole;
  final Map<String, String> txt;
  final DateTime resolvedAt;

  String get endpoint => '$ipAddress:$port';

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'displayName': displayName,
      'serviceType': serviceType,
      'ipAddress': ipAddress,
      'port': port,
      'hostname': hostname,
      'advertisedRole': advertisedRole.name,
      'txt': txt,
      'resolvedAt': resolvedAt.toIso8601String(),
    };
  }

  static ConnectDevice fromMap(Map<Object?, Object?> map) {
    return ConnectDevice(
      id: map['id'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      serviceType:
          map['serviceType'] as String? ?? ConnectConfig.defaultServiceType,
      ipAddress: map['ipAddress'] as String? ?? '',
      port: map['port'] as int? ?? 0,
      hostname: map['hostname'] as String?,
      advertisedRole: _roleFromName(map['advertisedRole'] as String?),
      txt: _stringMap(map['txt']),
      resolvedAt:
          DateTime.tryParse(map['resolvedAt'] as String? ?? '')?.toUtc(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectDevice &&
        other.id == id &&
        other.endpoint == endpoint;
  }

  @override
  int get hashCode => Object.hash(id, endpoint);

  static bool isIpLiteral(String value) {
    return InternetAddressValidator.isIpLiteral(value);
  }

  static ConnectRole _roleFromName(String? name) {
    return ConnectRole.values.firstWhere(
      (ConnectRole role) => role.name == name,
      orElse: () => ConnectRole.viewer,
    );
  }

  static Map<String, String> _stringMap(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return const <String, String>{};
    }
    return value.map(
      (Object? key, Object? value) => MapEntry('$key', '$value'),
    );
  }

  static void _validate({
    required String id,
    required String displayName,
    required String serviceType,
    required String ipAddress,
    required int port,
  }) {
    if (id.trim().isEmpty) {
      throw const ConnectException(
        ConnectErrorCode.resolveFailed,
        'Discovered devices must have a non-empty id.',
      );
    }
    if (displayName.trim().isEmpty) {
      throw const ConnectException(
        ConnectErrorCode.resolveFailed,
        'Discovered devices must have a display name.',
      );
    }
    if (!RegExp(r'^_[a-zA-Z0-9-]+\._(tcp|udp)$').hasMatch(serviceType)) {
      throw ConnectException(
        ConnectErrorCode.resolveFailed,
        'Invalid service type: $serviceType.',
      );
    }
    if (!isIpLiteral(ipAddress)) {
      throw ConnectException(
        ConnectErrorCode.resolveFailed,
        'ConnectDevice.ipAddress must be an IP literal, not a hostname: $ipAddress.',
      );
    }
    if (port < 1 || port > 65535) {
      throw const ConnectException(
        ConnectErrorCode.resolveFailed,
        'ConnectDevice.port must be between 1 and 65535.',
      );
    }
  }
}

/// Discovery query used by platform discovery implementations.
final class DiscoveryQuery {
  const DiscoveryQuery({
    this.serviceType = ConnectConfig.defaultServiceType,
    this.role,
    this.includeSelf = false,
  });

  final String serviceType;
  final ConnectRole? role;
  final bool includeSelf;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'serviceType': serviceType,
      'role': role?.name,
      'includeSelf': includeSelf,
    };
  }
}

/// Discovery event kind.
enum DiscoveryEventType { started, deviceFound, deviceLost, stopped, failed }

/// Structured discovery event.
final class DiscoveryEvent {
  const DiscoveryEvent({
    required this.type,
    this.device,
    this.message,
    this.timestamp,
  });

  final DiscoveryEventType type;
  final ConnectDevice? device;
  final String? message;
  final DateTime? timestamp;

  DateTime get occurredAt => timestamp ?? DateTime.now().toUtc();
}

/// Small IP literal validator that avoids importing dart:io in public models.
final class InternetAddressValidator {
  const InternetAddressValidator._();

  static final RegExp _ipv4 = RegExp(
    r'^(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})(\.(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})){3}$',
  );

  static final RegExp _ipv6 = RegExp(r'^[0-9a-fA-F:]+$');

  static bool isIpLiteral(String value) {
    if (_ipv4.hasMatch(value)) {
      return true;
    }
    return value.contains(':') && _ipv6.hasMatch(value);
  }
}
