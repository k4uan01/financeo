import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import '../main.dart';

/// Provider global para gerenciar o estado do usuário
class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _user != null;

  /// Carregar dados do usuário na inicialização
  Future<void> loadUserOnInit() async {
    // Verificar se há usuário logado
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    await loadUser();
  }

  /// Carregar dados do usuário (usa cache se disponível)
  Future<void> loadUser({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getUser(forceRefresh: forceRefresh);
      
      if (response.status && response.user != null) {
        _user = response.user;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        // Se não conseguir carregar da API, manter o cache se existir
        // (não alterar _user se já tiver dados em cache)
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar usuário: $e';
      // Manter dados do cache se existirem
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Forçar atualização dos dados do usuário
  Future<void> refreshUser() async {
    await loadUser(forceRefresh: true);
  }

  /// Limpar dados do usuário (logout)
  Future<void> clearUser() async {
    await _userService.clearCache();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Atualizar dados do usuário manualmente
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}

