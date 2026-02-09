import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrcodePage extends StatefulWidget {
  const ScanQrcodePage({super.key});

  @override
  State<ScanQrcodePage> createState() => _ScanQrcodePageState();
}

class _ScanQrcodePageState extends State<ScanQrcodePage> {
  String _scanResult = 'Unknown';
  bool _isScanning = false;
  final MobileScannerController _controller = MobileScannerController();

  Future<void> _startScan({required bool qrOnly}) async {
    setState(() {
      _isScanning = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                tooltip: 'Turn on/off flash',
                icon: const Icon(Icons.flash_on),
                onPressed: _controller.toggleTorch,
              ),
              IconButton(
                tooltip: 'Switch camera',
                icon: const Icon(Icons.cameraswitch),
                onPressed: _controller.switchCamera,
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double overlayWidth = constraints.maxWidth * 0.78;
              final double overlayHeight = constraints.maxHeight * 0.42;
              final Rect window = Rect.fromCenter(
                center: Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 2,
                ),
                width: overlayWidth,
                height: overlayHeight,
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    fit: BoxFit.cover,
                    scanWindow: window,
                    onDetect: (capture) {
                      final String? code =
                          capture.barcodes.firstOrNull?.rawValue;
                      if (code == null) return;

                      setState(() {
                        _scanResult = code;
                      });

                      Navigator.pop(context);
                    },
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _ScannerOverlayPainter(window: window),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // ✅ จะถูกเรียกเสมอ ไม่ว่าจะ scan สำเร็จ หรือกดย้อนกลับ
    if (!mounted) return;
    setState(() {
      _isScanning = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isScanning ? null : () => _startScan(qrOnly: true),
              child: const Text('Start QR scan'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isScanning ? null : () => _startScan(qrOnly: false),
              child: const Text('Start barcode scan'),
            ),
            const SizedBox(height: 20),
            Text('Scan result', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(_scanResult, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.window});

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final Path background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectXY(window, 14, 14))
      ..fillType = PathFillType.evenOdd;

    final Paint dimPaint = Paint()..color = Colors.black.withOpacity(0.45);
    canvas.drawPath(background, dimPaint);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectXY(window, 14, 14), borderPaint);

    final Paint linePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(window.left + 8, window.center.dy),
      Offset(window.right - 8, window.center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.window != window;
  }
}
