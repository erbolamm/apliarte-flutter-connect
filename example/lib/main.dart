import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static final ConnectConfig _config = ConnectConfig(
    appId: 'com.apliarte.apliarte_flutter_connect.example',
    diagnosticsEnabled: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'apliarte_flutter_connect example',
      theme: ThemeData(colorSchemeSeed: const Color(0xFFFF8F00)),
      home: Scaffold(
        appBar: AppBar(title: const Text('Apliarte Flutter Connect')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Development preview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'This example intentionally shows package metadata only. Real mDNS/Bonjour discovery and WebSocket transport are planned for a later block.',
              ),
              const SizedBox(height: 24),
              _InfoRow(label: 'Package', value: 'apliarte_flutter_connect'),
              _InfoRow(label: 'Version', value: '0.1.0-dev.1'),
              _InfoRow(
                label: 'Default service type',
                value: _config.serviceType,
              ),
              _InfoRow(label: 'Default port', value: '${_config.defaultPort}'),
              _InfoRow(
                label: 'Supported platforms in scope',
                value: 'Android / iOS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}
