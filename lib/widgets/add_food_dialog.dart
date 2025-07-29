import 'package:flutter/material.dart';

Future<void> showAddFoodDialog(
  BuildContext context,
  String meal,
  Function(Map<String, dynamic>) onAdd, 
  {Map<String, String>? prefill}
  ) 
{
  final nameController = TextEditingController(text: prefill?['name'] ?? '');
  final amountController = TextEditingController(text: '100');

  final double per100Kcal = double.tryParse(prefill?['kcal'] ?? '') ?? 0;
  final double per100Protein = double.tryParse(prefill?['protein'] ?? '') ?? 0;
  final double per100Carbs = double.tryParse(prefill?['carbs'] ?? '') ?? 0;
  final double per100Fat = double.tryParse(prefill?['fat'] ?? '') ?? 0;

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
              final foodEntry = {
                'name': nameController.text.trim(),
                'amount': double.tryParse(amountController.text) ?? 0,
                'calories': double.tryParse(kcalController.text) ?? 0,
                'protein': double.tryParse(proteinController.text) ?? 0,
                'carbs': double.tryParse(carbsController.text) ?? 0,
                'fat': double.tryParse(fatController.text) ?? 0,
              };
              onAdd(foodEntry);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}