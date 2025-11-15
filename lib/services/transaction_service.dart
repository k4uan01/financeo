import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Criar uma nova transação
  /// 
  /// Parâmetros:
  /// - [title]: Título da transação (obrigatório)
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
    required String title,
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
      if (title.trim().isEmpty) {
        return TransactionCreateResponse(
          status: false,
          message: 'O título é obrigatório',
          data: null,
        );
      }

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
        'p_title': title.trim(),
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

