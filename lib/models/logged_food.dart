class LoggedFood {
  final int? id;
  final String name;
  final double amount;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  LoggedFood({
    this.id,
    required this.name,
    required this.amount,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory LoggedFood.fromMap(Map<String, dynamic> map) {
    return LoggedFood(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      kcal: map['kcal'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
