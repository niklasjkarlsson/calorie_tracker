import 'package:flutter/material.dart';
import 'api.dart';
import 'barcode_scanner_page.dart';

void main() {
  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _barcodeController = TextEditingController();
  String? _calories;
  String? _productName;
  bool _loading = false;
  String? _error;

  void _search() async {
    setState(() {
      _loading = true;
      _calories = null;
      _productName = null;
      _error = null;
    });

    final product = await OpenFoodFactsAPI.fetchProduct(_barcodeController.text.trim());

    if (product != null) {
      setState(() {
        _productName = product['product_name'] ?? 'Unknown product';
        _calories = product['nutriments']?['energy-kcal_100g']?.toString() ?? 'No calorie data';
        _loading = false;
      });
    } else {
      setState(() {
        _error = 'Product not found';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Enter barcode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _search,
              child: _loading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('Search'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final scannedBarcode = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BarcodeScannerPage()),
                );

                if (scannedBarcode != null && mounted) {
                  setState(() {
                    _barcodeController.text = scannedBarcode;
                  });
                  _search();
                }
              },
              child: const Text('Scan Barcode'),
            ),
            const SizedBox(height: 20),
            if (_productName != null) 
              Text('Product: $_productName', style: const TextStyle(fontSize: 18)),
            if (_calories != null) 
              Text('Calories per 100g: $_calories kcal', style: const TextStyle(fontSize: 18)),
            if (_error != null) 
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
