import '../streaming/connect_frame.dart';
import 'connect_role.dart';
import 'session_event.dart';
import 'session_state.dart';

/// Public session contract for future WebSocket LAN sessions.
abstract interface class ConnectSession {
  String get id;
  ConnectRole get role;
  ConnectLifecycle get lifecycle;
  Stream<SessionEvent> get events;
  Stream<ConnectFrame> get frames;

  Future<void> sendFrame(ConnectFrame frame);
  Future<void> close();
}
