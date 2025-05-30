import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/models/group.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../providers/group_provider.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  final Expense? expense;

  const AddExpenseScreen({super.key, required this.groupId, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedPayer;
  final uuid = const Uuid();
  List<String> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedPayer = widget.expense!.paidBy;
      _selectedMembers = [...widget.expense!.splitBetween];
      _noteController.text = widget.expense!.note ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    setState(() {}); // Trigger UI validation feedback

    final isTitleValid = _titleController.text.isNotEmpty;
    final isAmountValid =
        _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.tryParse(_amountController.text)! > 0;
    final isPayerValid = _selectedPayer != null && _selectedPayer!.isNotEmpty;
    final isSplitValid = _selectedMembers.isNotEmpty;

    if (isTitleValid && isAmountValid && isPayerValid && isSplitValid) {
      // Remove duplicates from _selectedMembers
      _selectedMembers = _selectedMembers.toSet().toList();

      final provider = Provider.of<GroupProvider>(context, listen: false);

      if (widget.expense != null) {
        final isProUser = await provider.isProUser;
        if (!isProUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Editing expenses is a premium feature. Upgrade to unlock this.',
              ),
            ),
          );
          return;
        }

        final updatedExpense = Expense(
          id: widget.expense!.id,
          title: _titleController.text,
          amount: double.tryParse(_amountController.text) ?? 0,
          paidBy: _selectedPayer ?? '',
          splitBetween: _selectedMembers,
          createdAt: widget.expense!.createdAt,
          note: _noteController.text,
        );
        provider.updateExpense(widget.groupId, updatedExpense);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense updated!')));
        return;
      } else {
        // Check free tier limit before adding new expense
        if (provider.totalExpenses >= 3 && !provider.isProUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Free tier limit reached. Upgrade to add more expenses.',
              ),
            ),
          );
          return;
        }
        // ➕ Creating a new expense
        final newExpense = Expense(
          id: uuid.v4(),
          title: _titleController.text,
          amount: double.tryParse(_amountController.text) ?? 0,
          paidBy: _selectedPayer ?? '',
          splitBetween: _selectedMembers,
          createdAt: DateTime.now(),
          note: _noteController.text,
        );
        final success = await provider.addExpense(widget.groupId, newExpense);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Free tier limit reached. Upgrade to add more expenses.',
              ),
            ),
          );
          return;
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense added!')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse:
          () => Group(
            id: '',
            name: '',
            members: [],
            expenses: [],
            createdAt: DateTime.now(),
          ),
    );

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color(0xFFE6FCF6),
        // foregroundColor: const Color(0xFF006D5B),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.expense != null ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions:
            widget.expense != null
                ? [
                  IconTheme(
                    data: IconThemeData(
                      color: Theme.of(context).iconTheme.color,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
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
                          final removedExpense = widget.expense!;

                          final provider = Provider.of<GroupProvider>(
                            context,
                            listen: false,
                          );
                          final success = await provider.removeExpense(
                            widget.groupId,
                            removedExpense.id,
                          );
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You must keep at least 3 expenses on the free plan.',
                                ),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Expense deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  provider.addExpense(
                                    widget.groupId,
                                    removedExpense,
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ]
                : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  border: const OutlineInputBorder(),
                  errorText:
                      _titleController.text.isNotEmpty
                          ? null
                          : 'Title is required',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: const OutlineInputBorder(),
                  errorText:
                      (_amountController.text.isNotEmpty &&
                              double.tryParse(_amountController.text) != null &&
                              double.tryParse(_amountController.text)! > 0)
                          ? null
                          : 'Enter a valid positive amount',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedPayer,
                  decoration: InputDecoration(
                    labelText: 'Paid By',
                    border: const OutlineInputBorder(),
                    errorText:
                        (_selectedPayer != null && _selectedPayer!.isNotEmpty)
                            ? null
                            : 'Please select a payer',
                  ),
                  items:
                      group.members.map((member) {
                        return DropdownMenuItem<String>(
                          value: member,
                          child: Text(member),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPayer = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Split Between',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    child: Column(
                      children:
                          group.members.map((member) {
                            return CheckboxListTile(
                              title: Text(member),
                              value: _selectedMembers.contains(member),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedMembers =
                                        {..._selectedMembers, member}.toList();
                                  } else {
                                    _selectedMembers.remove(member);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            );
                          }).toList(),
                    ),
                  ),
                  if (_selectedMembers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select at least one member.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (widget.expense != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Created: ${DateFormat.yMMMd().add_jm().format(widget.expense!.createdAt)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
