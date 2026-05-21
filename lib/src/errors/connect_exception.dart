/// Stable error codes exposed by the package.
enum ConnectErrorCode {
  notInitialized,
  permissionDenied,
  permissionPermanentlyDenied,
  discoveryUnavailable,
  resolveFailed,
  hostUnreachable,
  connectionTimeout,
  protocolMismatch,
  roleNotAllowed,
  approvalRejected,
  sessionEnded,
  frameTooLarge,
  invalidFrame,
  invalidConfiguration,
  invalidLifecycleTransition,
  platformUnsupported,
  nativeFailure,
}

/// Typed exception used by the public API instead of leaking platform failures.
final class ConnectException implements Exception {
  const ConnectException(this.code, this.message, {this.cause});

  final ConnectErrorCode code;
  final String message;
  final Object? cause;

  @override
  String toString() {
    final suffix = cause == null ? '' : ' Cause: $cause';
    return 'ConnectException(${code.name}): $message$suffix';
  }
}
