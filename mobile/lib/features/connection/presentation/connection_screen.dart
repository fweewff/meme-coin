import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

import '../../../core/services/ble/ble_manager.dart';
import '../../../dependency_injection/service_locator.dart';
import '../../flashing/presentation/flashing_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  static const String routeName = 'connection';
  static const String routePath = '/connection';

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final BleManager _bleManager = di<BleManager>();

  @override
  void initState() {
    super.initState();
    _initializeBle();
  }

  Future<void> _initializeBle() async {
    await _bleManager.initialize();
    // TODO: Handle BLE state updates (powered off, unauthorized).
  }

  @override
  void dispose() {
    // TODO: Dispose per-peripheral subscriptions gracefully.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Vehicle'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ensure your OBD-II BLE adapter is powered on. Scanning for nearby devices...',
            ),
          ),
          Expanded(
            child: StreamBuilder<ScanResult>(
              stream: _bleManager.scanForObdDevices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data!;

                return ListTile(
                  title: Text(results.peripheral.name ?? 'Unknown device'),
                  subtitle: Text(results.peripheral.identifier),
                  trailing: const Icon(Icons.bluetooth_searching),
                  onTap: () async {
                    // TODO(security): Require authenticated user session before allowing connections.
                    await _bleManager.connect(results.peripheral);

                    if (!context.mounted) return;
                    context.go(FlashingScreen.routePath, extra: results.peripheral);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
