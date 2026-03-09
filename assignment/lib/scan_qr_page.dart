import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    cameraResolution: const Size(1920, 1080),
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 120,
    returnImage: false,
  );
  final TextEditingController _manualCtl = TextEditingController();
  bool _handled = false;
  bool _manualDialogOpen = false;
  bool _isLeavingPage = false;

  void _closeScanner([String? value]) {
    if (_isLeavingPage || !mounted) return;
    _isLeavingPage = true;
    Future.microtask(() {
      if (!mounted) return;
      Navigator.of(context).pop(value);
    });
  }

  int _formatScore(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.code128:
      case BarcodeFormat.code39:
      case BarcodeFormat.code93:
      case BarcodeFormat.codabar:
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
      case BarcodeFormat.itf:
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
        return 4;
      case BarcodeFormat.qrCode:
      case BarcodeFormat.dataMatrix:
      case BarcodeFormat.pdf417:
      case BarcodeFormat.aztec:
        return 3;
      case BarcodeFormat.all:
      case BarcodeFormat.unknown:
        return 1;
    }
  }

  String _decodeRawBytes(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return '';

    try {
      return utf8.decode(bytes, allowMalformed: true).trim();
    } catch (_) {
      try {
        return latin1.decode(bytes).trim();
      } catch (_) {
        return '';
      }
    }
  }

  int _textScore(String value) {
    var score = 0;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return -9999;

    if (RegExp(r'^[A-Za-z0-9._/-]+$').hasMatch(trimmed)) {
      score += 4;
    }
    if (RegExp(r'[A-Za-z]').hasMatch(trimmed) &&
        RegExp(r'[0-9]').hasMatch(trimmed)) {
      score += 2;
    }
    if (trimmed.length >= 4 && trimmed.length <= 64) {
      score += 2;
    }

    final lower = trimmed.toLowerCase();
    if (lower.contains('assetcode') ||
        lower.contains('barcode') ||
        lower.contains('code=')) {
      score += 2;
    }
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      score -= 1;
    }

    return score;
  }

  String _pickBestRawValue(List<Barcode> barcodes) {
    final seen = <String>{};
    var bestValue = '';
    var bestScore = -9999;

    for (final barcode in barcodes) {
      final formatBonus = _formatScore(barcode.format);
      final bytesValue = _decodeRawBytes(barcode.rawBytes);
      final candidates = <String?>[
        barcode.rawValue,
        barcode.displayValue,
        bytesValue.isEmpty ? null : bytesValue,
      ];

      for (final candidate in candidates) {
        final value = candidate?.trim() ?? '';
        if (value.isEmpty) continue;
        if (!seen.add(value)) continue;

        final score = _textScore(value) + formatBonus;
        if (score > bestScore) {
          bestScore = score;
          bestValue = value;
        }
      }
    }

    return bestValue;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || _manualDialogOpen || _isLeavingPage) return;
    if (capture.barcodes.isEmpty) return;

    final value = _pickBestRawValue(capture.barcodes);
    if (value.isEmpty) return;

    _handled = true;
    _closeScanner(value);
  }

  Future<void> _openManualInput() async {
    if (_manualDialogOpen || _isLeavingPage) return;
    _manualDialogOpen = true;
    await _controller.pause();
    if (!mounted) {
      _manualDialogOpen = false;
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('กรอกรหัสบาร์โค้ดด้วยตนเอง'),
        content: TextField(
          controller: _manualCtl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'บาร์โค้ด / รหัสครุภัณฑ์',
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ใช้รหัสนี้'),
          ),
        ],
      ),
    );

    _manualDialogOpen = false;
    if (!_isLeavingPage) {
      await _controller.start();
    }

    if (!mounted || _isLeavingPage || ok != true) return;
    final value = _manualCtl.text.trim();
    if (value.isEmpty) return;

    _handled = true;
    _closeScanner(value);
  }

  @override
  void dispose() {
    _manualCtl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนบาร์โค้ด / QR'),
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }

              IconData icon;
              switch (state.torchState) {
                case TorchState.on:
                  icon = Icons.flash_on;
                case TorchState.off:
                  icon = Icons.flash_off;
                case TorchState.auto:
                  icon = Icons.flash_auto;
                case TorchState.unavailable:
                  icon = Icons.no_flash;
              }

              return IconButton(
                tooltip: 'เปิด/ปิดแฟลช',
                icon: Icon(icon),
                onPressed: state.torchState == TorchState.unavailable
                    ? null
                    : () => _controller.toggleTorch(),
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }
              final available = state.availableCameras;
              if (available != null && available < 2) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'สลับกล้อง',
                icon: const Icon(Icons.flip_camera_android_outlined),
                onPressed: () => _controller.switchCamera(),
              );
            },
          ),
          IconButton(
            tooltip: 'กรอกเอง',
            icon: const Icon(Icons.keyboard_alt_outlined),
            onPressed: _manualDialogOpen ? null : _openManualInput,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = Rect.fromCenter(
            center: constraints.biggest.center(Offset.zero),
            width: constraints.maxWidth * 0.8,
            height: constraints.maxHeight * 0.24,
          );

          return Stack(
            children: [
              MobileScanner(
                controller: _controller,
                scanWindow: scanWindow,
                onDetect: _onDetect,
              ),
              Center(
                child: Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: Text(
                  'จัดบาร์โค้ด/QR ให้อยู่ในกรอบ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB22C),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => _closeScanner(),
                    child: const Text('ย้อนกลับ'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
