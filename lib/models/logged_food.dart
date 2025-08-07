class LoggedFood {
  final int? id;
  final String name;
  final double amount;
  final String unit;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;

  LoggedFood({
    this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
  });

  factory LoggedFood.fromMap(Map<String, dynamic> map) {
    return LoggedFood(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
      kcal: (map['kcal'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date.toIso8601String(),
    };
  }

  LoggedFood copyWith({
    int? id,
    String? name,
    double? amount,
    String? unit,
    double? kcal,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? date,
  }) {
    return LoggedFood(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      date: date ?? this.date,
    );
  }
}
