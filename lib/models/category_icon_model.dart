class CategoryIconModel {
  final String id;
  final String svg;

  CategoryIconModel({required this.id, required this.svg});

  factory CategoryIconModel.fromJson(Map<String, dynamic> json) {
    return CategoryIconModel(
      id: json['id'] as String,
      svg: json['svg'] as String,
    );
  }
}
