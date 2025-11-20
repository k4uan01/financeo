import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/metric_model.dart';

class MetricService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Buscar métricas agregadas de transações por categoria
  ///
  /// Parâmetros:
  /// - [startDate]: Data inicial do período (obrigatório)
  /// - [endDate]: Data final do período (obrigatório)
  /// - [type]: Tipo de transação - 'income' ou 'expense' (obrigatório)
  ///
  /// Retorna MetricResponse com status, message e data
  Future<MetricResponse> getMetrics({
    required DateTime startDate,
    required DateTime endDate,
    required String type,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return MetricResponse(
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
      if (type.trim().isEmpty) {
        return MetricResponse(
          status: false,
          message: 'O tipo de transação é obrigatório',
          data: null,
        );
      }

      final normalizedType = type.trim().toLowerCase();
      if (normalizedType != 'income' && normalizedType != 'expense') {
        return MetricResponse(
          status: false,
          message: 'O tipo deve ser "income" ou "expense"',
          data: null,
        );
      }

      if (startDate.isAfter(endDate)) {
        return MetricResponse(
          status: false,
          message: 'Data inicial deve ser menor ou igual à data final',
          data: null,
        );
      }

      // Preparar parâmetros
      final params = <String, dynamic>{
        'p_start_date': startDate.toIso8601String().split('T')[0],
        'p_end_date': endDate.toIso8601String().split('T')[0],
        'p_type': normalizedType,
      };

      // Chamar a função RPC
      final response = await _supabase.rpc(
        'get_metrics',
        params: params,
      );

      if (response == null) {
        return MetricResponse(
          status: false,
          message: 'Erro ao processar resposta da API: resposta nula',
          data: null,
        );
      }

      // Verificar se a resposta é um Map antes de fazer o cast
      if (response is! Map<String, dynamic>) {
        return MetricResponse(
          status: false,
          message: 'Erro ao processar resposta da API: formato inválido',
          data: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      return MetricResponse.fromJson(responseMap);
    } catch (e) {
      return MetricResponse(
        status: false,
        message: 'Erro ao buscar métricas: $e',
        data: null,
      );
    }
  }
}

