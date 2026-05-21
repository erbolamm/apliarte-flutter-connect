import '../session/connect_role.dart';

/// Coarse permission status for local connectivity flows.
enum PermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  restricted
}

/// Snapshot of permissions needed for a single use case.
final class PermissionSnapshot {
  const PermissionSnapshot({
    required this.useCase,
    required this.status,
    this.requiredPermissions = const <String>{},
    this.missingPermissions = const <String>{},
    this.canRequest = true,
    this.message,
  });

  final ConnectUseCase useCase;
  final PermissionStatus status;
  final Set<String> requiredPermissions;
  final Set<String> missingPermissions;
  final bool canRequest;
  final String? message;

  bool get isGranted => status == PermissionStatus.granted;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'useCase': useCase.name,
      'status': status.name,
      'requiredPermissions': requiredPermissions.toList(),
      'missingPermissions': missingPermissions.toList(),
      'canRequest': canRequest,
      'message': message,
    };
  }

  static PermissionSnapshot fromMap(Map<Object?, Object?> map) {
    return PermissionSnapshot(
      useCase: _useCaseFromName(map['useCase'] as String?),
      status: _statusFromName(map['status'] as String?),
      requiredPermissions: _stringSet(map['requiredPermissions']),
      missingPermissions: _stringSet(map['missingPermissions']),
      canRequest: (map['canRequest'] as bool?) ?? true,
      message: map['message'] as String?,
    );
  }

  static Set<String> defaultsFor(ConnectUseCase useCase) {
    return switch (useCase) {
      ConnectUseCase.discoveryOnly => <String>{'localNetwork'},
      ConnectUseCase.projectionHost => <String>{
          'localNetwork',
          'multicast',
          'networkState',
        },
      ConnectUseCase.projectionViewer => <String>{'localNetwork'},
    };
  }

  static Set<String> _stringSet(Object? value) {
    if (value is! Iterable<Object?>) {
      return const <String>{};
    }
    return value.whereType<String>().toSet();
  }

  static PermissionStatus _statusFromName(String? name) {
    return PermissionStatus.values.firstWhere(
      (PermissionStatus status) => status.name == name,
      orElse: () => PermissionStatus.unknown,
    );
  }

  static ConnectUseCase _useCaseFromName(String? name) {
    return ConnectUseCase.values.firstWhere(
      (ConnectUseCase useCase) => useCase.name == name,
      orElse: () => ConnectUseCase.discoveryOnly,
    );
  }
}
