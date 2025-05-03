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
    final borderRadiusValue = 12.0;
    final labelTextStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );
    final buttonTextStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.w600,
    );
    final chipTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingGroup != null ? 'Edit Group' : 'Create Group',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
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
                labelStyle: labelTextStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGroupType,
              decoration: InputDecoration(
                labelText: 'Group Type',
                labelStyle: labelTextStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(type, style: labelTextStyle),
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberController,
                    decoration: InputDecoration(
                      labelText: 'Add Member',
                      labelStyle: labelTextStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadiusValue),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadiusValue),
                    ),
                  ),
                  onPressed: () {
                    if (_memberController.text.trim().isNotEmpty) {
                      setState(() {
                        _members.add(_memberController.text.trim());
                        _memberController.clear();
                      });
                    }
                  },
                  child: Text('Add', style: buttonTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children:
                  _members.map((member) {
                    return Chip(
                      label: Text(member, style: chipTextStyle),
                      deleteIcon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onDeleted: () {
                        setState(() {
                          _members.remove(member);
                        });
                      },
                      backgroundColor:
                          Theme.of(context).chipTheme.backgroundColor,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                ),
              ),
              onPressed: _createGroup,
              child: Text(
                widget.existingGroup != null
                    ? 'Save Changes'
                    : 'Create and Continue',
                style: buttonTextStyle,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}
