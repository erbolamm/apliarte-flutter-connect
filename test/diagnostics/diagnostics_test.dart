import 'dart:async';

import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectDiagnostics emits events when enabled', () async {
    final diagnostics = ConnectDiagnostics(enabled: true);
    addTearDown(diagnostics.dispose);

    final expectation = expectLater(
      diagnostics.events,
      emits(isA<ConnectLogEvent>()),
    );

    diagnostics.emit(
      const ConnectLogEvent(
        level: ConnectLogLevel.info,
        message: 'enabled',
      ),
    );

    await expectation;
  });

  test('ConnectDiagnostics is silent when disabled', () async {
    final diagnostics = ConnectDiagnostics();
    addTearDown(diagnostics.dispose);

    diagnostics.emit(
      const ConnectLogEvent(
        level: ConnectLogLevel.info,
        message: 'disabled',
      ),
    );

    await expectLater(
      diagnostics.events.timeout(const Duration(milliseconds: 20)),
      emitsError(isA<TimeoutException>()),
    );
  });
}
