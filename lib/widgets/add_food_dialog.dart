import 'package:flutter/material.dart';
import '../models/logged_food.dart';

Future<void> showAddFoodDialog({
  required BuildContext context,
  required String meal,
  required Map<String, dynamic> product,
  required Function(LoggedFood) onAdd, 

}) async  {
  
  final name = product['product_name'] ?? 'Unnamed food';
  final nutriments = product['nutriments'] ?? {};

  final double per100Kcal = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
  final double per100Protein = (nutriments['proteins_100g'] ?? 0).toDouble();
  final double per100Carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
  final double per100Fat = (nutriments['fat_100g'] ?? 0).toDouble();

  final nameController = TextEditingController(text: name);
  final amountController = TextEditingController(text: '100');
  final kcalController = TextEditingController(text: per100Kcal.toStringAsFixed(1));
  final proteinController = TextEditingController(text: per100Protein.toStringAsFixed(1));
  final carbsController = TextEditingController(text: per100Carbs.toStringAsFixed(1));
  final fatController = TextEditingController(text: per100Fat.toStringAsFixed(1));

  amountController.addListener(() {
    final double amount = double.tryParse(amountController.text) ?? 0;
    final scale = amount / 100;

    kcalController.text = (per100Kcal * scale).toStringAsFixed(1);
    proteinController.text = (per100Protein * scale).toStringAsFixed(1);
    carbsController.text = (per100Carbs * scale).toStringAsFixed(1);
    fatController.text = (per100Fat * scale).toStringAsFixed(1);
  });

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add food to $meal'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: kcalController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(labelText: 'Fats (g)'),
                keyboardType: TextInputType.number,
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
              final multiplier = amount / 100;

              final food = LoggedFood(
                name: product['product_name'] ?? 'Unnamed food',
                amount: amount,
                kcal: (product['nutriments']?['energy-kcal_100g'] ?? 0) * multiplier,
                protein: (product['nutriments']?['proteins_100g'] ?? 0) * multiplier,
                carbs: (product['nutriments']?['carbohydrates_100g'] ?? 0) * multiplier,
                fat: (product['nutriments']?['fat_100g'] ?? 0) * multiplier,
              );

              onAdd(food);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}