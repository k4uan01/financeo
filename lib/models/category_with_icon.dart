class CategoryWithIcon {
  final String id;
  final String name;
  final String type;
  final String iconColor;
  final bool isStandard;
  final CategoryIconData icon;

  CategoryWithIcon({
    required this.id,
    required this.name,
    required this.type,
    required this.iconColor,
    required this.isStandard,
    required this.icon,
  });

  factory CategoryWithIcon.fromJson(Map<String, dynamic> json) {
    return CategoryWithIcon(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      iconColor: json['icon_color'] as String,
      isStandard: json['is_standard'] as bool? ?? false,
      icon: CategoryIconData.fromJson(json['icon'] as Map<String, dynamic>),
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
      id: json['id'] as String,
      svg: json['svg'] as String,
    );
  }
}

