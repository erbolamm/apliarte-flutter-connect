import 'dart:async';

import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';

final class FakeConnectPlatform implements ConnectPlatform {
  FakeConnectPlatform({
    this.capabilities = const ConnectCapabilities(
      platformName: 'fake',
      supportsDiscovery: true,
      supportsAdvertising: true,
      supportsLocalNetworkTransport: true,
      supportsPermissionRequests: true,
    ),
    this.permissionStatus = PermissionStatus.granted,
  });

  final ConnectCapabilities capabilities;
  final PermissionStatus permissionStatus;
  final StreamController<DiscoveryEvent> _discoveryController =
      StreamController<DiscoveryEvent>.broadcast();

  int initializeCalls = 0;
  int startDiscoveryCalls = 0;
  int stopDiscoveryCalls = 0;
  int disposeCalls = 0;
  ConnectConfig? lastConfig;

  @override
  Stream<DiscoveryEvent> get discoveryEvents => _discoveryController.stream;

  void emitDiscoveryEvent(DiscoveryEvent event) {
    _discoveryController.add(event);
  }

  @override
  Future<void> initialize(ConnectConfig config) async {
    initializeCalls += 1;
    lastConfig = config;
  }

  @override
  Future<ConnectCapabilities> getCapabilities() async => capabilities;

  @override
  Future<PermissionSnapshot> checkPermissions(ConnectUseCase useCase) async {
    return _snapshot(useCase);
  }

  @override
  Future<PermissionSnapshot> requestPermissions(ConnectUseCase useCase) async {
    return _snapshot(useCase);
  }

  @override
  Future<void> startDiscovery(DiscoveryQuery query) async {
    startDiscoveryCalls += 1;
  }

  @override
  Future<void> stopDiscovery() async {
    stopDiscoveryCalls += 1;
  }

  @override
  Future<ConnectSession> connect(ConnectDevice device) async {
    return FakeConnectSession(device: device);
  }

  @override
  Future<void> sendFrame(String sessionId, ConnectFrame frame) async {}

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
    await _discoveryController.close();
  }

  PermissionSnapshot _snapshot(ConnectUseCase useCase) {
    return PermissionSnapshot(
      useCase: useCase,
      status: permissionStatus,
      requiredPermissions: PermissionSnapshot.defaultsFor(useCase),
      missingPermissions: permissionStatus == PermissionStatus.granted
          ? const <String>{}
          : PermissionSnapshot.defaultsFor(useCase),
    );
  }
}

final class FakeConnectSession implements ConnectSession {
  FakeConnectSession({required this.device}) : id = 'fake-${device.id}';

  final ConnectDevice device;
  final StreamController<SessionEvent> _eventsController =
      StreamController<SessionEvent>.broadcast();
  final StreamController<ConnectFrame> _framesController =
      StreamController<ConnectFrame>.broadcast();

  @override
  final String id;

  @override
  ConnectRole get role => ConnectRole.viewer;

  @override
  ConnectLifecycle get lifecycle =>
      _closed ? ConnectLifecycle.closed : ConnectLifecycle.connected;

  @override
  Stream<SessionEvent> get events => _eventsController.stream;

  @override
  Stream<ConnectFrame> get frames => _framesController.stream;

  bool _closed = false;

  @override
  Future<void> sendFrame(ConnectFrame frame) async {
    if (_closed) {
      throw const ConnectException(
        ConnectErrorCode.sessionEnded,
        'Cannot send frames after close.',
      );
    }
    _framesController.add(frame);
  }

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    _eventsController.add(
      SessionEvent(
        type: SessionEventType.closed,
        lifecycle: ConnectLifecycle.closed,
        sessionId: id,
        role: role,
        device: device,
      ),
    );
    await _eventsController.close();
    await _framesController.close();
  }
}
