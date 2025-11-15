# Exemplos de Uso - Módulo BankAccounts

## 📱 Navegação para a Página de Criação

### Exemplo 1: Navegação Simples
```dart
import 'package:flutter/material.dart';
import 'BankAccounts/PagesBankAccounts/CreateBankAccountPage.dart';

// Dentro de um Widget
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBankAccountPage(),
      ),
    );
  },
  child: const Text('Criar Conta'),
)
```

### Exemplo 2: Navegação com Retorno
```dart
import 'package:flutter/material.dart';
import 'BankAccounts/PagesBankAccounts/CreateBankAccountPage.dart';
import 'models/bank_account_model.dart';

Future<void> _navigateToCreateAccount() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateBankAccountPage(),
    ),
  );

  // result será null se o usuário cancelou
  // ou BankAccountModel se a conta foi criada
  if (result != null && result is BankAccountModel) {
    print('Conta criada: ${result.name}');
    print('Saldo: R\$ ${result.balance.toStringAsFixed(2)}');
    
    // Atualizar a lista de contas ou fazer outra ação
    _refreshAccountList();
  }
}
```

### Exemplo 3: Navegação com Feedback
```dart
Future<void> _createNewAccount() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateBankAccountPage(),
    ),
  );

  if (result != null && result is BankAccountModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conta "${result.name}" criada com sucesso!'),
        backgroundColor: const Color(0xFF08BF62),
      ),
    );
  }
}
```

## 🔧 Uso Direto do Serviço

### Exemplo 1: Criar Conta
```dart
import 'services/bank_account_service.dart';

final _bankAccountService = BankAccountService();

Future<void> _createAccount() async {
  final result = await _bankAccountService.createBankAccount(
    name: 'Conta Corrente',
    balance: 1000.00,
  );

  if (result['status'] == true) {
    print('Sucesso: ${result['message']}');
    final account = result['data'] as BankAccountModel;
    print('ID: ${account.id}');
    print('Nome: ${account.name}');
    print('Saldo: R\$ ${account.balance}');
  } else {
    print('Erro: ${result['message']}');
  }
}
```

### Exemplo 2: Listar Contas
```dart
import 'services/bank_account_service.dart';

final _bankAccountService = BankAccountService();

Future<void> _loadAccounts() async {
  try {
    final accounts = await _bankAccountService.listBankAccounts();
    
    print('Total de contas: ${accounts.length}');
    
    for (var account in accounts) {
      print('${account.name}: R\$ ${account.balance.toStringAsFixed(2)}');
    }
  } catch (e) {
    print('Erro ao carregar contas: $e');
  }
}
```

### Exemplo 3: Buscar Conta Específica
```dart
import 'services/bank_account_service.dart';

final _bankAccountService = BankAccountService();

Future<void> _getAccount(String accountId) async {
  try {
    final account = await _bankAccountService.getBankAccount(accountId);
    
    if (account != null) {
      print('Conta encontrada: ${account.name}');
      print('Saldo: R\$ ${account.balance.toStringAsFixed(2)}');
    } else {
      print('Conta não encontrada');
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Exemplo 4: Atualizar Saldo
```dart
import 'services/bank_account_service.dart';

final _bankAccountService = BankAccountService();

Future<void> _updateAccountBalance(String accountId, double newBalance) async {
  try {
    final success = await _bankAccountService.updateBalance(accountId, newBalance);
    
    if (success) {
      print('Saldo atualizado com sucesso!');
    }
  } catch (e) {
    print('Erro ao atualizar saldo: $e');
  }
}
```

### Exemplo 5: Deletar Conta
```dart
import 'services/bank_account_service.dart';

final _bankAccountService = BankAccountService();

Future<void> _deleteAccount(String accountId) async {
  // Mostrar confirmação
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: const Text('Tem certeza que deseja excluir esta conta?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      final result = await _bankAccountService.deleteBankAccount(
        accountId: accountId,
      );

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Conta excluída com sucesso!'),
            backgroundColor: const Color(0xFF08BF62),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erro ao excluir conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir conta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

## 📊 Widget de Lista de Contas

### Exemplo Completo de Lista
```dart
import 'package:flutter/material.dart';
import 'services/bank_account_service.dart';
import 'models/bank_account_model.dart';

class BankAccountListWidget extends StatefulWidget {
  const BankAccountListWidget({super.key});

  @override
  State<BankAccountListWidget> createState() => _BankAccountListWidgetState();
}

class _BankAccountListWidgetState extends State<BankAccountListWidget> {
  final _bankAccountService = BankAccountService();
  List<BankAccountModel> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    
    try {
      final accounts = await _bankAccountService.listBankAccounts();
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar contas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma conta cadastrada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _accounts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final account = _accounts[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF08BF62),
              ),
            ),
            title: Text(
              account.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Criada em ${_formatDate(account.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: Text(
              'R\$ ${account.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF08BF62),
              ),
            ),
            onTap: () {
              // Navegar para detalhes da conta
              print('Conta selecionada: ${account.name}');
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data desconhecida';
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

## 🎨 Card de Resumo de Conta

### Widget Customizado
```dart
import 'package:flutter/material.dart';
import 'models/bank_account_model.dart';

class BankAccountCard extends StatelessWidget {
  final BankAccountModel account;
  final VoidCallback? onTap;

  const BankAccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF08BF62),
                const Color(0xFF08BF62).withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Ativa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                account.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${account.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saldo disponível',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Uso:
BankAccountCard(
  account: myAccount,
  onTap: () {
    print('Conta selecionada: ${myAccount.name}');
  },
)
```

## 🔄 Integração com Estado Global

### Exemplo com Provider (futuro)
```dart
// providers/bank_account_provider.dart
import 'package:flutter/foundation.dart';
import '../services/bank_account_service.dart';
import '../models/bank_account_model.dart';

class BankAccountProvider extends ChangeNotifier {
  final _service = BankAccountService();
  List<BankAccountModel> _accounts = [];
  bool _isLoading = false;

  List<BankAccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;

  double get totalBalance {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accounts = await _service.listBankAccounts();
    } catch (e) {
      print('Erro: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount(String name, double balance) async {
    final result = await _service.createBankAccount(
      name: name,
      balance: balance,
    );

    if (result['status'] == true) {
      await loadAccounts();
      return true;
    }
    return false;
  }
}
```

## 📱 Integração Completa na Aplicação

### Exemplo de Fluxo Completo
```dart
// Na HomePage ou Dashboard
FloatingActionButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBankAccountPage(),
      ),
    );

    if (result != null && result is BankAccountModel) {
      // Atualizar lista
      setState(() {
        // Adicionar conta à lista local
      });
      
      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conta "${result.name}" criada!'),
          backgroundColor: const Color(0xFF08BF62),
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              // Navegar para detalhes
            },
          ),
        ),
      );
    }
  },
  child: const Icon(Icons.add),
)
```

---

## 💡 Dicas de Uso

1. **Sempre verifique o retorno** dos métodos do serviço
2. **Use try-catch** para capturar exceções
3. **Mostre feedback visual** ao usuário (SnackBars, Dialogs)
4. **Valide os dados** antes de enviar
5. **Mantenha o estado** sincronizado após operações
6. **Use loading states** para melhorar UX

## 🎯 Próximos Exemplos

Aguardando implementação das próximas funcionalidades:
- Página de listagem de contas
- Página de edição de conta
- Seleção de ícones
- Transferências entre contas

