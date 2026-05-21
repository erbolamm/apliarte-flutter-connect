import 'dart:async';

import 'package:flutter/services.dart';

import '../api/connect_capabilities.dart';
import '../api/connect_platform.dart';
import '../config/connect_config.dart';
import '../discovery/discovery_models.dart';
import '../errors/connect_exception.dart';
import '../permissions/permission_models.dart';
import '../session/connect_role.dart';
import '../session/connect_session.dart';
import '../streaming/connect_frame.dart';
import 'channel_names.dart';

/// MethodChannel-backed platform skeleton.
final class MethodChannelConnectPlatform implements ConnectPlatform {
  MethodChannelConnectPlatform({MethodChannel? methodChannel})
      : _methodChannel =
            methodChannel ?? const MethodChannel(ConnectChannelNames.methods);

  final MethodChannel _methodChannel;
  final StreamController<DiscoveryEvent> _discoveryController =
      StreamController<DiscoveryEvent>.broadcast();

  @override
  Stream<DiscoveryEvent> get discoveryEvents => _discoveryController.stream;

  @override
  Future<void> initialize(ConnectConfig config) async {
    await _invoke<void>(
      ConnectMethodNames.initialize,
      <String, Object>{ConnectPayloadKeys.config: config.toMap()},
    );
  }

  @override
  Future<ConnectCapabilities> getCapabilities() async {
    final result = await _invoke<Map<Object?, Object?>>(
      ConnectMethodNames.getCapabilities,
    );
    if (result == null) {
      return ConnectCapabilities.unsupported;
    }
    return ConnectCapabilities.fromMap(result);
  }

  @override
  Future<PermissionSnapshot> checkPermissions(ConnectUseCase useCase) async {
    final result = await _invoke<Map<Object?, Object?>>(
      ConnectMethodNames.checkPermissions,
      <String, Object>{ConnectPayloadKeys.useCase: useCase.name},
    );
    if (result == null) {
      return PermissionSnapshot(
        useCase: useCase,
        status: PermissionStatus.unknown,
        requiredPermissions: PermissionSnapshot.defaultsFor(useCase),
      );
    }
    return PermissionSnapshot.fromMap(result);
  }

  @override
  Future<PermissionSnapshot> requestPermissions(ConnectUseCase useCase) async {
    final result = await _invoke<Map<Object?, Object?>>(
      ConnectMethodNames.requestPermissions,
      <String, Object>{ConnectPayloadKeys.useCase: useCase.name},
    );
    if (result == null) {
      return PermissionSnapshot(
        useCase: useCase,
        status: PermissionStatus.unknown,
        requiredPermissions: PermissionSnapshot.defaultsFor(useCase),
      );
    }
    return PermissionSnapshot.fromMap(result);
  }

  @override
  Future<void> startDiscovery(DiscoveryQuery query) async {
    await _invoke<void>(
      ConnectMethodNames.startDiscovery,
      <String, Object?>{ConnectPayloadKeys.query: query.toMap()},
    );
  }

  @override
  Future<void> stopDiscovery() async {
    await _invoke<void>(ConnectMethodNames.stopDiscovery);
  }

  @override
  Future<ConnectSession> connect(ConnectDevice device) {
    throw const ConnectException(
      ConnectErrorCode.platformUnsupported,
      'Real native/WebSocket transport is not implemented in 0.1.0-dev.1.',
    );
  }

  @override
  Future<void> sendFrame(String sessionId, ConnectFrame frame) {
    throw const ConnectException(
      ConnectErrorCode.platformUnsupported,
      'Real frame transport is not implemented in 0.1.0-dev.1.',
    );
  }

  @override
  Future<void> dispose() async {
    await _invoke<void>(ConnectMethodNames.dispose);
    await _discoveryController.close();
  }

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _methodChannel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error) {
      throw ConnectException(
        ConnectErrorCode.nativeFailure,
        error.message ?? 'Native platform call failed: $method.',
        cause: error,
      );
    } on MissingPluginException catch (error) {
      throw ConnectException(
        ConnectErrorCode.platformUnsupported,
        'No native implementation is registered for $method.',
        cause: error,
      );
    }
  }
}
