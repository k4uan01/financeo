import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserCacheService {
  static const String _userKey = 'cached_user_data';
  static const String _lastUpdateKey = 'user_data_last_update';
  static const String _userIdKey = 'cached_user_id';

  /// Salvar dados do usuário no cache local
  Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      
      await prefs.setString(_userKey, userJson);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      await prefs.setString(_userIdKey, user.id);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Buscar dados do usuário do cache local
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null) {
        return null;
      }
      
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Verificar se o cache é válido (menos de 1 hora)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      
      if (lastUpdateStr == null) {
        return false;
      }
      
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      final difference = now.difference(lastUpdate);
      
      // Cache válido por 1 hora
      return difference.inHours < 1;
    } catch (e) {
      return false;
    }
  }

  /// Verificar se o usuário no cache corresponde ao usuário logado
  Future<bool> isCacheForCurrentUser(String currentUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserId = prefs.getString(_userIdKey);
      
      return cachedUserId == currentUserId;
    } catch (e) {
      return false;
    }
  }

  /// Limpar cache do usuário
  Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_lastUpdateKey);
      await prefs.remove(_userIdKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Forçar atualização do cache (marcar como inválido)
  Future<bool> invalidateCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUpdateKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}

