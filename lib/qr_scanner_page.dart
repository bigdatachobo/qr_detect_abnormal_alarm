import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'qr_code_processing.dart';
import 'qr_code_dialogs.dart';

class QRScannerPage extends StatefulWidget {
  final bool isInbound;
  final bool isMoving;

  QRScannerPage({
    required this.isInbound,
    required this.isMoving,
  });

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  QRViewController? _controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final RegExp pattern = RegExp(r'^[A-Z]\d{5}_\d{10}$');

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && _controller != null) {
        if (pattern.hasMatch(scanData.code!)) {
          _controller?.pauseCamera();
          await processQRCode(context, scanData.code!, widget.isInbound);
          _controller?.resumeCamera();
        } else {
          _controller?.pauseCamera();
          await showInvalidCodeFormatDialog(context);
          _controller?.resumeCamera();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 5.0,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller?.toggleFlash();
        },
        child: const Icon(Icons.flash_on),
      ),
    );
  }
}
