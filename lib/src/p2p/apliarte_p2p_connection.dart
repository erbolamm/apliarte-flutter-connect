import 'dart:convert';
import 'package:flutter/services.dart';
import 'p2p_models.dart';

/// Cliente P2P de Wi-Fi Direct para ApliArte Connect.
///
/// Permite descubrimiento, creación de grupos y conexión punto a punto
/// entre dispositivos sin depender de routers externos.
class ApliarteP2pConnection {
  static const MethodChannel _channel =
      MethodChannel('com.apliarte.flutter_connect/p2p');
  static const EventChannel _peersChannel =
      EventChannel('com.apliarte.flutter_connect/p2p_peers');
  static const EventChannel _stateChannel =
      EventChannel('com.apliarte.flutter_connect/p2p_state');
  static const EventChannel _connectionChannel =
      EventChannel('com.apliarte.flutter_connect/p2p_connection');

  /// Inicializa los controladores nativos de Wi-Fi P2P
  Future<bool> initialize() async {
    final result = await _channel.invokeMethod<bool>('initialize');
    return result ?? false;
  }

  /// Inicia el escaneo y descubrimiento de peers cercanos
  Future<bool> discover() async {
    final result = await _channel.invokeMethod<bool>('discover');
    return result ?? false;
  }

  /// Detiene el descubrimiento de peers
  Future<bool> stopDiscovery() async {
    final result = await _channel.invokeMethod<bool>('stopDiscovery');
    return result ?? false;
  }

  /// Conecta con un dispositivo específico mediante su dirección MAC/Address
  Future<bool> connect(String address) async {
    final result = await _channel.invokeMethod<bool>(
      'connect',
      <String, dynamic>{'address': address},
    );
    return result ?? false;
  }

  /// Cancela o desconecta la sesión P2P activa
  Future<bool> disconnect() async {
    final result = await _channel.invokeMethod<bool>('disconnect');
    return result ?? false;
  }

  /// Crea un grupo autónomo Wi-Fi Direct (este dispositivo actuará como Group Owner)
  Future<bool> createGroup() async {
    final result = await _channel.invokeMethod<bool>('createGroup');
    return result ?? false;
  }

  /// Elimina el grupo Wi-Fi Direct activo
  Future<bool> removeGroup() async {
    final result = await _channel.invokeMethod<bool>('removeGroup');
    return result ?? false;
  }

  /// Obtiene la información del grupo P2P actual (red, passphrase, clientes)
  Future<WifiP2PGroupInfo?> groupInfo() async {
    final raw = await _channel.invokeMethod<String>('groupInfo');
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return WifiP2PGroupInfo.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  /// Consulta la lista actual de peers descubiertos
  Future<List<DiscoveredPeers>> fetchPeers() async {
    final rawList = await _channel.invokeMethod<List<dynamic>>('fetchPeers');
    if (rawList == null) return [];
    final peers = <DiscoveredPeers>[];
    for (final item in rawList) {
      if (item is String) {
        try {
          final json = jsonDecode(item);
          if (json is Map<String, dynamic>) {
            peers.add(DiscoveredPeers.fromJson(json));
          }
        } catch (_) {}
      }
    }
    return peers;
  }

  /// Stream reactivo de peers descubiertos
  Stream<List<DiscoveredPeers>> streamPeers() {
    return _peersChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is List) {
        final peers = <DiscoveredPeers>[];
        for (final item in event) {
          if (item is String) {
            try {
              final json = jsonDecode(item);
              if (json is Map<String, dynamic>) {
                peers.add(DiscoveredPeers.fromJson(json));
              }
            } catch (_) {}
          }
        }
        return peers;
      }
      return <DiscoveredPeers>[];
    });
  }

  /// Stream reactivo del estado del adaptador Wi-Fi P2P (activado/desactivado)
  Stream<bool> streamWifiState() {
    return _stateChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event == true);
  }

  /// Stream reactivo de la conexión activa
  Stream<WifiP2PInfo?> streamConnection() {
    return _connectionChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is String && event != 'null') {
        try {
          final json = jsonDecode(event);
          if (json is Map<String, dynamic>) {
            return WifiP2PInfo.fromJson(json);
          }
        } catch (_) {}
      }
      return null;
    });
  }

  /// Comprueba si se tienen los permisos de ubicación necesarios
  Future<bool> checkLocationPermission() async {
    final result =
        await _channel.invokeMethod<bool>('checkLocationPermission');
    return result ?? false;
  }

  /// Solicita los permisos de ubicación requeridos por Wi-Fi Direct
  Future<bool> askLocationPermission() async {
    final result = await _channel.invokeMethod<bool>('askLocationPermission');
    return result ?? false;
  }

  /// Comprueba si los servicios de ubicación están habilitados
  Future<bool> checkLocationEnabled() async {
    final result = await _channel.invokeMethod<bool>('checkLocationEnabled');
    return result ?? false;
  }

  /// Comprueba si el GPS está habilitado
  Future<bool> checkGpsEnabled() async {
    final result = await _channel.invokeMethod<bool>('checkGpsEnabled');
    return result ?? false;
  }

  /// Abre la pantalla de ajustes de ubicación del sistema
  Future<bool> enableLocationServices() async {
    final result =
        await _channel.invokeMethod<bool>('enableLocationServices');
    return result ?? false;
  }

  /// Comprueba si el Wi-Fi está habilitado
  Future<bool> checkWifiEnabled() async {
    final result = await _channel.invokeMethod<bool>('checkWifiEnabled');
    return result ?? false;
  }

  /// Abre la pantalla de ajustes de Wi-Fi del sistema
  Future<bool> enableWifiServices() async {
    final result = await _channel.invokeMethod<bool>('enableWifiServices');
    return result ?? false;
  }
}
