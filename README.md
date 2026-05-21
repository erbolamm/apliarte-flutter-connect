# apliarte_flutter_connect

Development-preview Flutter plugin foundation for local device-to-device connectivity contracts, diagnostics, and platform stubs.

> Status: `0.1.0-dev.1` development preview. This package currently exposes public Dart contracts, diagnostics, a platform seam, and test fakes only. Real native discovery and real WebSocket transport are not implemented yet.

## Scope

### Included in this dev block

- Android and iOS Flutter plugin skeleton.
- Public Dart contracts for configuration, capabilities, discovery, permissions, sessions, frames, diagnostics, and typed errors.
- Default service type: `_apliarte-connect._tcp`.
- Internal MethodChannel protocol constants and stub lifecycle.
- Unit-test fake platform for deterministic tests.

### Not included yet

- Real mDNS/Bonjour discovery or advertising.
- Real WebSocket LAN transport.
- Wi-Fi Direct, Nearby Connections, MultipeerConnectivity, WebRTC, desktop, or internet relay.
- CalcaApp UI, BLoC, GetIt, app logging, telemetry, Firebase, or secrets.

## Install

```yaml
dependencies:
  apliarte_flutter_connect: ^0.1.0-dev.1
```

## Basic usage

```dart
import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';

final connect = ApliarteFlutterConnect.instance;

await connect.initialize(
  ConnectConfig(
    appId: 'com.example.app',
    diagnosticsEnabled: true,
  ),
);

final capabilities = await connect.capabilities();
final permissions = await connect.checkPermissions(
  useCase: ConnectUseCase.discoveryOnly,
);
```

For CalcaApp or another product-specific integration, override the service type:

```dart
final config = ConnectConfig(
  appId: 'com.apliarte.calcaapp',
  serviceType: '_calcaconnect._tcp',
);
```

## Platform notes

Future native implementations are expected to require app-level declarations.

Android apps will need local network permissions such as `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`, and SDK-specific nearby Wi-Fi/location permissions when discovery is implemented.

iOS apps will need `NSLocalNetworkUsageDescription`, `NSBonjourServices`, and local network transport policy configured for the service types they browse or advertise.

## Development validation

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
cd example && flutter analyze
flutter pub publish --dry-run
```

## Autor
Javier Mateo (ApliArte) — github.com/erbolamm

## 💬 Una nota personal del autor / A personal note from the author
ℹ️ Nota: El texto siguiente es un mensaje personal del autor, escrito en varios idiomas para que pueda leerlo gente de todo el mundo. Esto no implica que el proyecto tenga soporte funcional completo en esos idiomas.

ℹ️ Note: The text below is a personal message from the author, written in several languages so people around the world can read it. This does not imply full multilingual feature support in those languages.

<details>
<summary>🇪🇸 Español</summary>

`apliarte_flutter_connect` nace para que las apps Flutter puedan preparar conexiones locales entre dispositivos de forma clara y testeable. Esta primera versión dev comparte los contratos públicos y la base del plugin para Android/iOS. Todavía no promete discovery real ni streaming real: se publica paso a paso para construirlo bien.
</details>

<details>
<summary>🇬🇧 English</summary>

`apliarte_flutter_connect` was created to help Flutter apps prepare local device-to-device connectivity with clear, testable contracts. This first dev release shares the public API and Android/iOS plugin foundation. It does not promise real discovery or real streaming yet: it is shared step by step so it can be built properly.
</details>

<details>
<summary>🇧🇷 Português</summary>

`apliarte_flutter_connect` nasceu para ajudar apps Flutter a preparar conectividade local entre dispositivos com contratos claros e testáveis. Esta primeira versão dev traz a API pública e a base do plugin para Android/iOS. Ainda não promete discovery real nem streaming real: está sendo compartilhado passo a passo para ser construído com cuidado.
</details>

<details>
<summary>🇫🇷 Français</summary>

`apliarte_flutter_connect` a été créé pour aider les apps Flutter à préparer une connectivité locale entre appareils avec des contrats clairs et testables. Cette première version dev fournit l'API publique et la base du plugin Android/iOS. Elle ne promet pas encore de découverte réelle ni de streaming réel : le projet est partagé étape par étape pour être construit proprement.
</details>

<details>
<summary>🇩🇪 Deutsch</summary>

`apliarte_flutter_connect` wurde entwickelt, damit Flutter-Apps lokale Verbindungen zwischen Geräten mit klaren und testbaren Verträgen vorbereiten können. Diese erste Dev-Version enthält die öffentliche API und die Android/iOS-Pluginbasis. Echte Discovery und echtes Streaming werden noch nicht versprochen: Das Projekt wird Schritt für Schritt geteilt, damit es sauber entstehen kann.
</details>

<details>
<summary>🇮🇹 Italiano</summary>

`apliarte_flutter_connect` nasce per aiutare le app Flutter a preparare connessioni locali tra dispositivi con contratti chiari e testabili. Questa prima versione dev offre l'API pubblica e la base del plugin Android/iOS. Non promette ancora discovery reale né streaming reale: viene condiviso passo dopo passo per costruirlo bene.
</details>

## 💖 Apoya el proyecto
Herramienta gratuita y open source. Si te ahorra tiempo, un café ayuda a mantener el desarrollo.

| Plataforma | Enlace |
|-----------|--------|
| PayPal | paypal.me/erbolamm |
| Ko-fi | ko-fi.com/C0C11TWR1K |
| Twitch Tip | streamelements.com/apliarte/tip |

🌐 [Sitio Oficial](https://apliarte.com) · 📦 [GitHub](https://github.com/erbolamm/apliarte-flutter-connect)

## Licencia
MIT — © 2026 ApliArte

## About
Development-preview Flutter plugin foundation for local device-to-device connectivity contracts, diagnostics, and platform stubs.
