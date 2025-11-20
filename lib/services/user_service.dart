import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'user_cache_service.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UserCacheService _cacheService = UserCacheService();

  /// Buscar informações do usuário logado
  /// 
  /// Retorna GetUserResponse com status, message e user
  /// Usa cache local se disponível e válido
  Future<GetUserResponse> getUser({bool forceRefresh = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        // Limpar cache se não houver usuário logado
        await _cacheService.clearCache();
        return GetUserResponse(
          status: false,
          message: 'Usuário não autenticado',
          user: null,
        );
      }

      // Verificar cache primeiro (se não for refresh forçado)
      if (!forceRefresh) {
        final cachedUser = await _cacheService.getUser();
        final isCacheValid = await _cacheService.isCacheValid();
        final isCacheForCurrentUser = await _cacheService.isCacheForCurrentUser(user.id);
        
        if (cachedUser != null && isCacheValid && isCacheForCurrentUser) {
          return GetUserResponse(
            status: true,
            message: 'Usuário carregado do cache',
            user: cachedUser,
          );
        }
      }

      // Tentar renovar a sessão
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {
        // Ignorar erro de refresh se já estiver válida
      }

      // Chamar a função RPC get_user
      final response = await _supabase.rpc('get_user');

      if (response == null) {
        // Se a API falhar, tentar usar cache mesmo que inválido
        final cachedUser = await _cacheService.getUser();
        if (cachedUser != null) {
          return GetUserResponse(
            status: true,
            message: 'Usuário carregado do cache (offline)',
            user: cachedUser,
          );
        }
        
        return GetUserResponse(
          status: false,
          message: 'Erro ao processar resposta da API',
          user: null,
        );
      }

      final responseMap = response as Map<String, dynamic>;
      final getUserResponse = GetUserResponse.fromJson(responseMap);
      
      // Salvar no cache se a resposta foi bem-sucedida
      if (getUserResponse.status && getUserResponse.user != null) {
        await _cacheService.saveUser(getUserResponse.user!);
      }
      
      return getUserResponse;
    } catch (e) {
      // Se houver erro, tentar usar cache
      final cachedUser = await _cacheService.getUser();
      if (cachedUser != null) {
        return GetUserResponse(
          status: true,
          message: 'Usuário carregado do cache (erro na API)',
          user: cachedUser,
        );
      }
      
      return GetUserResponse(
        status: false,
        message: 'Erro ao buscar informações do usuário: $e',
        user: null,
      );
    }
  }

  /// Limpar cache do usuário
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  /// Forçar atualização dos dados do usuário
  Future<GetUserResponse> refreshUser() async {
    return getUser(forceRefresh: true);
  }
}

