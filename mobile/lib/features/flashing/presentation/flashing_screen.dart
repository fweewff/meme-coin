import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/ble/ble_manager.dart';
import '../../../core/utils/logger.dart';
import '../../../dependency_injection/service_locator.dart';

class FlashingScreen extends StatefulWidget {
  const FlashingScreen({super.key});

  static const String routeName = 'flashing';
  static const String routePath = '/flashing';

  @override
  State<FlashingScreen> createState() => _FlashingScreenState();
}

class _FlashingScreenState extends State<FlashingScreen> {
  final BleManager _bleManager = di<BleManager>();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.dev.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      // TODO(security): Enforce TLS certificate pinning and HTTP signature validation.
    ),
  ); // TODO(security): Attach authenticated interceptors + encrypted local caching.

  Peripheral? _connectedPeripheral;
  bool _isUploading = false;
  double _progress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routerState = GoRouterState.of(context);
    if (_connectedPeripheral == null && routerState.extra is Peripheral) {
      _connectedPeripheral = routerState.extra as Peripheral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connected Adapter: ${_connectedPeripheral?.name ?? '—'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: _progress == 0 ? null : _progress),
            const SizedBox(height: 8),
            Text(
              _isUploading ? 'Transferring ECU binary...' : 'Idle',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: _isUploading ? null : _readAndUploadEcu,
            child: const Text('Read & Upload ECU'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.tonal(
            onPressed: _isUploading ? null : _downloadAndFlashEcu,
            child: const Text('Download & Flash'),
          ),
        ),
      ],
    );
  }

  Future<void> _readAndUploadEcu() async {
    if (_connectedPeripheral == null) return;

    setState(() {
      _isUploading = true;
      _progress = 0;
    });

    try {
      final Uint8List ecuBinary = await _bleManager.readEcuBinary(_connectedPeripheral!);

      // TODO(security): Validate ECU binary integrity, encrypt before upload.
      // TODO(storage): Chunk uploads for large binaries using multipart requests/S3 pre-signed URLs.
      await _dio.post(
        '/api/v1/upload-original',
        data: ecuBinary,
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
            // TODO(security): Attach user auth token, e.g., OAuth2 bearer.
          },
          responseType: ResponseType.json,
          onSendProgress: (count, total) {
            if (!mounted) return;
            setState(() {
              _progress = total == 0 ? 0 : count / total;
            });
          },
        ),
      );
    } catch (error, stackTrace) {
      di<AppLogger>().error('Read/upload failed', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer failed: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _progress = 0;
      });
    }
  }

  Future<void> _downloadAndFlashEcu() async {
    if (_connectedPeripheral == null) return;

    setState(() {
      _isUploading = true;
      _progress = 0;
    });

    try {
      // TODO(processing): Poll job status endpoint until AI processing is complete.
      final Response<Uint8List> response = await _dio.get(
        '/api/v1/download-mod/{jobId}', // TODO: Replace with actual job id.
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            // TODO(security): Attach user auth token, enforce TLS certificate pinning.
          },
        ),
        onReceiveProgress: (count, total) {
          if (!mounted) return;
          setState(() {
            _progress = total == 0 ? 0 : count / total;
          });
        },
      );

      await _bleManager.writeEcuBinary(_connectedPeripheral!, response.data!);
    } catch (error, stackTrace) {
      di<AppLogger>().error('Download/flash failed', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flashing failed: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _progress = 0;
      });
    }
  }
}
