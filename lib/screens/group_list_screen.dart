import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/screens/group/create_group_screen.dart';
import 'package:quicksplit/screens/group/expense_list_screen.dart';
import '../../providers/group_provider.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('QuickSplit – My Groups')),
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
