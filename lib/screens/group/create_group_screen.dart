import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';
import 'expense_list_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final List<String> _members = [];

  void _createGroup() {
    if (_groupNameController.text.isNotEmpty) {
      final provider = Provider.of<GroupProvider>(context, listen: false);
      final newGroup = Group(
        id: DateTime.now().toString(),
        name: _groupNameController.text,
        members: _members,
      );
      provider.addGroup(newGroup);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ExpenseListScreen(group: newGroup)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberController,
                    decoration: const InputDecoration(
                      labelText: 'Add Member',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_memberController.text.trim().isNotEmpty) {
                      setState(() {
                        _members.add(_memberController.text.trim());
                        _memberController.clear();
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children:
                  _members.map((member) {
                    return Chip(
                      label: Text(member),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          _members.remove(member);
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createGroup,
              child: const Text('Create and Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
