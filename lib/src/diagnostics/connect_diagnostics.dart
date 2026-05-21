import 'dart:async';

import 'connect_log_event.dart';

/// Release-safe diagnostics stream that can be disabled by configuration.
final class ConnectDiagnostics {
  ConnectDiagnostics({bool enabled = false}) : _enabled = enabled;

  final StreamController<ConnectLogEvent> _controller =
      StreamController<ConnectLogEvent>.broadcast();

  bool _enabled;
  bool _disposed = false;

  bool get enabled => _enabled;
  Stream<ConnectLogEvent> get events => _controller.stream;

  void configure({required bool enabled}) {
    if (_disposed) {
      return;
    }
    _enabled = enabled;
  }

  void emit(ConnectLogEvent event) {
    if (!_enabled || _disposed) {
      return;
    }
    _controller.add(event);
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _controller.close();
  }
}
