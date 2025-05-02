import 'expense.dart';

class Group {
  final String id;
  final String name;
  final List<String> members;
  final List<Expense> expenses;
  final DateTime createdAt;
  final String type;

  Group({
    required this.id,
    required this.name,
    List<Expense>? expenses,
    List<String>? members,
    required this.createdAt,
    this.type = 'General',
  }) : expenses = List<Expense>.from(expenses ?? []),
       members = List<String>.from(members ?? []);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'members': members,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'type': type,
  };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'],
    name: json['name'],
    members: List<String>.from(json['members']),
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
    expenses:
        (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
    type: (json['type'] is String) ? json['type'] : 'General',
  );
}
