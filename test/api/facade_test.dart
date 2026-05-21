import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_connect_platform.dart';

void main() {
  test('facade returns fake capabilities and permission snapshots', () async {
    final platform = FakeConnectPlatform();
    final connect = ApliarteFlutterConnect(platform: platform);
    addTearDown(connect.dispose);

    await connect.initialize(ConnectConfig(appId: 'com.apliarte.test'));

    final capabilities = await connect.capabilities();
    final permissions = await connect.checkPermissions(
      useCase: ConnectUseCase.projectionHost,
    );

    expect(capabilities.platformName, 'fake');
    expect(capabilities.supportsDiscovery, isTrue);
    expect(permissions.useCase, ConnectUseCase.projectionHost);
    expect(permissions.isGranted, isTrue);
  });

  test('facade device stream tracks platform discovery events', () async {
    final platform = FakeConnectPlatform();
    final connect = ApliarteFlutterConnect(platform: platform);
    addTearDown(connect.dispose);

    await connect.initialize(ConnectConfig(appId: 'com.apliarte.test'));
    await connect.startDiscovery();

    final device = ConnectDevice(
      id: 'peer-1',
      displayName: 'Peer 1',
      serviceType: '_apliarte-connect._tcp',
      ipAddress: '10.0.0.2',
      port: 8080,
      advertisedRole: ConnectRole.host,
    );

    final expectation = expectLater(
      connect.devices,
      emits(<ConnectDevice>[device]),
    );

    platform.emitDiscoveryEvent(
      DiscoveryEvent(type: DiscoveryEventType.deviceFound, device: device),
    );

    await expectation;
  });
}
