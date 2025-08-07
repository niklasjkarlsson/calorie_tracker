import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();
  double _calorieGoal = 2000;
  double _proteinGoal = 100;
  double _carbGoal = 250;
  double _fatGoal = 70;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calorieGoal = prefs.getDouble('calorieGoal') ?? 2000;
      _proteinGoal = prefs.getDouble('proteinGoal') ?? 100;
      _carbGoal = prefs.getDouble('carbGoal') ?? 250;
      _fatGoal = prefs.getDouble('fatGoal') ?? 70;
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calorieGoal', _calorieGoal);
    await prefs.setDouble('proteinGoal', _proteinGoal);
    await prefs.setDouble('carbGoal', _carbGoal);
    await prefs.setDouble('fatGoal', _fatGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _calorieGoal.toString(),
                decoration: const InputDecoration(labelText: 'Calorie Goal (kcal)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _calorieGoal = double.tryParse(v ?? '') ?? _calorieGoal,
              ),
              TextFormField(
                initialValue: _proteinGoal.toString(),
                decoration: const InputDecoration(labelText: 'Protein Goal (g)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _proteinGoal = double.tryParse(v ?? '') ?? _proteinGoal,
              ),
              TextFormField(
                initialValue: _carbGoal.toString(),
                decoration: const InputDecoration(labelText: 'Carb Goal (g)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _carbGoal = double.tryParse(v ?? '') ?? _carbGoal,
              ),
              TextFormField(
                initialValue: _fatGoal.toString(),
                decoration: const InputDecoration(labelText: 'Fat Goal (g)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _fatGoal = double.tryParse(v ?? '') ?? _fatGoal,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.save();
                  await _saveGoals();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goals saved!')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}