# Guia da Página de Edição de Conta Bancária

## ✅ Funcionalidade Implementada

Criada página completa para **editar contas bancárias** existentes, baseada na página de criação com carregamento automático dos dados atuais.

## 📁 Arquivos Criados/Atualizados

### Novo Arquivo:
- **`EditBankAccountPage.dart`** - Página de edição de conta

### Arquivos Atualizados:
- **`bank_account_service.dart`** - Métodos `getBankAccount()` e `editBankAccount()`
- **`BankAccountsListPage.dart`** - Navegação para edição ao clicar na conta

## 🎯 Funcionalidades

### Carregamento de Dados
- ✅ Carrega dados da conta via API `get_bank_account()`
- ✅ Preenche automaticamente todos os campos
- ✅ Exibe loading durante carregamento
- ✅ Trata erros de carregamento

### Campos Editáveis
- ✅ **Nome** da conta
- ✅ **Ícone** (com seletor igual à criação)
- ✅ **Cor** do ícone (para genéricos)
- ✅ **Saldo** da conta

### Validações
- ✅ Nome obrigatório (min. 3 caracteres)
- ✅ Ícone obrigatório
- ✅ Cor obrigatória (para ícones genéricos)
- ✅ Saldo obrigatório e não negativo
- ✅ Detecta se houve alterações

### Otimizações
- ✅ Envia apenas campos alterados para a API
- ✅ Compara valores originais vs novos
- ✅ Avisa se não houver alterações
- ✅ Atualiza lista automaticamente após salvar

## 🔌 APIs Utilizadas

### 1. `get_bank_account(p_bank_account_id)`

**Requisição:**
```dart
await _supabase.rpc('get_bank_account', params: {
  'p_bank_account_id': accountId,
});
```

**Resposta:**
```json
{
  "status": true,
  "message": "Conta bancária recuperada com sucesso",
  "data": {
    "id": "uuid",
    "name": "Carteira",
    "balance": 1000.00,
    "icon": {
      "id": "icon-uuid",
      "image": "<svg>...</svg>",
      "type": "generic"
    },
    "icon_color": "#F44336",
    "created_at": "2025-11-06T..."
  }
}
```

### 2. `post_edit_bank_account(...)`

**Requisição:**
```dart
await _supabase.rpc('post_edit_bank_account', params: {
  'p_bank_account_id': accountId,
  'p_name': name,           // null se não mudou
  'p_balance': balance,     // null se não mudou
  'p_icon_id': iconId,      // null se não mudou
  'p_icon_color': color,    // null se não mudou
});
```

**Resposta:**
```json
{
  "status": true,
  "message": "Conta bancária atualizada com sucesso",
  "data": {
    "id": "uuid",
    "name": "Carteira Atualizada",
    "balance": 1500.00,
    "icon_id": "uuid",
    "icon_color": "#2196F3",
    "user_id": "uuid",
    "created_at": "2025-11-06T..."
  }
}
```

## 🎨 Layout

```
┌──────────────────────────┐
│   ← Editar Conta         │
├──────────────────────────┤
│      ✏️ (ícone edit)     │
│                          │
│  Editar conta bancária   │
│  Atualize as informações │
│                          │
│  ┌────────────────────┐  │
│  │ Nome: Carteira     │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ [🔴💰] Ícone      →│  │
│  │    Ícone genérico  │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ Saldo: 1000.00     │  │
│  └────────────────────┘  │
│                          │
│  [Salvar Alterações]     │
│  [Cancelar]              │
└──────────────────────────┘
```

## 📊 Fluxo Completo

```
BankAccountsListPage
  ↓ (clica na conta)
EditBankAccountPage
  ↓ (carrega)
API: get_bank_account(id)
  ↓ (preenche campos)
Usuário edita campos
  ↓ (clica Salvar)
Valida alterações
  ↓ (envia apenas campos alterados)
API: post_edit_bank_account(...)
  ↓ (sucesso)
Volta para lista
  ↓ (recarrega)
Lista atualizada
```

## 🔍 Detecção de Alterações

A página compara valores originais vs atuais:

```dart
final nameChanged = name != _originalName;
final balanceChanged = balance != _originalBalance;
final iconChanged = iconId != _originalIconId;
final colorChanged = color != _originalIconColor;

// Envia apenas se houver alterações
if (!anyChanged) {
  showMessage('Nenhuma alteração foi feita');
  return;
}
```

## 🚀 Como Usar

### 1. Da Lista de Contas
```dart
// Clique em qualquer conta da lista
// Abre automaticamente a página de edição
```

### 2. Programaticamente
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditBankAccountPage(
      accountId: 'uuid-da-conta',
    ),
  ),
);
```

## ✅ Estados

### Loading
- Mostra CircularProgressIndicator
- Carrega dados da conta

### Loaded
- Campos preenchidos
- Pronto para edição

### Saving
- Botão com loading
- Desabilita interações

### Error
- Mostra SnackBar de erro
- Volta para lista (se erro no carregamento)

## 🎯 Validações Implementadas

### Nome
- ❌ Vazio
- ❌ Menos de 3 caracteres
- ✅ Mínimo 3 caracteres

### Ícone
- ❌ Não selecionado
- ✅ Selecionado (genérico ou bancário)

### Cor
- ❌ Não selecionada (para genéricos)
- ✅ Selecionada (para genéricos)
- ✅ Não obrigatória (para bancários)

### Saldo
- ❌ Vazio
- ❌ Negativo
- ❌ Texto inválido
- ✅ Número válido >= 0

## 💡 Diferenças da Página de Criação

| Aspecto | Criar | Editar |
|---------|-------|--------|
| **Título** | "Nova Conta Bancária" | "Editar Conta" |
| **Ícone** | 🎯 (wallet) | ✏️ (edit) |
| **Campos** | Vazios | Preenchidos |
| **Loading** | Não | Sim (carregamento) |
| **Botão** | "Criar Conta" | "Salvar Alterações" |
| **API** | `post_create_bank_account` | `post_edit_bank_account` |
| **Retorno** | `BankAccountModel` | `true` (sucesso) |
| **Otimização** | Envia todos | Envia apenas alterados |

## 🧪 Como Testar

### Teste 1: Editar Nome
1. Abrir lista de contas
2. Clicar em uma conta
3. Mudar o nome
4. Salvar
5. Ver mensagem de sucesso
6. Ver nome atualizado na lista

### Teste 2: Mudar Ícone e Cor
1. Abrir edição
2. Clicar em "Selecionar ícone"
3. Escolher outro ícone genérico
4. Escolher outra cor
5. Salvar
6. Ver ícone e cor atualizados

### Teste 3: Atualizar Saldo
1. Abrir edição
2. Mudar saldo
3. Salvar
4. Ver saldo atualizado na lista
5. Ver saldo total recalculado

### Teste 4: Sem Alterações
1. Abrir edição
2. Não mudar nada
3. Clicar em Salvar
4. Ver mensagem "Nenhuma alteração foi feita"

### Teste 5: Validações
1. Tentar salvar nome vazio
2. Tentar salvar saldo negativo
3. Ver mensagens de erro
4. Corrigir e salvar com sucesso

## 📝 Observações

### Performance
- Carrega dados apenas uma vez
- Envia apenas campos alterados
- Recarga automática apenas após sucesso

### UX
- Loading durante carregamento
- Feedback visual claro
- Botões desabilitados durante save
- Mensagens descritivas

### Segurança
- Validação no frontend E backend
- RLS garante acesso apenas ao proprietário
- Campos não alterados não são enviados

---

**Status:** ✅ IMPLEMENTADO E FUNCIONANDO  
**Data:** 06/11/2025

