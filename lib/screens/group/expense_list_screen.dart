import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/models/group.dart';
import '../../providers/group_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final Group group;

  const ExpenseListScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentGroup = groupProvider.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentGroup.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(groupId: currentGroup.id),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
          ),
        ],
      ),
      body:
          currentGroup.expenses.isEmpty
              ? const Center(child: Text('No expenses yet. Add one!'))
              : ListView.builder(
                itemCount: currentGroup.expenses.length,
                itemBuilder: (context, index) {
                  final expense = currentGroup.expenses[index];
                  return ListTile(
                    title: Text(expense.title),
                    subtitle: Text(
                      'Paid by: ${expense.paidBy}\nSplit between: ${expense.splitBetween.join(', ')}',
                    ),
                    trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                  );
                },
              ),
    );
  }
}
