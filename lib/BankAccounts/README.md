# Módulo BankAccounts

Módulo de gerenciamento de contas bancárias do Financeo.

## 📁 Estrutura

```
BankAccounts/
├── PagesBankAccounts/
│   └── CreateBankAccountPage.dart    # Página de criação de conta bancária
├── ComponentsBankAccounts/           # Componentes reutilizáveis (futuros)
└── README.md                         # Este arquivo
```

## 📄 Arquivos Relacionados

- **Modelo**: `lib/models/bank_account_model.dart`
- **Serviço**: `lib/services/bank_account_service.dart`

## 🎯 Funcionalidades

### CreateBankAccountPage
Página para criar uma nova conta bancária.

**Campos:**
- Nome da conta (obrigatório, mínimo 3 caracteres)
- Saldo inicial (obrigatório, não pode ser negativo)

**Validações:**
- Nome não pode estar vazio
- Nome deve ter no mínimo 3 caracteres
- Saldo deve ser um número válido
- Saldo não pode ser negativo

**Como usar:**
```dart
// Navegar para a página de criação
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CreateBankAccountPage(),
  ),
);

// result será null se cancelado, ou BankAccountModel se criado com sucesso
if (result != null && result is BankAccountModel) {
  print('Conta criada: ${result.name}');
}
```

## 🔧 Serviço BankAccountService

### Métodos disponíveis:

#### `createBankAccount()`
Cria uma nova conta bancária.

**Parâmetros:**
- `name` (String): Nome da conta
- `balance` (double): Saldo inicial (padrão: 0)
- `iconId` (String?): ID do ícone (opcional)
- `iconColor` (String?): Cor do ícone (opcional)

**Retorno:**
```dart
{
  'status': bool,
  'message': String,
  'data': BankAccountModel? // se sucesso
}
```

#### `listBankAccounts()`
Lista todas as contas bancárias do usuário.

**Retorno:** `List<BankAccountModel>`

#### `getBankAccount(String id)`
Obtém uma conta bancária específica.

**Retorno:** `BankAccountModel?`

#### `updateBalance(String id, double newBalance)`
Atualiza o saldo de uma conta.

**Retorno:** `bool`

#### `deleteBankAccount({ required String accountId })`
Deleta uma conta bancária utilizando a função RPC `post_delete_bank_account`.

**Retorno:** `Map<String, dynamic>`

## 🎨 Design

- Segue o padrão de design do Financeo
- Cor principal: `#08BF62`
- Suporta Dark Mode e Light Mode
- Interface responsiva para mobile
- Usa componentes reutilizáveis: `CustomTextField` e `PrimaryButton`

## 🔐 Autenticação

Todas as operações requerem que o usuário esteja autenticado.
O serviço valida automaticamente se o usuário tem sessão ativa.

## 📡 API

A criação de contas utiliza a função RPC do Supabase:
- **Função**: `post_create_bank_account`
- **Endpoint**: `/rest/v1/rpc/post_create_bank_account`
- **Método**: POST
- **Autenticação**: Bearer Token (JWT)

## 🚀 Próximos Passos

- [ ] Criar página de listagem de contas
- [ ] Criar página de edição de conta
- [ ] Adicionar seleção de ícones
- [ ] Adicionar seleção de cores
- [ ] Implementar filtros e busca
- [ ] Adicionar gráficos de saldo

