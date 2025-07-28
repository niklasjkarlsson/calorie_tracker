import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsAPI {
  static Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        return data['product'];
      }
    }
    return null;
  }
}
