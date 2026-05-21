import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectDevice requires IP literal for connectable peers', () {
    expect(
      () => ConnectDevice(
        id: 'peer-1',
        displayName: 'Peer 1',
        serviceType: '_apliarte-connect._tcp',
        ipAddress: 'android.local',
        port: 8080,
        advertisedRole: ConnectRole.host,
      ),
      throwsA(
        isA<ConnectException>().having(
          (ConnectException error) => error.code,
          'code',
          ConnectErrorCode.resolveFailed,
        ),
      ),
    );
  });

  test('ConnectDevice accepts IPv4 literal and keeps hostname as metadata only',
      () {
    final device = ConnectDevice(
      id: 'peer-1',
      displayName: 'Peer 1',
      serviceType: '_apliarte-connect._tcp',
      ipAddress: '192.168.1.22',
      port: 8080,
      hostname: 'android.local',
      advertisedRole: ConnectRole.host,
    );

    expect(device.endpoint, '192.168.1.22:8080');
    expect(device.hostname, 'android.local');
  });
}
