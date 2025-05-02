import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/expense.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  void createGroup(String name, List<String> members) {
    final newGroup = Group(
      id: DateTime.now().toString(),
      name: name,
      members: members,
      createdAt: DateTime.now(),
    );
    _groups.add(newGroup);
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    saveGroups();
    notifyListeners();
  }

  void removeGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    saveGroups();
    notifyListeners();
  }

  void updateGroup(Group group) {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      saveGroups();
      notifyListeners();
    }
  }

  void addExpense(String groupId, Expense expense) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].expenses.add(expense);
      saveGroups();
      notifyListeners();
    }
  }

  void updateExpense(String groupId, Expense updatedExpense) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      final expenseIndex = _groups[groupIndex].expenses.indexWhere(
        (e) => e.id == updatedExpense.id,
      );
      if (expenseIndex != -1) {
        _groups[groupIndex].expenses[expenseIndex] = updatedExpense;
        saveGroups(); // Persist updated state
        notifyListeners();
      }
    }
  }

  void removeExpense(String groupId, String expenseId) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].expenses.removeWhere((e) => e.id == expenseId);
      saveGroups();
      notifyListeners();
    }
  }

  Future<void> saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupList = _groups.map((g) => g.toJson()).toList();
    final encoded = jsonEncode(groupList);
    await prefs.setString('savedGroups', encoded);
  }

  Future<void> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('savedGroups');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _groups = decoded.map((g) => Group.fromJson(g)).toList();
      notifyListeners();
    }
  }
}
