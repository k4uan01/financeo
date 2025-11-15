import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Getter para acessar o client
  SupabaseClient get client => _client;

  // Método para verificar se o usuário está autenticado
  bool isUserLoggedIn() {
    return _client.auth.currentUser != null;
  }

  // Método para obter o usuário atual
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Exemplo: Método para buscar transações
  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .order('date', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar transações: $e');
      }
      return [];
    }
  }

  // Exemplo: Método para adicionar uma transação
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
  }) async {
    try {
      await _client.from('transactions').insert({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'is_income': isIncome,
        'user_id': _client.auth.currentUser?.id,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar transação: $e');
      }
      return false;
    }
  }

  // Exemplo: Método para deletar uma transação
  Future<bool> deleteTransaction(int id) async {
    try {
      await _client.from('transactions').delete().eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar transação: $e');
      }
      return false;
    }
  }

  // Exemplo: Método para atualizar uma transação
  Future<bool> updateTransaction({
    required int id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isIncome,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (amount != null) updates['amount'] = amount;
      if (category != null) updates['category'] = category;
      if (date != null) updates['date'] = date.toIso8601String();
      if (isIncome != null) updates['is_income'] = isIncome;

      await _client.from('transactions').update(updates).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar transação: $e');
      }
      return false;
    }
  }

  // Método para fazer login
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Método para fazer cadastro
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  // Método para fazer logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
