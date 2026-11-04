import 'dart:convert';

/// Modelo de peer descubierto por Wi-Fi Direct
class DiscoveredPeers {
  const DiscoveredPeers({
    required this.deviceName,
    required this.deviceAddress,
    required this.isGroupOwner,
    required this.isServiceDiscoveryCapable,
    required this.primaryDeviceType,
    required this.secondaryDeviceType,
    required this.status,
  });

  factory DiscoveredPeers.fromJson(Map<String, dynamic> json) {
    return DiscoveredPeers(
      deviceName: json['deviceName']?.toString() ?? '',
      deviceAddress: json['deviceAddress']?.toString() ?? '',
      isGroupOwner: json['isGroupOwner'] == true,
      isServiceDiscoveryCapable: json['isServiceDiscoveryCapable'] == true,
      primaryDeviceType: json['primaryDeviceType']?.toString() ?? '',
      secondaryDeviceType: json['secondaryDeviceType']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : 0,
    );
  }

  final String deviceName;
  final String deviceAddress;
  final bool isGroupOwner;
  final bool isServiceDiscoveryCapable;
  final String primaryDeviceType;
  final String secondaryDeviceType;
  final int status;

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'deviceAddress': deviceAddress,
        'isGroupOwner': isGroupOwner,
        'isServiceDiscoveryCapable': isServiceDiscoveryCapable,
        'primaryDeviceType': primaryDeviceType,
        'secondaryDeviceType': secondaryDeviceType,
        'status': status,
      };

  @override
  String toString() =>
      'DiscoveredPeers(name: $deviceName, address: $deviceAddress, isGO: $isGroupOwner)';
}

/// Cliente conectado a un grupo Wi-Fi Direct
class Client {
  const Client({
    required this.deviceName,
    required this.deviceAddress,
    required this.isGroupOwner,
    required this.isServiceDiscoveryCapable,
    required this.primaryDeviceType,
    required this.secondaryDeviceType,
    required this.status,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      deviceName: json['deviceName']?.toString() ?? '',
      deviceAddress: json['deviceAddress']?.toString() ?? '',
      isGroupOwner: json['isGroupOwner'] == true,
      isServiceDiscoveryCapable: json['isServiceDiscoveryCapable'] == true,
      primaryDeviceType: json['primaryDeviceType']?.toString() ?? '',
      secondaryDeviceType: json['secondaryDeviceType']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : 0,
    );
  }

  final String deviceName;
  final String deviceAddress;
  final bool isGroupOwner;
  final bool isServiceDiscoveryCapable;
  final String primaryDeviceType;
  final String secondaryDeviceType;
  final int status;

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'deviceAddress': deviceAddress,
        'isGroupOwner': isGroupOwner,
        'isServiceDiscoveryCapable': isServiceDiscoveryCapable,
        'primaryDeviceType': primaryDeviceType,
        'secondaryDeviceType': secondaryDeviceType,
        'status': status,
      };
}

/// Información del grupo Wi-Fi Direct
class WifiP2PGroupInfo {
  const WifiP2PGroupInfo({
    required this.isGroupOwner,
    required this.passPhrase,
    required this.groupNetworkName,
    required this.clients,
  });

  factory WifiP2PGroupInfo.fromJson(Map<String, dynamic> json) {
    final rawClients = json['clients'];
    final clientsList = <Client>[];
    if (rawClients is List) {
      for (final c in rawClients) {
        if (c is Map<String, dynamic>) {
          clientsList.add(Client.fromJson(c));
        } else if (c is String) {
          try {
            final parsed = jsonDecode(c);
            if (parsed is Map<String, dynamic>) {
              clientsList.add(Client.fromJson(parsed));
            }
          } catch (_) {}
        }
      }
    }

    return WifiP2PGroupInfo(
      isGroupOwner: json['isGroupOwner'] == true,
      passPhrase: json['passPhrase']?.toString() ?? '',
      groupNetworkName: json['groupNetworkName']?.toString() ?? '',
      clients: clientsList,
    );
  }

  final bool isGroupOwner;
  final String passPhrase;
  final String groupNetworkName;
  final List<Client> clients;
}

/// Información de la conexión Wi-Fi Direct activa
class WifiP2PInfo {
  const WifiP2PInfo({
    required this.isConnected,
    required this.isGroupOwner,
    this.groupOwnerAddress,
    required this.groupFormed,
    this.clients = const [],
  });

  factory WifiP2PInfo.fromJson(Map<String, dynamic> json) {
    final rawClients = json['clients'];
    final clientsList = <Client>[];
    if (rawClients is List) {
      for (final c in rawClients) {
        if (c is Map<String, dynamic>) {
          clientsList.add(Client.fromJson(c));
        } else if (c is String) {
          try {
            final parsed = jsonDecode(c);
            if (parsed is Map<String, dynamic>) {
              clientsList.add(Client.fromJson(parsed));
            }
          } catch (_) {}
        }
      }
    }

    return WifiP2PInfo(
      isConnected: json['isConnected'] == true,
      isGroupOwner: json['isGroupOwner'] == true,
      groupOwnerAddress: json['groupOwnerAddress']?.toString(),
      groupFormed: json['groupFormed'] == true,
      clients: clientsList,
    );
  }

  final bool isConnected;
  final bool isGroupOwner;
  final String? groupOwnerAddress;
  final bool groupFormed;
  final List<Client> clients;
}
