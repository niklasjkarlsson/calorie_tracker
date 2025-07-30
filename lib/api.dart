import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsAPI {
  static Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['product'];
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchProductByName(String name) async {
    try {
      final encodedName = Uri.encodeQueryComponent(name);
      final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$encodedName&search_simple=1&action=process&json=1&page_size=20',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List<dynamic>?;

        if (products != null) {
          return products.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      // Optionally log the error
      print('Error fetching product by name: $e');
    }

    return [];
}

}

