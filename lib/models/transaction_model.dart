class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;
  final String? userId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
    this.userId,
  });

  // Converter de JSON (do Supabase) para o modelo
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      isIncome: json['is_income'] as bool,
      userId: json['user_id'] as String?,
    );
  }

  // Converter do modelo para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'is_income': isIncome,
      if (userId != null) 'user_id': userId,
    };
  }

  // Copiar com alterações
  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isIncome,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, category: $category, date: $date, isIncome: $isIncome, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.isIncome == isIncome &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        date.hashCode ^
        isIncome.hashCode ^
        userId.hashCode;
  }
}
