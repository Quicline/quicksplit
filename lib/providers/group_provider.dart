import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/expense.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  void createGroup(String name, List<String> members) {
    final newGroup = Group(
      id: DateTime.now().toString(),
      name: name,
      members: members,
    );
    _groups.add(newGroup);
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void addExpense(String groupId, Expense expense) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].expenses.add(expense);
      notifyListeners();
    }
  }
}
