# Guia da Página de Lista de Contas Bancárias

## ✅ Funcionalidade Implementada

Criada página completa para **visualizar todas as contas bancárias** do usuário com seus ícones, cores e saldos.

## 📁 Arquivos Criados/Atualizados

### Novos Arquivos:

#### 1. `lib/models/bank_account_with_icon.dart`
Modelo para conta bancária com ícone incluído.

**Classes:**
- `BankAccountWithIcon`: Conta completa com ícone
- `IconData`: Dados do ícone (id, image, type)

**Estrutura:**
```dart
{
  "id": "uuid",
  "name": "Minha Carteira",
  "balance": 1000.00,
  "icon": {
    "id": "uuid",
    "image": "<svg>...</svg>" ou "https://...",
    "type": "generic" ou "banking institution"
  },
  "icon_color": "#F44336"
}
```

#### 2. `lib/BankAccounts/PagesBankAccounts/BankAccountsListPage.dart`
Página principal de listagem de contas.

**Funcionalidades:**
- ✅ Lista todas as contas do usuário
- ✅ Mostra ícones SVG (genéricos) e PNG/JPG (bancários)
- ✅ Exibe cores personalizadas de fundo
- ✅ Card de saldo total
- ✅ Pull to refresh
- ✅ Estados: loading, erro, vazio
- ✅ Navegação para criar conta
- ✅ Botão FAB para nova conta

### Arquivos Atualizados:

#### 3. `lib/services/bank_account_service.dart`
Método `listBankAccounts()` atualizado para usar RPC.

**Antes:**
```dart
Future<List<BankAccountModel>> listBankAccounts()
```

**Depois:**
```dart
Future<Map<String, dynamic>> listBankAccounts()
// Retorna: { status, message, data }
```

#### 4. `lib/main.dart`
Navegação do card "Contas Bancárias" atualizada.

**Antes:** Navegava para `CreateBankAccountPage`
**Depois:** Navega para `BankAccountsListPage`

## 🎨 Telas da Página

### 1. Loading State
```
┌─────────────────────────┐
│    Minhas Contas        │
│                         │
│          ⏳             │
│     Carregando...       │
│                         │
└─────────────────────────┘
```

### 2. Empty State
```
┌─────────────────────────┐
│    Minhas Contas        │
│                         │
│         🎯              │
│ Nenhuma conta cadastrada│
│                         │
│ Adicione sua primeira   │
│ conta bancária para     │
│ começar...              │
│                         │
│  [Adicionar Conta]      │
└─────────────────────────┘
```

### 3. Error State
```
┌─────────────────────────┐
│    Minhas Contas        │
│                         │
│         ❌              │
│  Erro ao carregar       │
│  contas                 │
│                         │
│  [Tentar Novamente]     │
└─────────────────────────┘
```

### 4. Lista de Contas
```
┌─────────────────────────┐
│    Minhas Contas        │
├─────────────────────────┤
│ ┌───────────────────┐   │
│ │ 🎯 Saldo Total    │   │
│ │ R$ 5.500,00       │   │
│ │ Total em 3 contas │   │
│ └───────────────────┘   │
│                         │
│ Suas Contas    3 contas │
│                         │
│ ┌───────────────────┐   │
│ │[🔴💰] Carteira    │   │
│ │       Genérica    │   │
│ │       R$ 1.000,00 │   │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │[🏦] Nubank        │   │
│ │     Instituição   │   │
│ │     R$ 3.500,00   │   │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │[🟡💵] Poupança    │   │
│ │       Genérica    │   │
│ │       R$ 1.000,00 │   │
│ └───────────────────┘   │
│                         │
│          [+ Nova]       │
└─────────────────────────┘
```

## 🔌 Integração com API

### Endpoint: `get_bank_accounts()`

**Requisição:**
```dart
await _supabase.rpc('get_bank_accounts')
```

**Resposta de Sucesso:**
```json
{
  "status": true,
  "message": "Contas bancárias recuperadas com sucesso",
  "data": [
    {
      "id": "uuid-1",
      "name": "Carteira",
      "balance": 1000.00,
      "icon": {
        "id": "icon-uuid",
        "image": "<svg>...</svg>",
        "type": "generic"
      },
      "icon_color": "#F44336"
    },
    {
      "id": "uuid-2",
      "name": "Nubank",
      "balance": 3500.00,
      "icon": {
        "id": "icon-uuid",
        "image": "https://logo-nubank.png",
        "type": "banking institution"
      },
      "icon_color": null
    }
  ]
}
```

**Resposta de Erro:**
```json
{
  "status": false,
  "message": "Usuário não autenticado",
  "data": null
}
```

## 🎯 Funcionalidades

### Card de Saldo Total
- ✅ Exibe soma de todas as contas
- ✅ Mostra quantidade de contas
- ✅ Gradiente verde (#08BF62)
- ✅ Ícone de carteira

### Lista de Contas
- ✅ Ordenadas por data de criação (mais recente primeiro)
- ✅ Ícone com cor de fundo (genéricos)
- ✅ Logo sem fundo (bancários)
- ✅ Nome da conta
- ✅ Tipo (genérica/instituição)
- ✅ Saldo formatado

### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: _loadAccounts,
  child: ListView(...),
)
```

### Navegação
- **Card na HomePage** → `BankAccountsListPage`
- **FAB "Nova Conta"** → `CreateBankAccountPage`
- **Após criar** → Recarrega lista automaticamente

## 💡 Estados e Validações

### Loading
- Mostra CircularProgressIndicator
- Bloqueia interação

### Erro
- Mostra ícone de erro
- Mensagem descritiva
- Botão "Tentar Novamente"

### Vazio
- Mostra ícone de carteira
- Mensagem motivacional
- Botão "Adicionar Conta"

### Sucesso
- Lista de contas
- Card de saldo total
- FAB para nova conta

## 🎨 Design

### Cores
- **Primary**: `#08BF62` (verde)
- **Background Card**: Cor selecionada pelo usuário
- **Text**: Adaptado ao tema (dark/light)

### Espaçamentos
- Card margin: 16px
- Card padding: 16-24px
- Icon size: 56x56px
- Icon padding: 12px

### Tipografia
- **Título**: 20px, bold
- **Saldo**: 18px, bold, verde
- **Nome**: 16px, bold
- **Subtítulo**: 12-14px, cinza

## 🚀 Como Usar

### 1. Navegar da HomePage
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BankAccountsListPage(),
  ),
);
```

### 2. Pull to Refresh
- Arraste a lista para baixo
- Lista será recarregada

### 3. Adicionar Nova Conta
- Clique no FAB "Nova Conta"
- Preencha formulário
- Lista atualiza automaticamente

## 📊 Cálculo de Saldo Total

```dart
double get totalBalance {
  return _accounts.fold(0, (sum, account) => sum + account.balance);
}
```

## 🔒 Segurança

- ✅ Requer autenticação
- ✅ Respeita RLS
- ✅ Retorna apenas contas do usuário logado
- ✅ Token JWT validado automaticamente

## 🧪 Testes

### Teste 1: Lista vazia
1. Usuário sem contas cadastradas
2. Ver empty state
3. Clicar em "Adicionar Conta"
4. Criar primeira conta
5. Ver lista com 1 conta

### Teste 2: Múltiplas contas
1. Criar 3 contas diferentes
2. Ver lista com 3 contas
3. Verificar saldo total
4. Verificar ícones e cores

### Teste 3: Pull to refresh
1. Abrir lista
2. Arrastar para baixo
3. Ver animação de loading
4. Lista recarrega

### Teste 4: Erro de rede
1. Desconectar internet
2. Tentar carregar lista
3. Ver error state
4. Reconectar internet
5. Clicar "Tentar Novamente"
6. Ver lista carregar

## 📝 Fluxo Completo

```
HomePage
  ↓ (clica em "Contas Bancárias")
BankAccountsListPage
  ↓ (carrega)
API: get_bank_accounts()
  ↓ (retorna)
Exibe lista com ícones e saldos
  ↓ (clica FAB)
CreateBankAccountPage
  ↓ (cria conta)
API: post_create_bank_account()
  ↓ (sucesso)
Volta para BankAccountsListPage
  ↓ (recarrega)
Lista atualizada com nova conta
```

## 🎯 Próximas Funcionalidades

### Curto Prazo
- [ ] Página de detalhes da conta
- [ ] Editar conta
- [ ] Excluir conta
- [ ] Filtros e busca

### Médio Prazo
- [ ] Histórico de transações por conta
- [ ] Transferências entre contas
- [ ] Gráficos de evolução
- [ ] Exportar dados

### Longo Prazo
- [ ] Categorização de gastos por conta
- [ ] Metas de economia por conta
- [ ] Sincronização com Open Banking
- [ ] Alertas de saldo baixo

---

**Status:** ✅ IMPLEMENTADO E FUNCIONANDO  
**Data:** 06/11/2025

