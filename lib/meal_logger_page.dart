import 'package:flutter/material.dart';
import '../api.dart';

class MealLoggerPage extends StatefulWidget {
  const MealLoggerPage({super.key});

  @override
  State<MealLoggerPage> createState() => _MealLoggerPageState();
}

class LoggedFood {
  final String name;
  final double amount;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  LoggedFood({
    required this.name,
    required this.amount,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _MealLoggerPageState extends State<MealLoggerPage> {
  final Map<String, List<LoggedFood>> _meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  void _addFood(String meal) {
    final searchController = TextEditingController();
    final amountController = TextEditingController(text: '100');
    final kcalController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    Map<String, dynamic>? selectedProduct;

    void updateFieldsFromProduct(Map<String, dynamic> product) {
      final nutriments = product['nutriments'] ?? {};
      kcalController.text = nutriments['energy-kcal_100g']?.toString() ?? '0';
      proteinController.text = nutriments['proteins_100g']?.toString() ?? '0';
      carbsController.text = nutriments['carbohydrates_100g']?.toString() ?? '0';
      fatController.text = nutriments['fat_100g']?.toString() ?? '0';
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add food to $meal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(labelText: 'Search food'),
                  onChanged: (value) async {
                    final results = await OpenFoodFactsAPI.fetchProductByName(value);
                    setState(() => searchResults = results ?? []);
                  },
                ),
                ...searchResults.map((product) {
                  final name = product['product_name'] ?? 'Unnamed product';
                  return ListTile(
                    title: Text(name),
                    onTap: () {
                      selectedProduct = product;
                      updateFieldsFromProduct(product);
                      searchController.text = name;
                      setState(() => searchResults = []);
                    },
                  );
                }).toList(),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount (g)'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    final amount = double.tryParse(amountController.text) ?? 100;
                    final scale = amount / 100.0;
                    kcalController.text = ((double.tryParse(kcalController.text) ?? 0) * scale).toStringAsFixed(1);
                    proteinController.text = ((double.tryParse(proteinController.text) ?? 0) * scale).toStringAsFixed(1);
                    carbsController.text = ((double.tryParse(carbsController.text) ?? 0) * scale).toStringAsFixed(1);
                    fatController.text = ((double.tryParse(fatController.text) ?? 0) * scale).toStringAsFixed(1);
                  },
                ),
                TextField(controller: kcalController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
                TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
                TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
                TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Fats (g)'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final double amount = double.tryParse(amountController.text) ?? 100;
                final double perGram = amount / 100;

                final food = LoggedFood(
                  name: searchController.text.trim().isNotEmpty
                      ? searchController.text.trim()
                      : 'Unnamed food',
                  amount: amount,
                  kcal: double.tryParse(kcalController.text) != null
                      ? double.parse(kcalController.text) * perGram
                      : 0,
                  protein: double.tryParse(proteinController.text) != null
                      ? double.parse(proteinController.text) * perGram
                      : 0,
                  carbs: double.tryParse(carbsController.text) != null
                      ? double.parse(carbsController.text) * perGram
                      : 0,
                  fat: double.tryParse(fatController.text) != null
                      ? double.parse(fatController.text) * perGram
                      : 0,
                );

                setState(() {
                  _meals[meal]!.add(food);
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealName, List<LoggedFood> foods) {
    double totalKcal = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (var food in foods) {
      totalKcal += food.kcal;
      totalProtein += food.protein;
      totalCarbs += food.carbs;
      totalFat += food.fat;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(mealName),
        subtitle: Text('Calories: ${totalKcal.toStringAsFixed(0)} kcal'),
        children: [
          ...foods.map((food) => ListTile(
                title: Text(food.name),
                subtitle: Text('${food.amount}g - ${food.kcal} kcal'),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Protein: ${totalProtein.toStringAsFixed(1)}g, Carbs: ${totalCarbs.toStringAsFixed(1)}g, Fat: ${totalFat.toStringAsFixed(1)}g'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Food'),
            onPressed: () => _addFood(mealName),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Logger')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _meals.entries.map((e) => _buildMealCard(e.key, e.value)).toList(),
      ),
    );
  }
}
