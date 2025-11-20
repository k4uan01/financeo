import 'category_with_icon.dart';

/// Modelo para métricas retornadas pela API get_metrics
class MetricResponse {
  final bool status;
  final String message;
  final MetricData? data;

  MetricResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MetricResponse.fromJson(Map<String, dynamic> json) {
    return MetricResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] as String?) ?? 'Erro ao buscar métricas',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MetricData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Dados das métricas
class MetricData {
  final double totalValue;
  final List<CategoryMetric> categories;

  MetricData({
    required this.totalValue,
    required this.categories,
  });

  factory MetricData.fromJson(Map<String, dynamic> json) {
    final categoriesList = (json['categories'] as List<dynamic>? ?? [])
        .map((item) => CategoryMetric.fromJson(item as Map<String, dynamic>))
        .toList();

    return MetricData(
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      categories: categoriesList,
    );
  }
}

/// Métrica de uma categoria específica
class CategoryMetric {
  final double percentage;
  final double totalValue;
  final CategoryWithIcon category;

  CategoryMetric({
    required this.percentage,
    required this.totalValue,
    required this.category,
  });

  factory CategoryMetric.fromJson(Map<String, dynamic> json) {
    return CategoryMetric(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? CategoryWithIcon.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : CategoryWithIcon(
              id: '',
              name: 'Categoria desconhecida',
              type: '',
              iconColor: '#08BF62',
              isStandard: false,
              icon: CategoryIconData(id: '', svg: ''),
            ),
    );
  }
}

