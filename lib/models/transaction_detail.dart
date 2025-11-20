/// Modelo completo de transação com todos os detalhes
/// Retornado pela API get_transaction()
class TransactionDetail {
  final String id;
  final String description;
  final double value;
  final String type; // 'revenue' ou 'expense'
  final DateTime date;
  final DateTime createdAt;
  final TransactionCategoryDetail category;
  final TransactionBankAccountDetail bankAccount;

  TransactionDetail({
    required this.id,
    required this.description,
    required this.value,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.category,
    required this.bankAccount,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    // Parse de data com suporte a diferentes formatos
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          // Tentar formato alternativo se necessário
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return TransactionDetail(
      id: json['id']?.toString() ?? '',
      description: json['description'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'expense',
      date: parseDate(json['date']),
      createdAt: parseDate(json['created_at']),
      category: TransactionCategoryDetail.fromJson(
        json['category'] as Map<String, dynamic>? ?? {},
      ),
      bankAccount: TransactionBankAccountDetail.fromJson(
        json['bank_account'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  bool get isRevenue => type == 'revenue';
  bool get isExpense => type == 'expense';
}

class TransactionCategoryDetail {
  final String id;
  final String name;
  final String type;
  final String iconColor;
  final bool isStandard;
  final CategoryIconDetail icon;

  TransactionCategoryDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.iconColor,
    required this.isStandard,
    required this.icon,
  });

  factory TransactionCategoryDetail.fromJson(Map<String, dynamic> json) {
    return TransactionCategoryDetail(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      iconColor: json['icon_color'] as String? ?? '#08BF62',
      isStandard: json['is_standard'] as bool? ?? false,
      icon: CategoryIconDetail.fromJson(
        json['icon'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CategoryIconDetail {
  final String id;
  final String name;
  final String svg;

  CategoryIconDetail({
    required this.id,
    required this.name,
    required this.svg,
  });

  factory CategoryIconDetail.fromJson(Map<String, dynamic> json) {
    return CategoryIconDetail(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      svg: json['svg'] as String? ?? '',
    );
  }
}

class TransactionBankAccountDetail {
  final String id;
  final String name;
  final BankAccountIconDetail icon;

  TransactionBankAccountDetail({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory TransactionBankAccountDetail.fromJson(Map<String, dynamic> json) {
    return TransactionBankAccountDetail(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      icon: BankAccountIconDetail.fromJson(
        json['icon'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BankAccountIconDetail {
  final String id;
  final String image;
  final String type;

  BankAccountIconDetail({
    required this.id,
    required this.image,
    required this.type,
  });

  factory BankAccountIconDetail.fromJson(Map<String, dynamic> json) {
    return BankAccountIconDetail(
      id: json['id']?.toString() ?? '',
      image: json['image'] as String? ?? '',
      type: json['type'] as String? ?? 'generic',
    );
  }

  bool get isGeneric => type == 'generic';
  bool get isBankingInstitution => type == 'banking institution';
}

