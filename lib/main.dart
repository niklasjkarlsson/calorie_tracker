import 'package:flutter/material.dart';
import 'api.dart';
import 'barcode_scanner_page.dart';
import 'dart:async';
import 'meal_logger_page.dart';
import 'widgets/add_food_dialog.dart';
import 'goals_page.dart';

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
  Timer? _debounce;
  String? _calories;
  String? _productName;
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>>? _searchResults;
  Map<String, dynamic>? _selectedProduct;

  void _handleInputChange(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _search();
    });
  }

  void _search() async {
    setState(() {
      _loading = true;
      _calories = null;
      _productName = null;
      _error = null;
      _searchResults = null;
      _selectedProduct = null;
    });

    final input = _barcodeController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _error = 'Please enter a barcode or search term';
        _loading = false;
      });
      return;
    }

    if (RegExp(r'^\d+$').hasMatch(input)) {
      // Input is digits => treat as barcode
      final product = await OpenFoodFactsAPI.fetchProduct(input);
      if (product != null) {
        setState(() {
          _productName = product['product_name'] ?? 'Unknown product';
          _calories = product['nutriments']?['energy-kcal_100g']?.toString() ?? 'No calorie data';
          _selectedProduct = product;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Product not found';
          _loading = false;
        });
      }
    } else {
      // Input is not digits => treat as name
      final results = await OpenFoodFactsAPI.fetchProductByName(input);
      if (results != null && results.isNotEmpty) {
        setState(() {
          _searchResults = results;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No products found';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GoalsPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter barcode or product name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _handleInputChange,
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final scannedBarcode = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarcodeScannerPage()),
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

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MealLoggerPage()),
                );
              },
              child: const Text('Log My Meals'),
            ),

            const SizedBox(height: 20),
            if (_productName != null) ...[
              Text('Product: $_productName',
                  style: const TextStyle(fontSize: 18)),
              if (_selectedProduct != null) ...[
                Text('Brand : ${_selectedProduct!['brands'] ?? 'Unknown'}'),
                Text('Proteins: ${_selectedProduct!['nutriments']?['proteins_100g']?.toString() ?? 'N/A'} g'),
                Text('Carbohydrates: ${_selectedProduct!['nutriments']?['carbohydrates_100g']?.toString() ?? 'N/A'} g'),
                Text('Fats: ${_selectedProduct!['nutriments']?['fat_100g']?.toString() ?? 'N/A'} g'),

                ElevatedButton(
                  onPressed: () {
                    final product = _selectedProduct!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealLoggerPage(initialProduct: product),
                      ),
                    );
                  },
                  child: const Text('Add to Meal Log')
                ),
              ],
            ],  
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            if (_searchResults != null) ...[
              const SizedBox(height: 20),
              const Text('Select a product:',
                  style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults!.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults![index];
                    final name = product['product_name'] ?? 'Unnamed product';
                    final brand = product['brands'] ?? 'Unknown brand';
                    final barcode = product['code'] ?? '';
                    final nutriments = product['nutriments'] ?? {};
                    final proteins = nutriments['proteins_100g']?.toString() ?? 'N/A';
                    final carbs = nutriments['carbohydrates_100g']?.toString() ?? 'N/A';
                    final fats = nutriments['fat_100g']?.toString() ?? 'N/A';

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Brand: $brand\nProtein: $proteins g | Carbs: $carbs g | Fats: $fats g'),
                      isThreeLine: true,
                      onTap: () async {
                        final detailedProduct =
                            await OpenFoodFactsAPI.fetchProduct(barcode);
                        if (detailedProduct != null) {
                          setState(() {
                            _productName =
                                detailedProduct['product_name'] ?? 'Unknown product';
                            _calories = detailedProduct['nutriments']
                                    ?['energy-kcal_100g']
                                    ?.toString() ??
                                'No calorie data';
                            _selectedProduct = detailedProduct;
                            _searchResults = null;
                            _barcodeController.text = barcode;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
