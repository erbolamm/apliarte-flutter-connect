import '../config/connect_config.dart';
import '../discovery/discovery_models.dart';
import '../permissions/permission_models.dart';
import '../session/connect_role.dart';
import '../session/connect_session.dart';
import '../streaming/connect_frame.dart';
import 'connect_capabilities.dart';

/// Advanced seam between the public facade and platform implementations.
///
/// This interface is exported so tests and custom platform adapters can inject
/// deterministic implementations. Normal consumers should use
/// [ApliarteFlutterConnect.instance] instead of implementing this directly.
abstract interface class ConnectPlatform {
  Stream<DiscoveryEvent> get discoveryEvents;

  Future<void> initialize(ConnectConfig config);
  Future<ConnectCapabilities> getCapabilities();
  Future<PermissionSnapshot> checkPermissions(ConnectUseCase useCase);
  Future<PermissionSnapshot> requestPermissions(ConnectUseCase useCase);
  Future<void> startDiscovery(DiscoveryQuery query);
  Future<void> stopDiscovery();
  Future<ConnectSession> connect(ConnectDevice device);
  Future<void> sendFrame(String sessionId, ConnectFrame frame);
  Future<void> dispose();
}
