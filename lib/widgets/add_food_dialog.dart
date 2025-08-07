import 'package:flutter/material.dart';
import '../models/logged_food.dart';

Future<void> showAddFoodDialog({
  required BuildContext context,
  required String meal,
  required Map<String, dynamic> product,
  required Function(LoggedFood) onAdd,
}) async {
  final name = product['product_name'] ?? 'Unnamed food';
  final nutriments = product['nutriments'] ?? {};

  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final double per100Kcal = parseDouble(nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal_100ml']);
  final double per100Protein = parseDouble(nutriments['proteins_100g'] ?? nutriments['proteins_100ml']);
  final double per100Carbs = parseDouble(nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates_100ml']);
  final double per100Fat = parseDouble(nutriments['fat_100g'] ?? nutriments['fat_100ml']);

  final nameController = TextEditingController(text: name);
  final amountController = TextEditingController(text: '100');
  final kcalController = TextEditingController(text: per100Kcal.toStringAsFixed(1));
  final proteinController = TextEditingController(text: per100Protein.toStringAsFixed(1));
  final carbsController = TextEditingController(text: per100Carbs.toStringAsFixed(1));
  final fatController = TextEditingController(text: per100Fat.toStringAsFixed(1));

  final List<String> units = ['g', 'ml', 'l', 'pcs'];
  String selectedUnit = units[0];

  DateTime selectedDate = DateTime.now();

  amountController.addListener(() {
    double amount = double.tryParse(amountController.text) ?? 0;
    double scale = amount / 100;

    if (selectedUnit == 'l') {
      scale = (amount * 1000) / 100;
    }

    kcalController.text = (per100Kcal * scale).toStringAsFixed(1);
    proteinController.text = (per100Protein * scale).toStringAsFixed(1);
    carbsController.text = (per100Carbs * scale).toStringAsFixed(1);
    fatController.text = (per100Fat * scale).toStringAsFixed(1);
  });

  String unit = nutriments.containsKey('energy-kcal_100ml') ? '100ml' : '100g';

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add food to $meal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Food name'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        decoration: InputDecoration(labelText: 'Amount ($selectedUnit)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedUnit,
                      items: units
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedUnit = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: kcalController,
                  decoration: InputDecoration(labelText: 'Calories per $unit'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: proteinController,
                  decoration: InputDecoration(labelText: 'Protein (${selectedUnit})'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: carbsController,
                  decoration: InputDecoration(labelText: 'Carbs (${selectedUnit})'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fatController,
                  decoration: InputDecoration(labelText: 'Fats (${selectedUnit})'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    Text("Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 100;

                final food = LoggedFood(
                  name: nameController.text,
                  amount: amount,
                  unit: selectedUnit,
                  kcal: double.tryParse(kcalController.text) ?? 0,
                  protein: double.tryParse(proteinController.text) ?? 0,
                  carbs: double.tryParse(carbsController.text) ?? 0,
                  fat: double.tryParse(fatController.text) ?? 0,
                  date: DateTime.now(),
                );

                onAdd(food);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}