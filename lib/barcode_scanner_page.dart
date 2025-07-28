import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          if (!_isScanning) return;

          final String? code = barcodeCapture.barcodes.first.rawValue;
          if (code != null && code.isNotEmpty) {
            print('Barcode found: $code');
            _isScanning = false;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}