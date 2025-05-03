import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../providers/group_provider.dart';
import 'group_list_screen.dart';
import 'quick_split_screen.dart'; // You'll create this next

class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QuickSplit',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🧮 What would you like to do?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.group),
                label: Text(
                  'Create a Group',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final hasShownDemo = prefs.getBool('hasShownDemo') ?? false;

                  final provider = Provider.of<GroupProvider>(
                    context,
                    listen: false,
                  );
                  await provider.loadGroups();

                  if (!hasShownDemo && provider.groups.isEmpty) {
                    final sampleGroup = Group(
                      id: DateTime.now().toString(),
                      name: 'Sample Trip',
                      members: ['Alice', 'Bob', 'Charlie'],
                      createdAt: DateTime.now(),
                    );
                    provider.addGroup(sampleGroup);

                    provider.addExpense(
                      sampleGroup.id,
                      Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Dinner',
                        amount: 90.0,
                        paidBy: 'Alice',
                        splitBetween: ['Alice', 'Bob', 'Charlie'],
                        createdAt: DateTime.now(),
                        note: 'Shared meal on first night',
                      ),
                    );

                    provider.addExpense(
                      sampleGroup.id,
                      Expense(
                        id:
                            DateTime.now()
                                .add(const Duration(seconds: 1))
                                .millisecondsSinceEpoch
                                .toString(),
                        title: 'Hotel',
                        amount: 300.0,
                        paidBy: 'Bob',
                        splitBetween: ['Alice', 'Bob', 'Charlie'],
                        createdAt: DateTime.now(),
                        note: '2 nights stay',
                      ),
                    );

                    await provider.saveGroups();
                    await prefs.setBool('hasShownDemo', true);
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupListScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.restaurant),
                label: Text(
                  'Quick Split a Bill',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuickSplitScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
