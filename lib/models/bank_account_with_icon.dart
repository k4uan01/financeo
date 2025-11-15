import 'bank_account_icon_model.dart';

/// Modelo para conta bancária com ícone incluído
/// Retornado pela API get_bank_accounts()
class BankAccountWithIcon {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final String? iconColor;

  BankAccountWithIcon({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    this.iconColor,
  });

  factory BankAccountWithIcon.fromJson(Map<String, dynamic> json) {
    return BankAccountWithIcon(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      icon: IconData.fromJson(json['icon'] as Map<String, dynamic>),
      iconColor: json['icon_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'icon': icon.toJson(),
      'icon_color': iconColor,
    };
  }

  @override
  String toString() {
    return 'BankAccountWithIcon(id: $id, name: $name, balance: $balance, icon: $icon, iconColor: $iconColor)';
  }
}

/// Dados do ícone retornados pela API
class IconData {
  final String id;
  final String image;
  final String type;

  IconData({required this.id, required this.image, required this.type});

  factory IconData.fromJson(Map<String, dynamic> json) {
    return IconData(
      id: json['id'] as String,
      image: json['image'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image, 'type': type};
  }

  bool get isGeneric => type == 'generic';
  bool get isBankingInstitution => type == 'banking institution';

  @override
  String toString() {
    return 'IconData(id: $id, image: $image, type: $type)';
  }
}
