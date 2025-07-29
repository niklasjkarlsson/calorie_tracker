import 'package:flutter/material.dart';


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
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final kcalController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add food to $meal'),
        content: SingleChildScrollView(
          child: Column(
            children:[
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Food name')),
              TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount (g)'), keyboardType: TextInputType.number),
              TextField(controller: kcalController, decoration: InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
              TextField(controller: proteinController, decoration: InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
              TextField(controller: carbsController, decoration: InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
              TextField(controller: fatController, decoration: InputDecoration(labelText: 'Fats (g)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final food = LoggedFood(
                name: nameController.text,
                amount: double.tryParse(amountController.text) ?? 0,
                kcal: double.tryParse(kcalController.text) ?? 0,
                protein: double.tryParse(proteinController.text) ?? 0,
                carbs: double.tryParse(carbsController.text) ?? 0,
                fat: double.tryParse(fatController.text) ?? 0,
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
          ) 
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