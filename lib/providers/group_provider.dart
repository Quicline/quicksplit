import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/expense.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  bool _isProUser = false;

  bool get isProUser => _isProUser;

  List<Group> get groups => _groups;

  /// Call this early in app lifecycle to cache pro status
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isProUser = prefs.getBool('isProUser') ?? false;
  }

  Future<void> refreshProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isProUser = prefs.getBool('isProUser') ?? false;
    notifyListeners();
  }

  void createGroup(String name, List<String> members) {
    if (!_isProUser && _groups.length >= 2) {
      throw Exception('Free users can only create 2 groups.');
    }

    final newGroup = Group(
      id: DateTime.now().toString(),
      name: name,
      members: members,
      createdAt: DateTime.now(),
    );
    _groups.add(newGroup);
    saveGroups();
    notifyListeners();
  }

  Future<bool> addGroup(Group group) async {
    if (!_isProUser && _groups.length >= 2) return false;
    _groups.add(group);
    await saveGroups();
    notifyListeners();
    return true;
  }

  Future<bool> removeGroup(String groupId) async {
    if (!_isProUser && _groups.length <= 2) {
      return false;
    }

    final initialLength = _groups.length;
    _groups.removeWhere((g) => g.id == groupId);
    final wasRemoved = _groups.length < initialLength;

    if (wasRemoved) {
      await saveGroups();
      notifyListeners();
    }

    return wasRemoved;
  }

  Future<bool> updateGroup(Group group) async {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      await saveGroups();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> addExpense(String groupId, Expense expense) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return false;

    if (!_isProUser && _groups[groupIndex].expenses.length >= 3) {
      return false;
    }

    _groups[groupIndex].expenses.add(expense);
    await saveGroups();
    notifyListeners();
    return true;
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

  Future<bool> removeExpense(String groupId, String expenseId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return false;

    if (!_isProUser && _groups[groupIndex].expenses.length <= 3) {
      return false;
    }

    _groups[groupIndex].expenses.removeWhere((e) => e.id == expenseId);
    await saveGroups();
    notifyListeners();
    return true;
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

  void markSettlement(String groupId, String key) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.settledTransactions[key] = true;
    saveGroups();
    notifyListeners();
  }

  void unmarkSettlement(String groupId, String key) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.settledTransactions.remove(key);
    saveGroups();
    notifyListeners();
  }

  bool isSettled(String groupId, String key) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    return group.settledTransactions.containsKey(key);
  }

  Map<String, Map<String, double>> calculateMemberSummary(String groupId) {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    final summary = <String, Map<String, double>>{};

    for (final expense in group.expenses) {
      final perPersonShare = expense.amount / expense.splitBetween.length;

      // Ensure all members and payer are initialized
      for (final member in [...expense.splitBetween, expense.paidBy]) {
        summary.putIfAbsent(
          member,
          () => {'paid': 0.0, 'share': 0.0, 'balance': 0.0},
        );
      }

      for (final member in expense.splitBetween) {
        summary[member]!['share'] =
            (summary[member]!['share'] ?? 0) + perPersonShare;
      }

      summary[expense.paidBy]!['paid'] =
          (summary[expense.paidBy]!['paid'] ?? 0) + expense.amount;
    }

    for (final entry in summary.entries) {
      final paid = entry.value['paid'] ?? 0;
      final share = entry.value['share'] ?? 0;
      entry.value['balance'] = paid - share;
    }

    return summary;
  }

  /// Smart Settlement: Calculate who should pay whom and how much to settle balances.
  List<Map<String, dynamic>> calculateSettlement(String groupId) {
    final summary = calculateMemberSummary(groupId);
    final balances = <String, double>{};

    // Extract balances from summary
    summary.forEach((name, data) {
      balances[name] = (data['paid'] ?? 0) - (data['share'] ?? 0);
    });

    final payers = <String, double>{};
    final receivers = <String, double>{};

    balances.forEach((name, balance) {
      if (balance < 0) {
        payers[name] = -balance;
      } else if (balance > 0) {
        receivers[name] = balance;
      }
    });

    final settlements = <Map<String, dynamic>>[];

    for (final payer in payers.entries) {
      var owed = payer.value;

      for (final receiver in receivers.entries.toList()) {
        if (owed == 0) break;

        final payAmount = owed < receiver.value ? owed : receiver.value;

        settlements.add({
          'from': payer.key,
          'to': receiver.key,
          'amount': double.parse(payAmount.toStringAsFixed(2)),
        });

        owed -= payAmount;
        receivers[receiver.key] = receiver.value - payAmount;
      }
    }

    return settlements;
  }

  // Removed isFreeTier async getter, use isProUser instead.

  int get totalExpenses {
    return _groups.fold(0, (sum, group) => sum + group.expenses.length);
  }

  /// For testing: clears all stored preferences and resets app state.
  Future<void> resetAppStateForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _groups = [];
    _isProUser = false;
    notifyListeners();
  }
}
