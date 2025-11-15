import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_icon_model.dart';

class CategoryIconService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<CategoryIconsResponse> getCategoryIcons() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return CategoryIconsResponse(
          status: false,
          message: 'Usuário não autenticado',
          data: const [],
        );
      }

      final response = await _supabase.rpc('get_category_icons');

      if (response != null) {
        return CategoryIconsResponse.fromJson(response as Map<String, dynamic>);
      }

      return CategoryIconsResponse(
        status: false,
        message: 'Erro ao processar resposta da API',
        data: const [],
      );
    } catch (e) {
      return CategoryIconsResponse(
        status: false,
        message: 'Erro ao buscar ícones: $e',
        data: const [],
      );
    }
  }
}

class CategoryIconsResponse {
  final bool status;
  final String message;
  final List<CategoryIconModel> data;

  const CategoryIconsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryIconsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return CategoryIconsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? 'Resposta sem mensagem',
      data: dataList
          .map(
            (item) => CategoryIconModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
