import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';
import 'expense_list_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  final Group? existingGroup;

  const CreateGroupScreen({Key? key, this.existingGroup}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  final List<String> _members = [];
  String _selectedGroupType = 'Trip';
  final List<String> _groupTypes = [
    'General', // <- Add this!
    'Trip',
    'Roommates',
    'Event',
    'Business',
    'Other',
  ];

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Trip':
        return Icons.flight_takeoff;
      case 'Roommates':
        return Icons.home;
      case 'Event':
        return Icons.celebration;
      case 'Business':
        return Icons.work;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.group;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingGroup != null) {
      _groupNameController.text = widget.existingGroup!.name;
      _members.addAll(widget.existingGroup!.members);
      _selectedGroupType = widget.existingGroup!.type;
    }
  }

  void _createGroup() {
    final provider = Provider.of<GroupProvider>(context, listen: false);

    if (_groupNameController.text.isNotEmpty) {
      if (widget.existingGroup != null) {
        final updatedGroup = Group(
          id: widget.existingGroup!.id,
          name: _groupNameController.text,
          members: _members,
          expenses: widget.existingGroup!.expenses,
          type: _selectedGroupType,
          createdAt: widget.existingGroup!.createdAt,
        );
        provider.updateGroup(updatedGroup);
        Navigator.pop(context); // Return to previous screen
      } else {
        final newGroup = Group(
          id: DateTime.now().toString(),
          name: _groupNameController.text,
          members: _members,
          type: _selectedGroupType,
          createdAt: DateTime.now(),
        );
        provider.addGroup(newGroup);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpenseListScreen(group: newGroup)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingGroup != null ? 'Edit Group' : 'Create Group',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGroupType,
              decoration: InputDecoration(
                labelText: 'Group Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items:
                  _groupTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(
                            _getIconForType(type),
                            size: 18,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGroupType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberController,
                    decoration: InputDecoration(
                      labelText: 'Add Member',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _createGroup,
              child: Text(
                widget.existingGroup != null
                    ? 'Save Changes'
                    : 'Create and Continue',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
