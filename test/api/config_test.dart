import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectConfig exposes approved defaults', () {
    final config = ConnectConfig(appId: 'com.apliarte.test');

    expect(config.serviceType, '_apliarte-connect._tcp');
    expect(config.defaultPort, 8080);
    expect(config.protocolVersion, 1);
    expect(config.diagnosticsEnabled, isFalse);
  });

  test('ConnectConfig allows CalcaApp service override', () {
    final config = ConnectConfig(
      appId: 'com.apliarte.calcaapp',
      serviceType: '_calcaconnect._tcp',
    );

    expect(config.serviceType, '_calcaconnect._tcp');
  });

  test('ConnectConfig rejects invalid service type', () {
    expect(
      () => ConnectConfig(
          appId: 'com.apliarte.test', serviceType: 'calcaconnect'),
      throwsA(isA<ConnectException>()),
    );
  });
}
