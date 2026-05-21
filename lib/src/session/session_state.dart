import '../errors/connect_exception.dart';

/// Lifecycle state for discovery, advertising, and session flows.
enum ConnectLifecycle {
  idle,
  discovering,
  advertising,
  connecting,
  connected,
  reconnecting,
  closing,
  closed,
  failed,
}

/// Minimal state transition guard used by the facade and tests.
final class ConnectLifecycleMachine {
  ConnectLifecycleMachine([this._state = ConnectLifecycle.idle]);

  ConnectLifecycle _state;

  ConnectLifecycle get state => _state;

  void transitionTo(ConnectLifecycle next) {
    if (!canTransition(_state, next)) {
      throw ConnectException(
        ConnectErrorCode.invalidLifecycleTransition,
        'Cannot transition from ${_state.name} to ${next.name}.',
      );
    }
    _state = next;
  }

  static bool canTransition(ConnectLifecycle from, ConnectLifecycle to) {
    if (from == to) {
      return true;
    }
    return switch (from) {
      ConnectLifecycle.idle => to == ConnectLifecycle.discovering ||
          to == ConnectLifecycle.advertising ||
          to == ConnectLifecycle.connecting ||
          to == ConnectLifecycle.closed,
      ConnectLifecycle.discovering =>
        to == ConnectLifecycle.idle || to == ConnectLifecycle.connecting,
      ConnectLifecycle.advertising =>
        to == ConnectLifecycle.idle || to == ConnectLifecycle.connected,
      ConnectLifecycle.connecting =>
        to == ConnectLifecycle.connected || to == ConnectLifecycle.failed,
      ConnectLifecycle.connected =>
        to == ConnectLifecycle.reconnecting || to == ConnectLifecycle.closing,
      ConnectLifecycle.reconnecting =>
        to == ConnectLifecycle.connected || to == ConnectLifecycle.failed,
      ConnectLifecycle.closing => to == ConnectLifecycle.closed,
      ConnectLifecycle.closed => to == ConnectLifecycle.idle,
      ConnectLifecycle.failed =>
        to == ConnectLifecycle.idle || to == ConnectLifecycle.closed,
    };
  }
}
