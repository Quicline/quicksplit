import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicksplit/screens/group_list_screen.dart';
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

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          final groupProvider = Provider.of<GroupProvider>(
            context,
            listen: false,
          );
          final existingGroup = groupProvider.groups.firstWhere(
            (g) => g.id == widget.group.id,
            orElse:
                () => Group(
                  id: '',
                  name: '',
                  members: [],
                  expenses: [],
                  createdAt: DateTime.now(),
                ),
          );
          if (existingGroup.expenses.isEmpty) {
            Future.microtask(() {
              Navigator.popUntil(context, (route) => route.isFirst);
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.white,
          // foregroundColor: const Color(0xFF4CAF90),
          elevation: 1,
          title: Text(
            currentGroup.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(groupId: currentGroup.id),
                  ),
                );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by adding your first expense!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentGroup.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = currentGroup.expenses[index];
                      return Card(
                        margin: const EdgeInsets.all(12),
                        elevation: 2,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.onPrimary,
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
                                          .calculateMemberSummary(
                                            currentGroup.id,
                                          );
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
                            title: Text(
                              expense.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            subtitle: Text(
                              'Paid by: ${expense.paidBy}\nSplit between: ${expense.splitBetween.join(', ')}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            trailing: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                // Tabbed Summary and Settlements UI
                const SizedBox(height: 16),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: const [
                          Tab(text: 'Summary'),
                          Tab(text: 'Settlements'),
                        ],
                      ),
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          children: [
                            // Summary Tab
                            Card(
                              margin: const EdgeInsets.all(12),
                              elevation: 2,
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Stack(
                                  children: [
                                    SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Each member’s balance in the group',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (summary.isEmpty) ...[
                                            const SizedBox(height: 32),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    size: 64,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'No summary data',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade600,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Add expenses to see group summary',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          ...summary.entries.map((entry) {
                                            final name = entry.key;
                                            final paid = entry.value['paid']!;
                                            final share = entry.value['share']!;
                                            final balance =
                                                entry.value['balance']!;
                                            final balanceText = balance
                                                .abs()
                                                .toStringAsFixed(2);
                                            final balanceColor =
                                                balance > 0
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : (balance < 0
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.error
                                                        : Colors.grey);
                                            final balanceMessage =
                                                balance > 0
                                                    ? 'is owed \$$balanceText'
                                                    : balance < 0
                                                    ? 'owes \$$balanceText'
                                                    : 'is settled';

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Total paid: \$${paid.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Share owed: \$${share.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        ),
                                                      ),
                                                      Text(
                                                        balanceMessage,
                                                        style: TextStyle(
                                                          color: balanceColor,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          const SizedBox(height: 16),
                                          // Share Summary button removed
                                          const SizedBox(
                                            height: 30,
                                          ), // Padding for fade visibility
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Divider or spacing between summary and settlements
                            // (Handled outside TabBarView, see below)

                            // Settlements Tab
                            Card(
                              margin: const EdgeInsets.all(12),
                              elevation: 2,
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Stack(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final Map<
                                          String,
                                          List<Map<String, dynamic>>
                                        >
                                        groupedSettlements = {};
                                        for (final s in settlements) {
                                          final payer = s['from'];
                                          groupedSettlements
                                              .putIfAbsent(payer, () => [])
                                              .add(s);
                                        }
                                        final groupedList =
                                            groupedSettlements.entries.toList();
                                        return ListView(
                                          padding: const EdgeInsets.only(
                                            bottom: 100,
                                          ),
                                          children: [
                                            Text(
                                              'Settlement Suggestions',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                foregroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                              ),
                                              icon: const Icon(Icons.copy),
                                              label: const Text(
                                                'Copy Settlements to Clipboard',
                                              ),
                                              onPressed:
                                                  settlements.isEmpty
                                                      ? null
                                                      : () {
                                                        final buffer =
                                                            StringBuffer();
                                                        buffer.writeln(
                                                          'Settlement Summary for Group: ${widget.group.name}',
                                                        );
                                                        for (final s
                                                            in settlements) {
                                                          final from =
                                                              s['from'];
                                                          final to = s['to'];
                                                          final amount =
                                                              s['amount'];
                                                          if (amount > 0) {
                                                            buffer.writeln(
                                                              '$from → $to: \$${amount.toStringAsFixed(2)}',
                                                            );
                                                          }
                                                        }
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text:
                                                                buffer
                                                                    .toString(),
                                                          ),
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Settlements copied to clipboard',
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onInverseSurface,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                            ),
                                            const SizedBox(height: 12),
                                            ...[
                                              if (settlements.isEmpty)
                                                Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.group_off,
                                                        size: 64,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade400,
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Text(
                                                        'No settlements yet',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Once expenses are added, we’ll calculate who owes what',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade500,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                            ...groupedList.map((entry) {
                                              final payer = entry.key;
                                              final payments =
                                                  entry.value
                                                      .where(
                                                        (s) =>
                                                            s['amount'] != 0.0,
                                                      )
                                                      .toList();

                                              if (payments.isEmpty)
                                                return const SizedBox.shrink();

                                              final allChecked = payments.every((
                                                s,
                                              ) {
                                                final key =
                                                    '${s['from']}->${s['to']}:${s['amount'].toStringAsFixed(2)}';
                                                return _settledKeys.contains(
                                                  key,
                                                );
                                              });

                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                elevation: 2,
                                                color:
                                                    Theme.of(context).cardColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ExpansionTile(
                                                  title: Text(
                                                    '$payer should pay ${payments.length} ${payments.length == 1 ? 'person' : 'people'}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          allChecked
                                                              ? Colors.grey
                                                              : Theme.of(
                                                                    context,
                                                                  )
                                                                  .colorScheme
                                                                  .primary,
                                                      decoration:
                                                          allChecked
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null,
                                                    ),
                                                  ),
                                                  children:
                                                      payments.map((s) {
                                                        final key =
                                                            '${s['from']}->${s['to']}:${s['amount'].toStringAsFixed(2)}';
                                                        final isChecked =
                                                            _settledKeys
                                                                .contains(key);
                                                        return ListTile(
                                                          title: Text(
                                                            '${s['to']} → \$${s['amount'].toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  isChecked
                                                                      ? Colors
                                                                          .grey
                                                                      : Theme.of(
                                                                        context,
                                                                      ).colorScheme.primary,
                                                              decoration:
                                                                  isChecked
                                                                      ? TextDecoration
                                                                          .lineThrough
                                                                      : null,
                                                            ),
                                                          ),
                                                          trailing: Checkbox(
                                                            value: isChecked,
                                                            activeColor:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                if (val ==
                                                                    true) {
                                                                  _settledKeys
                                                                      .add(key);
                                                                } else {
                                                                  _settledKeys
                                                                      .remove(
                                                                        key,
                                                                      );
                                                                }
                                                                _saveSettledKeys();
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      }).toList(),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add divider/spacing between summary and settlements cards
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
