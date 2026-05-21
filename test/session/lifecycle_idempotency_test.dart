import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_connect_platform.dart';

void main() {
  test('initialize is idempotent for same platform setup', () async {
    final platform = FakeConnectPlatform();
    final connect = ApliarteFlutterConnect(platform: platform);
    addTearDown(connect.dispose);

    final config = ConnectConfig(appId: 'com.apliarte.test');
    await connect.initialize(config);
    await connect.initialize(config.copyWith(diagnosticsEnabled: true));

    expect(platform.initializeCalls, 1);
    expect(connect.isInitialized, isTrue);
  });

  test('initialize rejects different platform configuration', () async {
    final platform = FakeConnectPlatform();
    final connect = ApliarteFlutterConnect(platform: platform);
    addTearDown(connect.dispose);

    await connect.initialize(ConnectConfig(appId: 'com.apliarte.test'));

    expect(
      () => connect.initialize(
        ConnectConfig(
          appId: 'com.apliarte.test',
          serviceType: '_other-connect._tcp',
        ),
      ),
      throwsA(isA<ConnectException>()),
    );
    expect(platform.initializeCalls, 1);
  });

  test('start and stop discovery are idempotent', () async {
    final platform = FakeConnectPlatform();
    final connect = ApliarteFlutterConnect(platform: platform);
    addTearDown(connect.dispose);

    await connect.initialize(ConnectConfig(appId: 'com.apliarte.test'));
    await connect.startDiscovery();
    await connect.startDiscovery();
    await connect.stopDiscovery();
    await connect.stopDiscovery();

    expect(platform.startDiscoveryCalls, 1);
    expect(platform.stopDiscoveryCalls, 1);
    expect(connect.lifecycle, ConnectLifecycle.idle);
  });

  test('dispose is idempotent', () async {
    final platform = FakeConnectPlatform();
    final connect = ApliarteFlutterConnect(platform: platform);

    await connect.initialize(ConnectConfig(appId: 'com.apliarte.test'));
    await connect.dispose();
    await connect.dispose();

    expect(platform.disposeCalls, 1);
    expect(connect.lifecycle, ConnectLifecycle.closed);
  });
}
