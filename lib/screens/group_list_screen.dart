import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/screens/group/create_group_screen.dart';
import 'package:quicksplit/screens/group/expense_list_screen.dart';
import '../../providers/group_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: StatefulBuilder(
          builder: (context, setState) {
            bool isPressed = false;

            return GestureDetector(
              onLongPressStart: (_) {
                setState(() => isPressed = true);
                Future.delayed(const Duration(milliseconds: 150), () {
                  setState(() => isPressed = false);
                });
              },
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🧪 Developer Tools',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('onboardingComplete');
                              await prefs.remove('onboardingDate');
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Onboarding reset. Restart the app.',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Reset Onboarding'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: AnimatedScale(
                scale: isPressed ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: const Text('QuickSplit – My Groups'),
              ),
            );
          },
        ),
      ),
      body:
          groupProvider.groups.isEmpty
              ? const Center(child: Text('No groups yet. Add one!'))
              : ListView.builder(
                itemCount: groupProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = groupProvider.groups[index];
                  final totalAmount = group.expenses.fold<double>(
                    0,
                    (sum, e) => sum + e.amount,
                  );

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${group.members.length} member${group.members.length > 1 ? 's' : ''}',
                      ),
                      trailing: Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseListScreen(group: group),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
