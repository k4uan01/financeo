# 📚 Exemplos de Uso do Supabase no Financeo

Este documento contém exemplos práticos de como usar o Supabase no aplicativo Financeo.

## 📦 Importações Necessárias

```dart
import 'package:financeo/services/supabase_service.dart';
import 'package:financeo/models/transaction_model.dart';
```

## 🔐 Autenticação

### Criar uma Conta

```dart
final supabaseService = SupabaseService();

try {
  final response = await supabaseService.signUpWithEmail(
    email: 'usuario@exemplo.com',
    password: 'senha_segura_123',
  );
  
  if (response.user != null) {
    print('Conta criada com sucesso!');
    print('User ID: ${response.user!.id}');
  }
} catch (e) {
  print('Erro ao criar conta: $e');
}
```

### Fazer Login

```dart
final supabaseService = SupabaseService();

try {
  final response = await supabaseService.signInWithEmail(
    email: 'usuario@exemplo.com',
    password: 'senha_segura_123',
  );
  
  if (response.user != null) {
    print('Login realizado com sucesso!');
    print('User ID: ${response.user!.id}');
  }
} catch (e) {
  print('Erro ao fazer login: $e');
}
```

### Verificar se o Usuário Está Logado

```dart
final supabaseService = SupabaseService();

if (supabaseService.isUserLoggedIn()) {
  final user = supabaseService.getCurrentUser();
  print('Usuário logado: ${user?.email}');
} else {
  print('Nenhum usuário logado');
}
```

### Fazer Logout

```dart
final supabaseService = SupabaseService();

try {
  await supabaseService.signOut();
  print('Logout realizado com sucesso!');
} catch (e) {
  print('Erro ao fazer logout: $e');
}
```

## 💰 Gerenciamento de Transações

### Buscar Todas as Transações

```dart
final supabaseService = SupabaseService();

try {
  final transactionsData = await supabaseService.getTransactions();
  
  // Converter para lista de TransactionModel
  final transactions = transactionsData.map((data) {
    return TransactionModel.fromJson(data);
  }).toList();
  
  print('Total de transações: ${transactions.length}');
  
  for (var transaction in transactions) {
    print('${transaction.title}: R\$ ${transaction.amount}');
  }
} catch (e) {
  print('Erro ao buscar transações: $e');
}
```

### Adicionar uma Nova Transação (Receita)

```dart
final supabaseService = SupabaseService();

try {
  final success = await supabaseService.addTransaction(
    title: 'Salário de Janeiro',
    amount: 5000.00,
    category: 'Trabalho',
    date: DateTime.now(),
    isIncome: true,
  );
  
  if (success) {
    print('Receita adicionada com sucesso!');
  } else {
    print('Falha ao adicionar receita');
  }
} catch (e) {
  print('Erro ao adicionar receita: $e');
}
```

### Adicionar uma Nova Transação (Despesa)

```dart
final supabaseService = SupabaseService();

try {
  final success = await supabaseService.addTransaction(
    title: 'Conta de Luz',
    amount: 150.00,
    category: 'Contas',
    date: DateTime.now(),
    isIncome: false,
  );
  
  if (success) {
    print('Despesa adicionada com sucesso!');
  } else {
    print('Falha ao adicionar despesa');
  }
} catch (e) {
  print('Erro ao adicionar despesa: $e');
}
```

### Atualizar uma Transação

```dart
final supabaseService = SupabaseService();

try {
  final success = await supabaseService.updateTransaction(
    id: 1,
    title: 'Salário de Janeiro (Atualizado)',
    amount: 5500.00,
  );
  
  if (success) {
    print('Transação atualizada com sucesso!');
  } else {
    print('Falha ao atualizar transação');
  }
} catch (e) {
  print('Erro ao atualizar transação: $e');
}
```

### Deletar uma Transação

```dart
final supabaseService = SupabaseService();

try {
  final success = await supabaseService.deleteTransaction(1);
  
  if (success) {
    print('Transação deletada com sucesso!');
  } else {
    print('Falha ao deletar transação');
  }
} catch (e) {
  print('Erro ao deletar transação: $e');
}
```

## 🎯 Exemplo Completo: Widget com Transações

```dart
import 'package:flutter/material.dart';
import 'package:financeo/services/SupabaseService.dart';
import 'package:financeo/models/TransactionModel.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactionsData = await _supabaseService.getTransactions();
      
      setState(() {
        _transactions = transactionsData.map((data) {
          return TransactionModel.fromJson(data);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTransaction() async {
    final success = await _supabaseService.addTransaction(
      title: 'Nova Transação',
      amount: 100.00,
      category: 'Outros',
      date: DateTime.now(),
      isIncome: true,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação adicionada!')),
      );
      _loadTransactions(); // Recarregar lista
    }
  }

  Future<void> _deleteTransaction(int id) async {
    final success = await _supabaseService.deleteTransaction(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação deletada!')),
      );
      _loadTransactions(); // Recarregar lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Nenhuma transação encontrada'))
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return ListTile(
                      title: Text(transaction.title),
                      subtitle: Text(transaction.category),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'R\$ ${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: transaction.isIncome
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (transaction.id != null) {
                                _deleteTransaction(transaction.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## 📊 Calcular Estatísticas

```dart
Future<Map<String, double>> getFinancialStats() async {
  final supabaseService = SupabaseService();
  
  try {
    final transactionsData = await supabaseService.getTransactions();
    
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    
    for (var data in transactionsData) {
      final transaction = TransactionModel.fromJson(data);
      
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  } catch (e) {
    print('Erro ao calcular estatísticas: $e');
    return {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
  }
}

// Uso:
final stats = await getFinancialStats();
print('Receitas: R\$ ${stats['income']}');
print('Despesas: R\$ ${stats['expense']}');
print('Saldo: R\$ ${stats['balance']}');
```

## 🔄 Realtime (Sincronização em Tempo Real)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Escutar mudanças na tabela de transações
void listenToTransactions() {
  final supabase = Supabase.instance.client;
  
  supabase
      .from('transactions')
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> data) {
        print('Transações atualizadas em tempo real!');
        
        final transactions = data.map((item) {
          return TransactionModel.fromJson(item);
        }).toList();
        
        // Atualizar UI ou estado
        print('Total de transações: ${transactions.length}');
      });
}
```

## 🎨 Integração com StatefulWidget

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabaseService = SupabaseService();
  
  Future<void> _handleAddTransaction() async {
    final success = await _supabaseService.addTransaction(
      title: 'Exemplo',
      amount: 100.00,
      category: 'Teste',
      date: DateTime.now(),
      isIncome: true,
    );
    
    if (success && mounted) {
      setState(() {
        // Atualizar estado
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Widget tree...
    );
  }
}
```

## 💡 Dicas e Boas Práticas

1. **Sempre use try-catch**: Operações de banco de dados podem falhar
2. **Verifique mounted**: Antes de chamar setState após operações assíncronas
3. **Use loading states**: Mostre indicadores de carregamento durante operações
4. **Valide dados**: Antes de enviar ao Supabase
5. **Trate erros**: Mostre mensagens amigáveis ao usuário
6. **Use const**: Para widgets que não mudam
7. **Separe lógica de UI**: Use services e models

## 🆘 Tratamento de Erros

```dart
Future<void> safeAddTransaction() async {
  final supabaseService = SupabaseService();
  
  try {
    final success = await supabaseService.addTransaction(
      title: 'Teste',
      amount: 100.00,
      category: 'Outros',
      date: DateTime.now(),
      isIncome: true,
    );
    
    if (success) {
      print('✅ Transação adicionada');
    } else {
      print('❌ Falha ao adicionar transação');
    }
  } on PostgrestException catch (error) {
    print('Erro do Supabase: ${error.message}');
  } on AuthException catch (error) {
    print('Erro de autenticação: ${error.message}');
  } catch (error) {
    print('Erro desconhecido: $error');
  }
}
```

---

**Nota**: Certifique-se de que o usuário está autenticado antes de realizar operações no banco de dados!

