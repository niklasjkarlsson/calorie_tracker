Map<String, dynamic> parseServingSize(String? servingSize) {
  if (servingSize == null || servingSize.isEmpty) {
    return {'amount': 100.0, 'unit': 'g'}; // default fallback
  }
  
  final regex = RegExp(r'([\d\.]+)\s*([a-zA-Z]+)');
  final match = regex.firstMatch(servingSize);
  
  if (match != null) {
    final amount = double.tryParse(match.group(1)!) ?? 100.0;
    final unit = match.group(2)!.toLowerCase();
    return {'amount': amount, 'unit': unit};
  } else {
    // fallback
    return {'amount': 100.0, 'unit': 'g'};
  }
}
