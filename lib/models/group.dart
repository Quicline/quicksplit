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
}
