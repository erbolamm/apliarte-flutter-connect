# Changelog

## 0.2.0

* **Wi-Fi Direct P2P Nativo (Android)**:
  * Implementación completa de `ApliarteP2pConnection` con soporte para descubrimiento de peers, creación autónoma de grupos (Group Owner), conexión y desconexión.
  * Compatibilidad nativa con Android Gradle Plugin 8.x (`namespace = "com.apliarte.apliarte_flutter_connect"`).
  * Blindaje ante caídas en el ciclo de vida de la Activity (`onDetachedFromActivity`).
  * Modelos exportados: `DiscoveredPeers`, `Client`, `WifiP2PGroupInfo`, `WifiP2PInfo`.
  * Punto de entrada dedicado: `import 'package:apliarte_flutter_connect/p2p.dart'`.

## 0.1.0-dev.1

* Initial development preview for local device-to-device connectivity contracts.
* Platform interface and method-channel skeleton.
* Capability detection and permission models.
