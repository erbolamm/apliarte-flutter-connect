import '../discovery/discovery_models.dart';
import '../errors/connect_exception.dart';
import 'connect_role.dart';
import 'session_state.dart';

/// Session event kind.
enum SessionEventType {
  connecting,
  connected,
  frameSent,
  frameReceived,
  closed,
  failed
}

/// Structured session lifecycle event.
final class SessionEvent {
  const SessionEvent({
    required this.type,
    required this.lifecycle,
    this.sessionId,
    this.role,
    this.device,
    this.error,
    this.timestamp,
  });

  final SessionEventType type;
  final ConnectLifecycle lifecycle;
  final String? sessionId;
  final ConnectRole? role;
  final ConnectDevice? device;
  final ConnectException? error;
  final DateTime? timestamp;

  DateTime get occurredAt => timestamp ?? DateTime.now().toUtc();
}
