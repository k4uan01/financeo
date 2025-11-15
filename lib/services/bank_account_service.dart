import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bank_account_model.dart';
import '../models/bank_account_with_icon.dart';
import '../config/supabase_config.dart';

class BankAccountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Criar uma nova conta bancária
  ///
  /// Parâmetros:
  /// - [name]: Nome da conta bancária
  /// - [balance]: Saldo inicial (padrão: 0)
  /// - [iconId]: ID do ícone (opcional, usa um padrão se não fornecido)
  /// - [iconColor]: Cor do ícone (opcional)
  ///
  /// Retorna um Map com:
  /// - status: bool
  /// - message: String
  /// - data: BankAccountModel? (se sucesso)
  Future<Map<String, dynamic>> createBankAccount({
    required String name,
    double balance = 0,
    String? iconId,
    String? iconColor,
  }) async {
    try {
      // Verificar se o usuário está autenticado
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'status': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        // Ignorar erro de refresh se já estiver válida
      }

      // Validar nome
      if (name.trim().isEmpty) {
        return {
          'status': false,
          'message': 'Nome da conta é obrigatório',
          'data': null,
        };
      }

      // Se iconId não for fornecido, usar um UUID padrão
      // TODO: Buscar um ícone padrão da tabela bank_account_icons
      final finalIconId = iconId ?? '00000000-0000-0000-0000-000000000000';

      // Validar saldo inicial
      if (balance < 0) {
        return {
          'status': false,
          'message': 'Saldo inicial não pode ser negativo',
          'data': null,
        };
      }

      // Obter o token JWT
      final session = _supabase.auth.currentSession;
      final token = session?.accessToken;

      if (token == null) {
        return {
          'status': false,
          'message': 'Token de autenticação não encontrado',
          'data': null,
        };
      }

      // Fazer requisição para a API RPC
      final response = await _supabase.rpc(
        'post_create_bank_account',
        params: {
          'p_name': name.trim(),
          'p_icon_id': finalIconId,
          'p_balance': balance,
          'p_icon_color': iconColor,
        },
      );

      // Processar resposta
      if (response != null) {
        final responseData = response as Map<String, dynamic>;
        final status = responseData['status'] as bool;
        final message = responseData['message'] as String;

        if (status) {
          final accountData = responseData['data'] as Map<String, dynamic>;
          final bankAccount = BankAccountModel.fromJson(accountData);

          return {'status': true, 'message': message, 'data': bankAccount};
        } else {
          return {'status': false, 'message': message, 'data': null};
        }
      }

      return {
        'status': false,
        'message': 'Erro ao processar resposta da API',
        'data': null,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Erro ao criar conta bancária: $e',
        'data': null,
      };
    }
  }

  /// Listar todas as contas bancárias do usuário com ícones
  /// Usa a função RPC get_bank_accounts() que retorna contas com ícones incluídos
  Future<Map<String, dynamic>> listBankAccounts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'status': false,
          'message': 'Usuário não autenticado',
          'data': <BankAccountWithIcon>[],
        };
      }

      // Tentar renovar a sessão se estiver próxima de expirar
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        // Ignorar erro de refresh se já estiver válida
      }

      // Chamar a função RPC get_bank_accounts
      final response = await _supabase.rpc('get_bank_accounts');

      if (response != null) {
        final responseData = response as Map<String, dynamic>;
        final status = responseData['status'] as bool;
        final message = responseData['message'] as String;

        if (status) {
          final dataList = responseData['data'] as List<dynamic>;
          final accounts = dataList
              .map(
                (item) =>
                    BankAccountWithIcon.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          return {'status': true, 'message': message, 'data': accounts};
        } else {
          return {
            'status': false,
            'message': message,
            'data': <BankAccountWithIcon>[],
          };
        }
      }

      return {
        'status': false,
        'message': 'Erro ao processar resposta da API',
        'data': <BankAccountWithIcon>[],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Erro ao listar contas bancárias: $e',
        'data': <BankAccountWithIcon>[],
      };
    }
  }

  /// Obter uma conta bancária específica com ícone
  /// Usa a função RPC get_bank_account() que retorna conta com ícone incluído
  Future<Map<String, dynamic>> getBankAccount(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'status': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        // Ignorar erro de refresh se já estiver válida
      }

      // Chamar a função RPC get_bank_account
      final response = await _supabase.rpc(
        'get_bank_account',
        params: {'p_bank_account_id': id},
      );

      if (response != null) {
        final responseData = response as Map<String, dynamic>;
        final status = responseData['status'] as bool;
        final message = responseData['message'] as String;

        if (status) {
          final accountData = responseData['data'] as Map<String, dynamic>;
          final account = BankAccountWithIcon.fromJson(accountData);

          return {'status': true, 'message': message, 'data': account};
        } else {
          return {'status': false, 'message': message, 'data': null};
        }
      }

      return {
        'status': false,
        'message': 'Erro ao processar resposta da API',
        'data': null,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Erro ao buscar conta bancária: $e',
        'data': null,
      };
    }
  }

  /// Editar uma conta bancária existente
  Future<Map<String, dynamic>> editBankAccount({
    required String accountId,
    String? name,
    double? balance,
    String? iconId,
    String? iconColor,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'status': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        // Ignorar erro de refresh se já estiver válida
      }

      // Chamar a função RPC post_edit_bank_account
      final response = await _supabase.rpc(
        'post_edit_bank_account',
        params: {
          'p_bank_account_id': accountId,
          'p_name': name,
          'p_balance': balance,
          'p_icon_id': iconId,
          'p_icon_color': iconColor,
        },
      );

      if (response != null) {
        final responseData = response as Map<String, dynamic>;
        final status = responseData['status'] as bool;
        final message = responseData['message'] as String;

        if (status) {
          final accountData = responseData['data'] as Map<String, dynamic>;
          final account = BankAccountModel.fromJson(accountData);

          return {'status': true, 'message': message, 'data': account};
        } else {
          return {'status': false, 'message': message, 'data': null};
        }
      }

      return {
        'status': false,
        'message': 'Erro ao processar resposta da API',
        'data': null,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Erro ao editar conta bancária: $e',
        'data': null,
      };
    }
  }

  /// Atualizar saldo de uma conta bancária
  Future<bool> updateBalance(String id, double newBalance) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      await _supabase
          .from('bank_accounts')
          .update({'balance': newBalance})
          .eq('id', id)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar saldo: $e');
    }
  }

  /// Deletar uma conta bancária
  ///
  /// Retorna um Map com:
  /// - status: bool
  /// - message: String
  /// - data: Map<String, dynamic>? (dados da conta excluída)
  Future<Map<String, dynamic>> deleteBankAccount({
    required String accountId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'status': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        // Ignorar erro de refresh se já estiver válida
      }

      // Chamar a função RPC post_delete_bank_account
      final response = await _supabase.rpc(
        'post_delete_bank_account',
        params: {'p_bank_account_id': accountId},
      );

      if (response != null) {
        final responseData = response as Map<String, dynamic>;
        final status = responseData['status'] as bool;
        final message = responseData['message'] as String;

        if (status) {
          return {
            'status': true,
            'message': message,
            'data': responseData['data'] as Map<String, dynamic>?,
          };
        } else {
          return {'status': false, 'message': message, 'data': null};
        }
      }

      return {
        'status': false,
        'message': 'Erro ao processar resposta da API',
        'data': null,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Erro ao deletar conta bancária: $e',
        'data': null,
      };
    }
  }
}
