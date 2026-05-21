import 'package:apliarte_flutter_connect/src/method_channel/channel_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('method-channel protocol names are versionable and stable', () {
    expect(ConnectChannelNames.methods, 'com.apliarte.flutter_connect/methods');
    expect(
      ConnectChannelNames.discoveryEvents,
      'com.apliarte.flutter_connect/discovery_events',
    );
    expect(ConnectMethodNames.initialize, 'initialize');
    expect(ConnectMethodNames.getCapabilities, 'getCapabilities');
    expect(ConnectMethodNames.startDiscovery, 'startDiscovery');
    expect(ConnectMethodNames.dispose, 'dispose');
  });
}
