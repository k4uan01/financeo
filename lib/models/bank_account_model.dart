class BankAccountModel {
  final String? id;
  final String name;
  final double balance;
  final String? iconId;
  final String? iconColor;
  final String? userId;
  final DateTime? createdAt;

  BankAccountModel({
    this.id,
    required this.name,
    required this.balance,
    this.iconId,
    this.iconColor,
    this.userId,
    this.createdAt,
  });

  // Converter de JSON (do Supabase) para o modelo
  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      iconId: json['icon_id'] as String?,
      iconColor: json['icon_color'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Converter do modelo para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'balance': balance,
      if (iconId != null) 'icon_id': iconId,
      if (iconColor != null) 'icon_color': iconColor,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Copiar com alterações
  BankAccountModel copyWith({
    String? id,
    String? name,
    double? balance,
    String? iconId,
    String? iconColor,
    String? userId,
    DateTime? createdAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconId: iconId ?? this.iconId,
      iconColor: iconColor ?? this.iconColor,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'BankAccountModel(id: $id, name: $name, balance: $balance, iconId: $iconId, iconColor: $iconColor, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BankAccountModel &&
        other.id == id &&
        other.name == name &&
        other.balance == balance &&
        other.iconId == iconId &&
        other.iconColor == iconColor &&
        other.userId == userId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        balance.hashCode ^
        iconId.hashCode ^
        iconColor.hashCode ^
        userId.hashCode ^
        createdAt.hashCode;
  }
}
