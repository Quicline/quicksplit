import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/models/group.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../providers/group_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;

  const AddExpenseScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedPayer;
  final uuid = const Uuid();
  List<String> _selectedMembers = [];

  void _saveExpense() {
    if (_titleController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _selectedPayer != null &&
        _selectedPayer!.isNotEmpty) {
      final newExpense = Expense(
        id: uuid.v4(),
        title: _titleController.text,
        amount: double.tryParse(_amountController.text) ?? 0,
        paidBy: _selectedPayer ?? '',
        splitBetween: _selectedMembers,
      );

      print('Adding expense: ${newExpense.title}, ${newExpense.amount}');

      final provider = Provider.of<GroupProvider>(context, listen: false);
      provider.addExpense(widget.groupId, newExpense);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense added!')));

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
      appBar: AppBar(title: const Text('Add Expense')),
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
