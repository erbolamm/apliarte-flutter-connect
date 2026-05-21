/// Diagnostics severity.
enum ConnectLogLevel { debug, info, warning, error }

/// Structured diagnostics event.
final class ConnectLogEvent {
  const ConnectLogEvent({
    required this.level,
    required this.message,
    this.category = 'general',
    this.data = const <String, Object?>{},
    this.timestamp,
  });

  final ConnectLogLevel level;
  final String message;
  final String category;
  final Map<String, Object?> data;
  final DateTime? timestamp;

  DateTime get occurredAt => timestamp ?? DateTime.now().toUtc();
}
