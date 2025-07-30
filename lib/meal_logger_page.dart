import 'package:flutter/material.dart';
import 'widgets/add_food_dialog.dart';
import '../models/logged_food.dart';
import 'widgets/openfoodfacts_search_delegate.dart';
import '../data/database_helper.dart';

class MealLoggerPage extends StatefulWidget {
  final Map<String, dynamic>? initialProduct;

  const MealLoggerPage({super.key, this.initialProduct});

  @override
  State<MealLoggerPage> createState() => _MealLoggerPageState();
}

class _MealLoggerPageState extends State<MealLoggerPage> {
  final Map<String, List<LoggedFood>> _meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  @override
  void initState() {
    super.initState();
    _loadMealsFromDatabase();
    if (widget.initialProduct != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addFoodFromProduct('Lunch', widget.initialProduct!);
      });
    }
  }

  Future<void> _loadMealsFromDatabase() async {
    final breakfast = await DatabaseHelper.instance.fetchFoodsByMeal('Breakfast');
    final lunch = await DatabaseHelper.instance.fetchFoodsByMeal('Lunch');
    final dinner = await DatabaseHelper.instance.fetchFoodsByMeal('Dinner');

    setState(() {
      _meals['Breakfast'] = breakfast;
      _meals['Lunch'] = lunch;
      _meals['Dinner'] = dinner;
    });
  }

  void _addFood(String meal) async {
    final selected = await showSearch<Map<String, dynamic>?>(
      context: context,
      delegate: OpenFoodFactsSearchDelegate(),
    );

    if (selected != null) {
      await showAddFoodDialog(
        context: context,
        meal: meal,
        product: selected,
        onAdd: (LoggedFood food) async {
          await DatabaseHelper.instance.insertFood(meal, food);
          setState(() {
            _meals[meal]!.add(food);
          });
        },
      );
    }
  }

  void _deleteFood(String meal, LoggedFood food) async {
    await DatabaseHelper.instance.deleteFood(food.id!);
    setState(() {
      _meals[meal]!.removeWhere((f) => f.id == food.id);
    });
  }

  void _addFoodFromProduct(String meal, Map<String, dynamic> product) async {
    await showAddFoodDialog(
      context: context,
      meal: meal,
      product: product,
      onAdd: (LoggedFood food) async {
        await DatabaseHelper.instance.insertFood(meal, food);
        setState(() {
          _meals[meal]!.add(food);
        });
      },
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteFood(mealName, food),
                ),
              )),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                'Protein: ${totalProtein.toStringAsFixed(1)}g, Carbs: ${totalCarbs.toStringAsFixed(1)}g, Fat: ${totalFat.toStringAsFixed(1)}g'),
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

