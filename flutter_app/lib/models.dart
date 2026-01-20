class Fee {
  final int id;
  final String date; // "YYYY-MM-DD"
  final double amount;
  final String type;
  final String category;
  final String description;

  Fee({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'] as int,
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
    };
  }
}

class MonthlyTotal {
  final String month; // e.g. "2025-12"
  final double total;

  MonthlyTotal({required this.month, required this.total});
}

class CategoryTotal {
  final String category;
  final double total;

  CategoryTotal({required this.category, required this.total});
}

