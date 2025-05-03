class Expense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime createdAt;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'paidBy': paidBy,
    'splitBetween': splitBetween,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: (json['amount'] as num).toDouble(),
    paidBy: json['paidBy'],
    splitBetween: List<String>.from(json['splitBetween']),
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
    note: json['note'],
  );
}
