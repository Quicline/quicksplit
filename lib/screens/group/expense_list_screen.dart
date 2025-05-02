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
  bool _showAllSummary = false;

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentGroup = groupProvider.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );
    final summary = Provider.of<GroupProvider>(
      context,
    ).calculateMemberSummary(widget.group.id);

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
      body: Column(
        children: [
          Expanded(
            child:
                currentGroup.expenses.isEmpty
                    ? const Center(child: Text('No expenses yet. Add one!'))
                    : ListView.builder(
                      itemCount: currentGroup.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = currentGroup.expenses[index];
                        return Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('Delete Expense?'),
                                    content: const Text(
                                      'Are you sure you want to delete this expense?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              final removedExpense =
                                  currentGroup.expenses[index];
                              final provider = Provider.of<GroupProvider>(
                                context,
                                listen: false,
                              );

                              provider.removeExpense(
                                currentGroup.id,
                                removedExpense.id,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Expense deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      provider.addExpense(
                                        currentGroup.id,
                                        removedExpense,
                                      );
                                    },
                                  ),
                                ),
                              );

                              return true;
                            }

                            return false;
                          },
                          child: ListTile(
                            title: Text(expense.title),
                            subtitle: Text(
                              'Paid by: ${expense.paidBy}\nSplit between: ${expense.splitBetween.join(', ')}',
                            ),
                            trailing: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddExpenseScreen(
                                        groupId: currentGroup.id,
                                        expense: expense,
                                      ),
                                ),
                              ).then((_) {
                                if (mounted) setState(() {});
                              });
                            },
                          ),
                        );
                      },
                    ),
          ),

          // 👉 Your summary card
          Card(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Group Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...summary.entries
                      .toList()
                      .asMap()
                      .entries
                      .where(
                        (e) => _showAllSummary || e.key < 4,
                      ) // show only 4 unless expanded
                      .map((e) {
                        final entry = e.value;
                        final name = entry.key;
                        final paid = entry.value['paid']!;
                        final share = entry.value['share']!;
                        final balance = entry.value['balance']!;
                        final balanceText = balance.abs().toStringAsFixed(2);
                        final balanceColor =
                            balance > 0
                                ? Colors.green
                                : (balance < 0 ? Colors.red : Colors.grey);
                        final balanceMessage =
                            balance > 0
                                ? 'is owed \$$balanceText'
                                : balance < 0
                                ? 'owes \$$balanceText'
                                : 'is settled';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Paid: \$${paid.toStringAsFixed(2)}'),
                                  Text(
                                    'Owed Portion: \$${share.toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    balanceMessage,
                                    style: TextStyle(color: balanceColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  if (summary.length > 4)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllSummary = !_showAllSummary;
                        });
                      },
                      child: Text(_showAllSummary ? 'Collapse' : 'Show All'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
