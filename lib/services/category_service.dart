import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';
import '../models/category_with_icon.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<CategoryDetailResponse> getCategory(String categoryId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return CategoryDetailResponse(
          status: false,
          message: 'Usuário não autenticado',
          category: null,
        );
      }

      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      if (categoryId.trim().isEmpty) {
        return CategoryDetailResponse(
          status: false,
          message: 'ID da categoria é obrigatório',
          category: null,
        );
      }

      final response = await _supabase.rpc(
        'get_category',
        params: {'p_category_id': categoryId},
      );

      if (response == null) {
        return CategoryDetailResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          category: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message =
          responseMap['message'] as String? ?? 'Erro ao buscar categoria';
      final data = responseMap['data'] as Map<String, dynamic>?;

      return CategoryDetailResponse(
        status: status,
        message: message,
        category: data != null ? CategoryWithIcon.fromJson(data) : null,
      );
    } catch (e) {
      return CategoryDetailResponse(
        status: false,
        message: 'Erro ao buscar categoria: $e',
        category: null,
      );
    }
  }

  Future<CategoryListResponse> getCategories({
    int itemsPerPage = 20,
    int currentPage = 1,
    String? type,
    bool? isStandard,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return CategoryListResponse(
          status: false,
          message: 'Usuário não autenticado',
          categories: const [],
          pagination: null,
        );
      }

      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      if (itemsPerPage < 1) {
        return CategoryListResponse(
          status: false,
          message: 'Items por página deve ser maior que 0',
          categories: const [],
          pagination: null,
        );
      }

      if (currentPage < 1) {
        return CategoryListResponse(
          status: false,
          message: 'Página atual deve ser maior que 0',
          categories: const [],
          pagination: null,
        );
      }

      if (type != null && type.isNotEmpty && type != 'expense' && type != 'revenue') {
        return CategoryListResponse(
          status: false,
          message: 'Tipo inválido. Use expense ou revenue',
          categories: const [],
          pagination: null,
        );
      }

      final params = <String, dynamic>{
        'p_items_page': itemsPerPage,
        'p_current_page': currentPage,
      };

      if (type != null && type.isNotEmpty) {
        params['p_type'] = type;
      }

      if (isStandard != null) {
        params['p_is_standard'] = isStandard.toString();
      }

      final response = await _supabase.rpc('get_categories', params: params);

      if (response == null) {
        return CategoryListResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          categories: const [],
          pagination: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message = responseMap['message'] as String? ?? 'Erro ao buscar categorias';
      final dataList = (responseMap['data'] as List<dynamic>? ?? [])
          .map((item) => CategoryWithIcon.fromJson(item as Map<String, dynamic>))
          .toList();

      final paginationData = responseMap['pagination'] as Map<String, dynamic>?;
      final pagination = paginationData != null
          ? CategoryPagination.fromJson(paginationData)
          : null;

      return CategoryListResponse(
        status: status,
        message: message,
        categories: dataList,
        pagination: pagination,
      );
    } catch (e) {
      return CategoryListResponse(
        status: false,
        message: 'Erro ao buscar categorias: $e',
        categories: const [],
        pagination: null,
      );
    }
  }

  Future<CategoryEditResponse> editCategory({
    required String categoryId,
    String? name,
    String? iconId,
    String? iconColor,
    String? type,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return CategoryEditResponse(
          status: false,
          message: 'Usuário não autenticado',
          category: null,
        );
      }

      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      if (categoryId.trim().isEmpty) {
        return CategoryEditResponse(
          status: false,
          message: 'ID da categoria é obrigatório',
          category: null,
        );
      }

      final params = <String, dynamic>{
        'p_category_id': categoryId,
      };

      if (name != null) {
        if (name.trim().isEmpty) {
          return CategoryEditResponse(
            status: false,
            message: 'Nome da categoria é obrigatório',
            category: null,
          );
        }
        params['p_name'] = name.trim();
      }

      if (iconId != null) {
        if (iconId.trim().isEmpty) {
          return CategoryEditResponse(
            status: false,
            message: 'Selecione um ícone válido',
            category: null,
          );
        }
        params['p_icon_id'] = iconId;
      }

      if (iconColor != null) {
        if (iconColor.trim().isEmpty) {
          return CategoryEditResponse(
            status: false,
            message: 'Selecione uma cor válida para o ícone',
            category: null,
          );
        }
        params['p_icon_color'] = iconColor.toUpperCase();
      }

      if (type != null) {
        if (type != 'expense' && type != 'revenue') {
          return CategoryEditResponse(
            status: false,
            message: 'Tipo inválido. Use expense ou revenue',
            category: null,
          );
        }
        params['p_type'] = type;
      }

      final response = await _supabase.rpc(
        'post_edit_category',
        params: params,
      );

      if (response == null) {
        return CategoryEditResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          category: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message =
          responseMap['message'] as String? ?? 'Erro ao editar categoria';
      final data = responseMap['data'] as Map<String, dynamic>?;

      return CategoryEditResponse(
        status: status,
        message: message,
        category: data != null ? CategoryWithIcon.fromJson(data) : null,
      );
    } catch (e) {
      return CategoryEditResponse(
        status: false,
        message: 'Erro ao editar categoria: $e',
        category: null,
      );
    }
  }

  Future<CategoryCreateResponse> createCategory({
    required String name,
    required String iconId,
    required String iconColor,
    required String type,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return CategoryCreateResponse(
          status: false,
          message: 'Usuário não autenticado',
          data: null,
        );
      }

      if (name.trim().isEmpty) {
        return CategoryCreateResponse(
          status: false,
          message: 'Nome da categoria é obrigatório',
          data: null,
        );
      }

      if (iconId.trim().isEmpty) {
        return CategoryCreateResponse(
          status: false,
          message: 'Selecione um ícone',
          data: null,
        );
      }

      if (iconColor.trim().isEmpty) {
        return CategoryCreateResponse(
          status: false,
          message: 'Selecione uma cor para o ícone',
          data: null,
        );
      }

      if (type != 'expense' && type != 'revenue') {
        return CategoryCreateResponse(
          status: false,
          message: 'Tipo inválido. Use expense ou revenue',
          data: null,
        );
      }

      final response = await _supabase.rpc(
        'post_create_category',
        params: {
          'p_name': name.trim(),
          'p_icon_id': iconId,
          'p_icon_color': iconColor.toUpperCase(),
          'p_type': type,
        },
      );

      if (response != null) {
        return CategoryCreateResponse.fromJson(
          response as Map<String, dynamic>,
        );
      }

      return CategoryCreateResponse(
        status: false,
        message: 'Erro ao processar resposta da API',
        data: null,
      );
    } catch (e) {
      return CategoryCreateResponse(
        status: false,
        message: 'Erro ao criar categoria: $e',
        data: null,
      );
    }
  }

  Future<CategoryDeleteResponse> deleteCategory({
    required String categoryId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return CategoryDeleteResponse(
          status: false,
          message: 'Usuário não autenticado',
        );
      }

      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      if (categoryId.trim().isEmpty) {
        return CategoryDeleteResponse(
          status: false,
          message: 'ID da categoria é obrigatório',
        );
      }

      final response = await _supabase.rpc(
        'delete_category',
        params: {
          'p_category_id': categoryId,
        },
      );

      if (response == null) {
        return CategoryDeleteResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message =
          responseMap['message'] as String? ?? 'Erro ao excluir categoria';

      return CategoryDeleteResponse(
        status: status,
        message: message,
      );
    } catch (e) {
      return CategoryDeleteResponse(
        status: false,
        message: 'Erro ao excluir categoria: $e',
      );
    }
  }
}

class CategoryCreateResponse {
  final bool status;
  final String message;
  final CategoryModel? data;

  CategoryCreateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryCreateResponse.fromJson(Map<String, dynamic> json) {
    return CategoryCreateResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? 'Resposta sem mensagem',
      data: json['data'] != null
          ? CategoryModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CategoryListResponse {
  final bool status;
  final String message;
  final List<CategoryWithIcon> categories;
  final CategoryPagination? pagination;

  CategoryListResponse({
    required this.status,
    required this.message,
    required this.categories,
    required this.pagination,
  });
}

class CategoryPagination {
  final int totalItems;
  final int totalPages;
  final int currentPage;

  CategoryPagination({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory CategoryPagination.fromJson(Map<String, dynamic> json) {
    return CategoryPagination(
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
    );
  }
}

class CategoryDetailResponse {
  final bool status;
  final String message;
  final CategoryWithIcon? category;

  CategoryDetailResponse({
    required this.status,
    required this.message,
    required this.category,
  });
}

class CategoryEditResponse {
  final bool status;
  final String message;
  final CategoryWithIcon? category;

  CategoryEditResponse({
    required this.status,
    required this.message,
    required this.category,
  });
}

class CategoryDeleteResponse {
  final bool status;
  final String message;

  CategoryDeleteResponse({
    required this.status,
    required this.message,
  });
}
