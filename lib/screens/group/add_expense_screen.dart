import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/models/group.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../providers/group_provider.dart';

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
    }
  }

  void _saveExpense() {
    if (_titleController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _selectedPayer != null &&
        _selectedPayer!.isNotEmpty) {
      final provider = Provider.of<GroupProvider>(context, listen: false);

      if (widget.expense != null) {
        // ✏️ Editing an existing expense
        final updatedExpense = Expense(
          id: widget.expense!.id,
          title: _titleController.text,
          amount: double.tryParse(_amountController.text) ?? 0,
          paidBy: _selectedPayer ?? '',
          splitBetween: _selectedMembers,
        );
        provider.updateExpense(widget.groupId, updatedExpense);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense updated!')));
      } else {
        // ➕ Creating a new expense
        final newExpense = Expense(
          id: uuid.v4(),
          title: _titleController.text,
          amount: double.tryParse(_amountController.text) ?? 0,
          paidBy: _selectedPayer ?? '',
          splitBetween: _selectedMembers,
        );
        provider.addExpense(widget.groupId, newExpense);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense added!')));
      }

      Navigator.pop(context);
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
      orElse: () => Group(id: '', name: '', members: [], expenses: []),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
        actions:
            widget.expense != null
                ? [
                  IconButton(
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
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
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
                        provider.removeExpense(
                          widget.groupId,
                          removedExpense.id,
                        );
                        Navigator.pop(context);

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
                ]
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPayer,
              decoration: const InputDecoration(
                labelText: 'Paid By',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 16),
            Text(
              'Split Between:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children:
                  group.members.map((member) {
                    return CheckboxListTile(
                      title: Text(member),
                      value: _selectedMembers.contains(member),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedMembers.add(member);
                          } else {
                            _selectedMembers.remove(member);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
