class CategoryModel {
  final String id;
  final String name;
  final String type;
  final String iconId;
  final String iconColor;
  final bool isStandard;
  final String userId;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconId,
    required this.iconColor,
    required this.isStandard,
    required this.userId,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      iconId: json['icon_id'] as String,
      iconColor: json['icon_color'] as String,
      isStandard: json['is_standard'] as bool? ?? false,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
