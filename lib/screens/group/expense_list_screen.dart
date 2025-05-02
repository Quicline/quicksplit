import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _showAllSettlements = false;
  Map<String, Map<String, double>> _summary = {};
  List<Map<String, dynamic>> _settlements = [];
  Set<String> _settledKeys = {};

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('settled_${widget.group.id}') ?? [];
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      setState(() {
        _settledKeys = stored.toSet();
        _summary = groupProvider.calculateMemberSummary(widget.group.id);
        _settlements = groupProvider.calculateSettlement(widget.group.id);
      });
    });
  }

  Future<void> _saveSettledKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'settled_${widget.group.id}',
      _settledKeys.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentGroup = groupProvider.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );
    final summary = _summary;
    final settlements = _settlements;

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
                if (mounted) {
                  final groupProvider = Provider.of<GroupProvider>(
                    context,
                    listen: false,
                  );
                  setState(() {
                    _summary = groupProvider.calculateMemberSummary(
                      widget.group.id,
                    );
                    _settlements = groupProvider.calculateSettlement(
                      widget.group.id,
                    );
                  });
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              if (currentGroup.expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No expenses yet. Add one!')),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                        child: const Icon(Icons.delete, color: Colors.white),
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
                          final removedExpense = currentGroup.expenses[index];
                          final provider = Provider.of<GroupProvider>(
                            context,
                            listen: false,
                          );
                          provider.removeExpense(
                            currentGroup.id,
                            removedExpense.id,
                          );

                          final updatedSummary = provider
                              .calculateMemberSummary(currentGroup.id);
                          final updatedSettlements = provider
                              .calculateSettlement(currentGroup.id);

                          setState(() {
                            _summary = updatedSummary;
                            _settlements = updatedSettlements;
                          });

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
                                  final refreshedSummary = provider
                                      .calculateMemberSummary(currentGroup.id);
                                  final refreshedSettlements = provider
                                      .calculateSettlement(currentGroup.id);
                                  setState(() {
                                    _summary = refreshedSummary;
                                    _settlements = refreshedSettlements;
                                  });
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
                            if (mounted) {
                              final groupProvider = Provider.of<GroupProvider>(
                                context,
                                listen: false,
                              );
                              setState(() {
                                _summary = groupProvider.calculateMemberSummary(
                                  widget.group.id,
                                );
                                _settlements = groupProvider
                                    .calculateSettlement(widget.group.id);
                              });
                            }
                          });
                        },
                      ),
                    );
                  },
                ),

              // Consolidated Summary and Settlement Card
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Group Summary & Settlements',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...summary.entries
                          .toList()
                          .asMap()
                          .entries
                          .where((e) => _showAllSummary || e.key < 4)
                          .map((e) {
                            final entry = e.value;
                            final name = entry.key;
                            final paid = entry.value['paid']!;
                            final share = entry.value['share']!;
                            final balance = entry.value['balance']!;
                            final balanceText = balance.abs().toStringAsFixed(
                              2,
                            );
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Paid: \$${paid.toStringAsFixed(2)}',
                                      ),
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
                          child: Text(
                            _showAllSummary ? 'Collapse' : 'Show All',
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (settlements.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Settlement Suggestions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final Map<String, List<Map<String, dynamic>>>
                                groupedSettlements = {};
                                for (final s in settlements) {
                                  final payer = s['from'];
                                  groupedSettlements
                                      .putIfAbsent(payer, () => [])
                                      .add(s);
                                }
                                final groupedList =
                                    groupedSettlements.entries.toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...groupedList.map((entry) {
                                      final payer = entry.key;
                                      final payments =
                                          entry.value
                                              .where((s) => s['amount'] != 0.0)
                                              .toList();

                                      if (payments.isEmpty)
                                        return const SizedBox.shrink();

                                      return ExpansionTile(
                                        title: Text(
                                          '$payer should pay ${payments.length} ${payments.length == 1 ? 'person' : 'people'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        children:
                                            payments.map((s) {
                                              final key =
                                                  '${s['from']}->${s['to']}:${s['amount'].toStringAsFixed(2)}';
                                              final isChecked = _settledKeys
                                                  .contains(key);
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 6,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          s['to'],
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                isChecked
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black,
                                                            decoration:
                                                                isChecked
                                                                    ? TextDecoration
                                                                        .lineThrough
                                                                    : null,
                                                          ),
                                                        ),
                                                        Text(
                                                          '\$${s['amount'].toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                isChecked
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black54,
                                                            decoration:
                                                                isChecked
                                                                    ? TextDecoration
                                                                        .lineThrough
                                                                    : null,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Checkbox(
                                                      value: isChecked,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            _settledKeys.add(
                                                              key,
                                                            );
                                                          } else {
                                                            _settledKeys.remove(
                                                              key,
                                                            );
                                                          }
                                                          _saveSettledKeys();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      );
                                    }),
                                    if (groupedSettlements.length > 2)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _showAllSettlements =
                                                !_showAllSettlements;
                                          });
                                        },
                                        child: Text(
                                          _showAllSettlements
                                              ? 'Collapse'
                                              : 'Show All',
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
