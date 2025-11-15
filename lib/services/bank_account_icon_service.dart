import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bank_account_icon_model.dart';

class BankAccountIconService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Buscar ícones de contas bancárias
  ///
  /// Parâmetros:
  /// - [type]: Tipo de ícone ("generic" ou "banking institution")
  /// - [itemsPerPage]: Quantidade de itens por página (padrão: 100 para carregar todos de uma vez)
  /// - [currentPage]: Página atual (padrão: 1)
  /// - [search]: Termo de busca (opcional)
  ///
  /// Retorna BankAccountIconsResponse com status, message, data e pagination
  Future<BankAccountIconsResponse> getIcons({
    String? type,
    int itemsPerPage = 100,
    int currentPage = 1,
    String? search,
  }) async {
    try {
      // Verificar se o usuário está autenticado
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return BankAccountIconsResponse(
          status: false,
          message: 'Usuário não autenticado',
          data: [],
        );
      }

      // Fazer requisição para a API RPC
      final response = await _supabase.rpc(
        'get_bank_account_icons',
        params: {
          'p_items_page': itemsPerPage,
          'p_current_page': currentPage,
          'p_search': search,
          'p_type': type,
        },
      );

      // Processar resposta
      if (response != null) {
        return BankAccountIconsResponse.fromJson(
          response as Map<String, dynamic>,
        );
      }

      return BankAccountIconsResponse(
        status: false,
        message: 'Erro ao processar resposta da API',
        data: [],
      );
    } catch (e) {
      return BankAccountIconsResponse(
        status: false,
        message: 'Erro ao buscar ícones: $e',
        data: [],
      );
    }
  }

  /// Buscar ícones genéricos
  Future<BankAccountIconsResponse> getGenericIcons({
    String? search,
    int itemsPerPage = 100,
  }) async {
    return getIcons(
      type: 'generic',
      search: search,
      itemsPerPage: itemsPerPage,
    );
  }

  /// Buscar ícones de instituições bancárias
  Future<BankAccountIconsResponse> getBankingInstitutionIcons({
    String? search,
    int itemsPerPage = 100,
  }) async {
    return getIcons(
      type: 'banking institution',
      search: search,
      itemsPerPage: itemsPerPage,
    );
  }

  /// Buscar todos os ícones (sem filtro de tipo)
  Future<BankAccountIconsResponse> getAllIcons({
    String? search,
    int itemsPerPage = 100,
  }) async {
    return getIcons(search: search, itemsPerPage: itemsPerPage);
  }
}
