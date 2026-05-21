import 'dart:async';

import '../config/connect_config.dart';
import '../diagnostics/connect_diagnostics.dart';
import '../diagnostics/connect_log_event.dart';
import '../discovery/discovery_models.dart';
import '../errors/connect_exception.dart';
import '../method_channel/method_channel_connect_platform.dart';
import '../permissions/permission_models.dart';
import '../session/connect_role.dart';
import '../session/connect_session.dart';
import '../session/session_state.dart';
import 'connect_capabilities.dart';
import 'connect_platform.dart';

/// Main public facade for apliarte_flutter_connect.
final class ApliarteFlutterConnect {
  ApliarteFlutterConnect({ConnectPlatform? platform})
      : _platform = platform ?? MethodChannelConnectPlatform() {
    _discoverySubscription =
        _platform.discoveryEvents.listen(_onDiscoveryEvent);
  }

  static final ApliarteFlutterConnect instance = ApliarteFlutterConnect();

  final ConnectPlatform _platform;
  final Map<String, ConnectDevice> _devices = <String, ConnectDevice>{};
  final StreamController<List<ConnectDevice>> _devicesController =
      StreamController<List<ConnectDevice>>.broadcast();
  final StreamController<DiscoveryEvent> _discoveryController =
      StreamController<DiscoveryEvent>.broadcast();
  final ConnectDiagnostics diagnostics = ConnectDiagnostics();

  late final StreamSubscription<DiscoveryEvent> _discoverySubscription;
  ConnectConfig? _config;
  ConnectLifecycle _lifecycle = ConnectLifecycle.idle;
  bool _disposed = false;

  ConnectLifecycle get lifecycle => _lifecycle;
  ConnectConfig? get config => _config;
  Stream<List<ConnectDevice>> get devices => _devicesController.stream;
  Stream<DiscoveryEvent> get discoveryEvents => _discoveryController.stream;

  bool get isInitialized => _config != null && !_disposed;

  Future<void> initialize(ConnectConfig config) async {
    _ensureNotDisposed();
    final currentConfig = _config;
    if (currentConfig != null) {
      if (!_hasSamePlatformConfig(currentConfig, config)) {
        throw const ConnectException(
          ConnectErrorCode.invalidConfiguration,
          'ApliarteFlutterConnect is already initialized with a different configuration. Dispose and create a new instance to change platform settings.',
        );
      }
      diagnostics.configure(enabled: config.diagnosticsEnabled);
      _config = config;
      return;
    }
    diagnostics.configure(enabled: config.diagnosticsEnabled);
    await _platform.initialize(config);
    _config = config;
    diagnostics.emit(
      const ConnectLogEvent(
        level: ConnectLogLevel.info,
        category: 'lifecycle',
        message: 'ApliarteFlutterConnect initialized.',
      ),
    );
  }

  Future<ConnectCapabilities> capabilities() {
    _ensureNotDisposed();
    return _platform.getCapabilities();
  }

  Future<PermissionSnapshot> checkPermissions({
    ConnectUseCase useCase = ConnectUseCase.discoveryOnly,
  }) {
    _ensureNotDisposed();
    return _platform.checkPermissions(useCase);
  }

  Future<PermissionSnapshot> requestPermissions({
    required ConnectUseCase useCase,
  }) {
    _ensureNotDisposed();
    return _platform.requestPermissions(useCase);
  }

  Future<void> startDiscovery([DiscoveryQuery? query]) async {
    _ensureInitialized();
    if (_lifecycle == ConnectLifecycle.discovering) {
      return;
    }
    final effectiveQuery = query ??
        DiscoveryQuery(
          serviceType: _config?.serviceType ?? ConnectConfig.defaultServiceType,
        );
    await _platform.startDiscovery(effectiveQuery);
    _lifecycle = ConnectLifecycle.discovering;
    _addDiscoveryEvent(
      const DiscoveryEvent(type: DiscoveryEventType.started),
    );
  }

  Future<void> stopDiscovery() async {
    _ensureInitialized();
    if (_lifecycle != ConnectLifecycle.discovering) {
      return;
    }
    await _platform.stopDiscovery();
    _lifecycle = ConnectLifecycle.idle;
    _addDiscoveryEvent(
      const DiscoveryEvent(type: DiscoveryEventType.stopped),
    );
  }

  Future<ConnectSession> connect(ConnectDevice device) async {
    _ensureInitialized();
    _lifecycle = ConnectLifecycle.connecting;
    try {
      final session = await _platform.connect(device);
      _lifecycle = ConnectLifecycle.connected;
      return session;
    } on ConnectException {
      _lifecycle = ConnectLifecycle.failed;
      rethrow;
    } on Object catch (error) {
      _lifecycle = ConnectLifecycle.failed;
      throw ConnectException(
        ConnectErrorCode.nativeFailure,
        'Unexpected connection failure.',
        cause: error,
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _lifecycle = ConnectLifecycle.closed;
    await _discoverySubscription.cancel();
    await _platform.dispose();
    await _devicesController.close();
    await _discoveryController.close();
    await diagnostics.dispose();
  }

  void _onDiscoveryEvent(DiscoveryEvent event) {
    if (_disposed) {
      return;
    }
    switch (event.type) {
      case DiscoveryEventType.deviceFound:
        final device = event.device;
        if (device != null) {
          _devices[device.id] = device;
          _devicesController
              .add(List<ConnectDevice>.unmodifiable(_devices.values));
        }
      case DiscoveryEventType.deviceLost:
        final device = event.device;
        if (device != null) {
          _devices.remove(device.id);
          _devicesController
              .add(List<ConnectDevice>.unmodifiable(_devices.values));
        }
      case DiscoveryEventType.started:
      case DiscoveryEventType.stopped:
      case DiscoveryEventType.failed:
        break;
    }
    _addDiscoveryEvent(event);
  }

  void _addDiscoveryEvent(DiscoveryEvent event) {
    if (!_discoveryController.isClosed) {
      _discoveryController.add(event);
    }
  }

  bool _hasSamePlatformConfig(ConnectConfig a, ConnectConfig b) {
    return a.appId == b.appId &&
        a.serviceType == b.serviceType &&
        a.defaultPort == b.defaultPort &&
        a.protocolVersion == b.protocolVersion &&
        a.operationTimeout == b.operationTimeout &&
        a.maxFrameBytes == b.maxFrameBytes;
  }

  void _ensureInitialized() {
    _ensureNotDisposed();
    if (_config == null) {
      throw const ConnectException(
        ConnectErrorCode.notInitialized,
        'Call initialize() before using this operation.',
      );
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const ConnectException(
        ConnectErrorCode.sessionEnded,
        'ApliarteFlutterConnect has been disposed.',
      );
    }
  }
}
