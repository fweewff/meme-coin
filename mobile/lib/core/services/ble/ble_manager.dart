import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';

import '../../config/app_config.dart';
import '../../utils/logger.dart';

class BleManager {
  BleManager(this._logger) : _bleManager = FlutterBleLib();

  final FlutterBleLib _bleManager;
  final AppLogger _logger;

  Future<void> initialize() async {
    _logger.info('Initializing BLE manager');
    await _bleManager.createClient(); // TODO(security): Validate platform-specific BLE permissions.
  }

  Stream<ScanResult> scanForObdDevices({
    Duration timeout = const Duration(seconds: 10),
  }) {
    _logger.info('Scanning for OBD-II BLE devices');

    // TODO(security): Filter by whitelisted MAC addresses or enforce secure pairing when possible.
    return _bleManager.scanForPeripherals(
      withServices: [AppConfig.dev.bleServiceUuid],
      scanMode: ScanMode.lowLatency,
      scanDuration: timeout,
    );
  }

  Future<Peripheral> connect(Peripheral peripheral) async {
    _logger.info('Connecting to device: ${peripheral.name}');

    await peripheral.connect();

    // TODO(security): Implement secure BLE pairing/bonding and handle encryption keys.
    return peripheral;
  }

  Future<void> disconnect(Peripheral peripheral) async {
    _logger.info('Disconnecting from device: ${peripheral.name}');
    await peripheral.disconnectOrCancelConnection();
  }

  Future<Uint8List> readEcuBinary(Peripheral peripheral) async {
    _logger.info('Reading ECU binary from BLE characteristic');

    final serviceUuid = AppConfig.dev.bleServiceUuid;
    final characteristicUuid = AppConfig.dev.bleCharacteristicUuid;

    // TODO(protocol): Implement OBD-II framing, chunking, and checksum validation.
    final characteristic = await peripheral
        .readCharacteristic(serviceUuid, characteristicUuid);

    return characteristic.value ?? Uint8List(0);
  }

  Future<void> writeEcuBinary(
    Peripheral peripheral,
    Uint8List payload,
  ) async {
    _logger.info('Writing modified ECU binary to BLE characteristic');

    final serviceUuid = AppConfig.dev.bleServiceUuid;
    final characteristicUuid = AppConfig.dev.bleCharacteristicUuid;

    // TODO(protocol): Chunk payload according to MTU size, add retries and checksum verification.
    await peripheral.writeCharacteristic(
      serviceUuid,
      characteristicUuid,
      payload,
      false,
    );
  }

  Future<void> dispose() async {
    _logger.info('Disposing BLE manager');
    await _bleManager.destroyClient();
  }
}
