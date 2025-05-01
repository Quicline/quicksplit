import 'expense.dart';

class Group {
  final String id;
  final String name;
  final List<String> members;
  final List<Expense> expenses;

  Group({
    required this.id,
    required this.name,
    List<Expense>? expenses,
    List<String>? members,
  }) : expenses = List<Expense>.from(expenses ?? []),
       members = List<String>.from(members ?? []);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'members': members,
    'expenses': expenses.map((e) => e.toJson()).toList(),
  };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'],
    name: json['name'],
    members: List<String>.from(json['members']),
    expenses:
        (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
  );
}
