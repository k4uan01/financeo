
class TransactionWithCategory {
  final String id;
  final String description;
  final double value;
  final String type; // 'revenue' ou 'expense'
  final DateTime date;
  final BankAccountData bankAccount;
  final CategoryData category;

  TransactionWithCategory({
    required this.id,
    required this.description,
    required this.value,
    required this.type,
    required this.date,
    required this.bankAccount,
    required this.category,
  });

  factory TransactionWithCategory.fromJson(Map<String, dynamic> json) {
    return TransactionWithCategory(
      id: json['id'].toString(),
      description: json['description'] as String? ?? '',
      value: (json['value'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      bankAccount: BankAccountData.fromJson(
        json['bank_account'] as Map<String, dynamic>,
      ),
      category: CategoryData.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
    );
  }

  bool get isRevenue => type == 'revenue';
  bool get isExpense => type == 'expense';
}

class BankAccountData {
  final String id;
  final String name;

  BankAccountData({
    required this.id,
    required this.name,
  });

  factory BankAccountData.fromJson(Map<String, dynamic> json) {
    return BankAccountData(
      id: json['id'].toString(),
      name: json['name'] as String,
    );
  }
}

class CategoryData {
  final String id;
  final String name;
  final String iconColor;
  final CategoryIconData icon;

  CategoryData({
    required this.id,
    required this.name,
    required this.iconColor,
    required this.icon,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'].toString(),
      name: json['name'] as String,
      iconColor: json['icon_color'] as String,
      icon: CategoryIconData.fromJson(
        json['icon'] as Map<String, dynamic>,
      ),
    );
  }
}

class CategoryIconData {
  final String id;
  final String svg;

  CategoryIconData({
    required this.id,
    required this.svg,
  });

  factory CategoryIconData.fromJson(Map<String, dynamic> json) {
    return CategoryIconData(
      id: json['id'].toString(),
      svg: json['svg'] as String,
    );
  }
}

