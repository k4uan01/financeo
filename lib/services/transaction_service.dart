import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_with_category.dart';
import '../models/transaction_detail.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Criar uma nova transação
  /// 
  /// Parâmetros:
  /// - [value]: Valor da transação (obrigatório, deve ser > 0)
  /// - [categoryId]: ID da categoria (obrigatório)
  /// - [bankAccountId]: ID da conta bancária (obrigatório)
  /// - [date]: Data da transação (obrigatório)
  /// - [type]: Tipo da transação - 'income', 'revenue' ou 'expense' (obrigatório)
  ///   A API espera 'revenue' para receita, mas aceita 'income' que será convertido automaticamente
  /// - [description]: Descrição da transação (opcional)
  /// 
  /// Retorna TransactionCreateResponse com status, message e data
  Future<TransactionCreateResponse> createTransaction({
    required double value,
    required String categoryId,
    required String bankAccountId,
    required DateTime date,
    required String type,
    String? description,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return TransactionCreateResponse(
          status: false,
          message: 'Usuário não autenticado',
          data: null,
        );
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      // Validações
      if (value <= 0) {
        return TransactionCreateResponse(
          status: false,
          message: 'O valor deve ser maior que zero',
          data: null,
        );
      }

      if (type != 'income' && type != 'expense' && type != 'revenue') {
        return TransactionCreateResponse(
          status: false,
          message: 'O tipo deve ser "income", "revenue" ou "expense"',
          data: null,
        );
      }

      if (categoryId.trim().isEmpty) {
        return TransactionCreateResponse(
          status: false,
          message: 'O ID da categoria é obrigatório',
          data: null,
        );
      }

      if (bankAccountId.trim().isEmpty) {
        return TransactionCreateResponse(
          status: false,
          message: 'O ID da conta bancária é obrigatório',
          data: null,
        );
      }

      // Converter 'income' para 'revenue' se necessário (a API espera 'revenue' para receita)
      final apiType = type == 'income' ? 'revenue' : type;
      
      // Preparar parâmetros
      final params = <String, dynamic>{
        'p_value': value,
        'p_category_id': categoryId,
        'p_bank_account_id': bankAccountId,
        'p_date': date.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
        'p_type': apiType,
      };

      if (description != null && description.trim().isNotEmpty) {
        params['p_description'] = description.trim();
      }

      // Chamar a função RPC
      final response = await _supabase.rpc(
        'post_create_transactions',
        params: params,
      );

      if (response == null) {
        return TransactionCreateResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          data: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message = responseMap['message'] as String? ?? 'Erro ao criar transação';
      final data = responseMap['data'] as Map<String, dynamic>?;

      return TransactionCreateResponse(
        status: status,
        message: message,
        data: data,
      );
    } catch (e) {
      return TransactionCreateResponse(
        status: false,
        message: 'Erro ao criar transação: $e',
        data: null,
      );
    }
  }

  /// Buscar transações do usuário autenticado com filtros e paginação
  /// 
  /// Parâmetros:
  /// - [itemsPerPage]: Quantidade de itens por página (obrigatório)
  /// - [currentPage]: Página atual (obrigatório, começa em 1)
  /// - [startDate]: Data inicial para filtro (opcional)
  /// - [endDate]: Data final para filtro (opcional)
  /// - [search]: Texto para busca em descrição (opcional)
  /// - [type]: Tipo de transação - 'revenue' ou 'expense' (opcional)
  /// - [bankAccountId]: ID da conta bancária (opcional)
  /// - [categoryId]: ID da categoria (opcional)
  /// 
  /// Retorna TransactionListResponse com status, message, data e pagination
  Future<TransactionListResponse> getTransactions({
    required int itemsPerPage,
    required int currentPage,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    String? type,
    String? bankAccountId,
    String? categoryId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return TransactionListResponse(
          status: false,
          message: 'Usuário não autenticado',
          transactions: const [],
          pagination: null,
        );
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      // Validações
      if (itemsPerPage <= 0) {
        return TransactionListResponse(
          status: false,
          message: 'O número de itens por página deve ser maior que zero',
          transactions: const [],
          pagination: null,
        );
      }

      if (currentPage <= 0) {
        return TransactionListResponse(
          status: false,
          message: 'A página atual deve ser maior que zero',
          transactions: const [],
          pagination: null,
        );
      }

      if (type != null && type.isNotEmpty && type != 'revenue' && type != 'expense') {
        return TransactionListResponse(
          status: false,
          message: 'O tipo deve ser "revenue" ou "expense"',
          transactions: const [],
          pagination: null,
        );
      }

      // Preparar parâmetros
      final params = <String, dynamic>{
        'p_items_page': itemsPerPage,
        'p_current_page': currentPage,
      };

      if (startDate != null) {
        params['p_start_date'] = startDate.toIso8601String().split('T')[0];
      }

      if (endDate != null) {
        params['p_end_date'] = endDate.toIso8601String().split('T')[0];
      }

      if (search != null && search.trim().isNotEmpty) {
        params['p_search'] = search.trim();
      }

      if (type != null && type.isNotEmpty) {
        params['p_type'] = type;
      }

      if (bankAccountId != null && bankAccountId.trim().isNotEmpty) {
        params['p_bank_account_id'] = bankAccountId.trim();
      }

      if (categoryId != null && categoryId.trim().isNotEmpty) {
        params['p_category_id'] = categoryId.trim();
      }

      // Chamar a função RPC
      final response = await _supabase.rpc(
        'get_transactions',
        params: params,
      );

      if (response == null) {
        return TransactionListResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          transactions: const [],
          pagination: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message = responseMap['message'] as String? ?? 'Erro ao buscar transações';
      final dataList = (responseMap['data'] as List<dynamic>? ?? [])
          .map((item) => TransactionWithCategory.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();

      final paginationData = responseMap['pagination'] as Map<String, dynamic>?;
      final pagination = paginationData != null
          ? TransactionPagination.fromJson(paginationData)
          : null;

      return TransactionListResponse(
        status: status,
        message: message,
        transactions: dataList,
        pagination: pagination,
      );
    } catch (e) {
      return TransactionListResponse(
        status: false,
        message: 'Erro ao buscar transações: $e',
        transactions: const [],
        pagination: null,
      );
    }
  }

  /// Buscar uma transação específica do usuário autenticado
  /// 
  /// Parâmetros:
  /// - [transactionId]: ID da transação (obrigatório)
  /// 
  /// Retorna TransactionDetailResponse com status, message e data
  Future<TransactionDetailResponse> getTransaction({
    required String transactionId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return TransactionDetailResponse(
          status: false,
          message: 'Usuário não autenticado',
          data: null,
        );
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      // Validações
      if (transactionId.trim().isEmpty) {
        return TransactionDetailResponse(
          status: false,
          message: 'O ID da transação é obrigatório',
          data: null,
        );
      }

      // Chamar a função RPC
      final response = await _supabase.rpc(
        'get_transaction',
        params: {
          'p_transaction_id': transactionId.trim(),
        },
      );

      if (response == null) {
        return TransactionDetailResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          data: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message = responseMap['message'] as String? ?? 'Erro ao buscar transação';
      final dataMap = responseMap['data'] as Map<String, dynamic>?;

      TransactionDetail? transaction;
      if (dataMap != null && status) {
        transaction = TransactionDetail.fromJson(dataMap);
      }

      return TransactionDetailResponse(
        status: status,
        message: message,
        data: transaction,
      );
    } catch (e) {
      return TransactionDetailResponse(
        status: false,
        message: 'Erro ao buscar transação: $e',
        data: null,
      );
    }
  }

  /// Editar uma transação existente do usuário autenticado
  /// 
  /// Parâmetros:
  /// - [transactionId]: ID da transação a ser editada (obrigatório)
  /// - [value]: Valor da transação (obrigatório, deve ser > 0)
  /// - [categoryId]: ID da categoria (obrigatório)
  /// - [bankAccountId]: ID da conta bancária (obrigatório)
  /// - [date]: Data da transação (obrigatório)
  /// - [type]: Tipo da transação - 'revenue' ou 'expense' (obrigatório)
  /// - [description]: Descrição da transação (opcional)
  /// 
  /// Retorna TransactionEditResponse com status, message e data
  Future<TransactionEditResponse> editTransaction({
    required String transactionId,
    required double value,
    required String categoryId,
    required String bankAccountId,
    required DateTime date,
    required String type,
    String? description,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return TransactionEditResponse(
          status: false,
          message: 'Usuário não autenticado',
          data: null,
        );
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      // Validações
      if (transactionId.trim().isEmpty) {
        return TransactionEditResponse(
          status: false,
          message: 'O ID da transação é obrigatório',
          data: null,
        );
      }

      if (value <= 0) {
        return TransactionEditResponse(
          status: false,
          message: 'O valor deve ser maior que zero',
          data: null,
        );
      }

      if (type != 'income' && type != 'expense' && type != 'revenue') {
        return TransactionEditResponse(
          status: false,
          message: 'O tipo deve ser "income", "revenue" ou "expense"',
          data: null,
        );
      }

      if (categoryId.trim().isEmpty) {
        return TransactionEditResponse(
          status: false,
          message: 'O ID da categoria é obrigatório',
          data: null,
        );
      }

      if (bankAccountId.trim().isEmpty) {
        return TransactionEditResponse(
          status: false,
          message: 'O ID da conta bancária é obrigatório',
          data: null,
        );
      }

      // Converter 'income' para 'revenue' se necessário (a API espera 'revenue' para receita)
      final apiType = type == 'income' ? 'revenue' : type;

      // Preparar parâmetros
      final params = <String, dynamic>{
        'p_transaction_id': transactionId.trim(),
        'p_value': value,
        'p_category_id': categoryId.trim(),
        'p_bank_account_id': bankAccountId.trim(),
        'p_date': date.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
        'p_type': apiType,
      };

      if (description != null && description.trim().isNotEmpty) {
        params['p_description'] = description.trim();
      }

      // Chamar a função RPC
      final response = await _supabase.rpc(
        'post_edit_transaction',
        params: params,
      );

      if (response == null) {
        return TransactionEditResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          data: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message = responseMap['message'] as String? ?? 'Erro ao editar transação';
      final dataMap = responseMap['data'] as Map<String, dynamic>?;

      TransactionDetail? transaction;
      if (dataMap != null && status) {
        transaction = TransactionDetail.fromJson(dataMap);
      }

      return TransactionEditResponse(
        status: status,
        message: message,
        data: transaction,
      );
    } catch (e) {
      return TransactionEditResponse(
        status: false,
        message: 'Erro ao editar transação: $e',
        data: null,
      );
    }
  }

  /// Excluir uma transação existente do usuário autenticado
  /// 
  /// Parâmetros:
  /// - [transactionId]: ID da transação a ser excluída (obrigatório)
  /// 
  /// Retorna TransactionDeleteResponse com status e message
  Future<TransactionDeleteResponse> deleteTransaction({
    required String transactionId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return TransactionDeleteResponse(
          status: false,
          message: 'Usuário não autenticado',
        );
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {}

      // Validações
      if (transactionId.trim().isEmpty) {
        return TransactionDeleteResponse(
          status: false,
          message: 'O ID da transação é obrigatório',
        );
      }

      // Chamar a função RPC
      final response = await _supabase.rpc(
        'delete_transaction',
        params: {
          'p_transaction_id': transactionId.trim(),
        },
      );

      if (response == null) {
        return TransactionDeleteResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final status = responseMap['status'] as bool? ?? false;
      final message = responseMap['message'] as String? ?? 'Erro ao excluir transação';

      return TransactionDeleteResponse(
        status: status,
        message: message,
      );
    } catch (e) {
      return TransactionDeleteResponse(
        status: false,
        message: 'Erro ao excluir transação: $e',
      );
    }
  }
}

class TransactionCreateResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  TransactionCreateResponse({
    required this.status,
    required this.message,
    required this.data,
  });
}

class TransactionListResponse {
  final bool status;
  final String message;
  final List<TransactionWithCategory> transactions;
  final TransactionPagination? pagination;

  const TransactionListResponse({
    required this.status,
    required this.message,
    required this.transactions,
    required this.pagination,
  });
}

class TransactionPagination {
  final int totalItems;
  final int totalPages;
  final int currentPage;

  TransactionPagination({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory TransactionPagination.fromJson(Map<String, dynamic> json) {
    return TransactionPagination(
      totalItems: json['total_items'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
    );
  }
}

class TransactionDetailResponse {
  final bool status;
  final String message;
  final TransactionDetail? data;

  TransactionDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });
}

class TransactionEditResponse {
  final bool status;
  final String message;
  final TransactionDetail? data;

  TransactionEditResponse({
    required this.status,
    required this.message,
    required this.data,
  });
}

class TransactionDeleteResponse {
  final bool status;
  final String message;

  TransactionDeleteResponse({
    required this.status,
    required this.message,
  });
}

