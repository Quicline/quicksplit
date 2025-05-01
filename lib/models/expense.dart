class Expense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
  });
}
