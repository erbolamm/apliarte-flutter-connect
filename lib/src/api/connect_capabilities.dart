import '../session/connect_role.dart';

/// Capabilities reported by the current platform implementation.
final class ConnectCapabilities {
  const ConnectCapabilities({
    required this.platformName,
    this.supportsDiscovery = false,
    this.supportsAdvertising = false,
    this.supportsLocalNetworkTransport = false,
    this.supportsPermissionRequests = false,
    this.supportedRoles = const <ConnectRole>{
      ConnectRole.host,
      ConnectRole.viewer
    },
  });

  final String platformName;
  final bool supportsDiscovery;
  final bool supportsAdvertising;
  final bool supportsLocalNetworkTransport;
  final bool supportsPermissionRequests;
  final Set<ConnectRole> supportedRoles;

  static const ConnectCapabilities unsupported = ConnectCapabilities(
    platformName: 'unsupported',
  );

  Map<String, Object> toMap() {
    return <String, Object>{
      'platformName': platformName,
      'supportsDiscovery': supportsDiscovery,
      'supportsAdvertising': supportsAdvertising,
      'supportsLocalNetworkTransport': supportsLocalNetworkTransport,
      'supportsPermissionRequests': supportsPermissionRequests,
      'supportedRoles':
          supportedRoles.map((ConnectRole role) => role.name).toList(),
    };
  }

  static ConnectCapabilities fromMap(Map<Object?, Object?> map) {
    final roles = map['supportedRoles'];
    return ConnectCapabilities(
      platformName: (map['platformName'] as String?) ?? 'unknown',
      supportsDiscovery: (map['supportsDiscovery'] as bool?) ?? false,
      supportsAdvertising: (map['supportsAdvertising'] as bool?) ?? false,
      supportsLocalNetworkTransport:
          (map['supportsLocalNetworkTransport'] as bool?) ?? false,
      supportsPermissionRequests:
          (map['supportsPermissionRequests'] as bool?) ?? false,
      supportedRoles: roles is Iterable<Object?>
          ? roles
              .whereType<String>()
              .map(
                (String name) => ConnectRole.values.firstWhere(
                  (ConnectRole role) => role.name == name,
                  orElse: () => ConnectRole.viewer,
                ),
              )
              .toSet()
          : const <ConnectRole>{ConnectRole.host, ConnectRole.viewer},
    );
  }
}
