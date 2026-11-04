import 'package:apliarte_flutter_connect/p2p.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P2P Models', () {
    test('DiscoveredPeers serializes and deserializes correctly', () {
      final peer = DiscoveredPeers(
        deviceName: 'Pixel 8',
        deviceAddress: '02:00:00:00:00:00',
        isGroupOwner: false,
        isServiceDiscoveryCapable: true,
        primaryDeviceType: '10-0050F204-5',
        secondaryDeviceType: '',
        status: 3,
      );

      final json = peer.toJson();
      final fromJson = DiscoveredPeers.fromJson(json);

      expect(fromJson.deviceName, 'Pixel 8');
      expect(fromJson.deviceAddress, '02:00:00:00:00:00');
      expect(fromJson.isGroupOwner, false);
      expect(fromJson.isServiceDiscoveryCapable, true);
      expect(fromJson.status, 3);
    });

    test('WifiP2PGroupInfo parses json correctly', () {
      final raw = {
        'isGroupOwner': true,
        'passPhrase': 'secret_password_123',
        'groupNetworkName': 'DIRECT-xy-CalcaApp',
        'clients': [
          {
            'deviceName': 'Galaxy Tab',
            'deviceAddress': '02:00:00:00:00:01',
            'isGroupOwner': false,
            'isServiceDiscoveryCapable': true,
            'primaryDeviceType': '',
            'secondaryDeviceType': '',
            'status': 0,
          }
        ],
      };

      final group = WifiP2PGroupInfo.fromJson(raw);
      expect(group.isGroupOwner, true);
      expect(group.passPhrase, 'secret_password_123');
      expect(group.groupNetworkName, 'DIRECT-xy-CalcaApp');
      expect(group.clients.length, 1);
      expect(group.clients.first.deviceName, 'Galaxy Tab');
    });

    test('WifiP2PInfo parses json correctly', () {
      final raw = {
        'isConnected': true,
        'isGroupOwner': false,
        'groupOwnerAddress': '192.168.49.1',
        'groupFormed': true,
        'clients': <Map<String, dynamic>>[],
      };

      final info = WifiP2PInfo.fromJson(raw);
      expect(info.isConnected, true);
      expect(info.isGroupOwner, false);
      expect(info.groupOwnerAddress, '192.168.49.1');
      expect(info.groupFormed, true);
    });
  });

  group('ApliarteP2pConnection MethodChannel mock tests', () {
    const channel = MethodChannel('com.apliarte.flutter_connect/p2p');
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
          case 'discover':
          case 'stopDiscovery':
          case 'connect':
          case 'disconnect':
          case 'createGroup':
          case 'removeGroup':
            return true;
          case 'groupInfo':
            return '{"isGroupOwner": true, "passPhrase": "test", "groupNetworkName": "DIRECT-TEST", "clients": []}';
          case 'fetchPeers':
            return [
              '{"deviceName": "Device A", "deviceAddress": "02:00:00:00:00:01", "isGroupOwner": false, "isServiceDiscoveryCapable": true, "primaryDeviceType": "", "secondaryDeviceType": "", "status": 3}'
            ];
          case 'checkLocationPermission':
          case 'askLocationPermission':
          case 'checkLocationEnabled':
          case 'checkWifiEnabled':
            return true;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('lifecycle calls invoke correct channel methods', () async {
      final p2p = ApliarteP2pConnection();

      expect(await p2p.initialize(), true);
      expect(await p2p.discover(), true);
      expect(await p2p.stopDiscovery(), true);
      expect(await p2p.connect('02:00:00:00:00:01'), true);
      expect(await p2p.createGroup(), true);
      expect(await p2p.removeGroup(), true);
      expect(await p2p.disconnect(), true);

      final group = await p2p.groupInfo();
      expect(group?.isGroupOwner, true);
      expect(group?.groupNetworkName, 'DIRECT-TEST');

      final peers = await p2p.fetchPeers();
      expect(peers.length, 1);
      expect(peers.first.deviceName, 'Device A');

      expect(log.map((c) => c.method), [
        'initialize',
        'discover',
        'stopDiscovery',
        'connect',
        'createGroup',
        'removeGroup',
        'disconnect',
        'groupInfo',
        'fetchPeers',
      ]);
    });
  });
}
