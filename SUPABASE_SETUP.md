# 🚀 Guia de Configuração do Supabase

Este guia irá ajudá-lo a configurar o Supabase para o projeto Financeo.

## 📋 Informações de Conexão

- **URL do Projeto**: https://jsycwyuiqqijrcjhlbao.supabase.co
- **Anon Key**: Já configurada em `lib/config/SupabaseConfig.dart`

## 🔧 Passo a Passo de Configuração

### 1. Acessar o Dashboard do Supabase

1. Acesse: https://app.supabase.com
2. Faça login na sua conta
3. Selecione o projeto: **jsycwyuiqqijrcjhlbao**

### 2. Criar a Tabela de Transações

1. No menu lateral, clique em **SQL Editor**
2. Clique em **New Query**
3. Copie e cole o conteúdo do arquivo `supabase_schema.sql`
4. Clique em **Run** (ou pressione Ctrl+Enter)
5. Aguarde a confirmação de que o SQL foi executado com sucesso

### 3. Verificar a Tabela Criada

1. No menu lateral, clique em **Table Editor**
2. Você deverá ver a tabela `transactions` listada
3. A tabela possui os seguintes campos:
   - `id` - Identificador único (BIGSERIAL)
   - `user_id` - ID do usuário (UUID)
   - `title` - Título da transação (TEXT)
   - `amount` - Valor da transação (DECIMAL)
   - `category` - Categoria (TEXT)
   - `date` - Data da transação (TIMESTAMPTZ)
   - `is_income` - Se é receita ou despesa (BOOLEAN)
   - `created_at` - Data de criação (TIMESTAMPTZ)
   - `updated_at` - Data de atualização (TIMESTAMPTZ)

### 4. Configurar Autenticação (Opcional)

Se você deseja usar autenticação:

1. No menu lateral, clique em **Authentication**
2. Clique em **Policies**
3. As políticas RLS já foram criadas pelo script SQL
4. Configure os provedores de autenticação desejados:
   - Email/Password (recomendado)
   - Google
   - GitHub
   - Etc.

#### Habilitar Autenticação por Email

1. Vá em **Authentication** > **Providers**
2. Certifique-se de que **Email** está habilitado
3. Configure as opções conforme necessário

### 5. Testar a Conexão

Execute o aplicativo Flutter:

```bash
flutter run
```

O aplicativo agora está conectado ao Supabase!

## 📊 Estrutura do Banco de Dados

### Tabela: transactions

| Campo        | Tipo         | Descrição                          | Obrigatório |
|--------------|--------------|-------------------------------------|-------------|
| id           | BIGSERIAL    | ID único da transação              | Sim         |
| user_id      | UUID         | ID do usuário (FK para auth.users) | Sim         |
| title        | TEXT         | Título/descrição da transação      | Sim         |
| amount       | DECIMAL(12,2)| Valor da transação                 | Sim         |
| category     | TEXT         | Categoria da transação             | Sim         |
| date         | TIMESTAMPTZ  | Data da transação                  | Sim         |
| is_income    | BOOLEAN      | True para receita, False para gasto| Sim         |
| created_at   | TIMESTAMPTZ  | Data de criação do registro        | Auto        |
| updated_at   | TIMESTAMPTZ  | Data da última atualização         | Auto        |

### Índices

- `idx_transactions_user_id` - Para consultas por usuário
- `idx_transactions_date` - Para consultas ordenadas por data

### Políticas de Segurança (RLS)

As seguintes políticas estão ativas:

- ✅ **SELECT**: Usuários só podem ver suas próprias transações
- ✅ **INSERT**: Usuários só podem criar transações para si mesmos
- ✅ **UPDATE**: Usuários só podem atualizar suas próprias transações
- ✅ **DELETE**: Usuários só podem deletar suas próprias transações

## 🔐 Segurança

### Row Level Security (RLS)

O RLS está **habilitado** na tabela `transactions`. Isso significa que:

- Cada usuário só pode acessar seus próprios dados
- As consultas são automaticamente filtradas pelo `user_id`
- Não é possível acessar dados de outros usuários

### Boas Práticas

1. **Nunca** compartilhe sua `service_role_key` publicamente
2. Use apenas a `anon_key` no aplicativo (já configurada)
3. Sempre mantenha o RLS habilitado em produção
4. Teste as políticas antes de liberar para produção

## 📝 Exemplos de Uso

### Inserir uma Transação

```dart
final supabaseService = SupabaseService();

await supabaseService.addTransaction(
  title: 'Salário',
  amount: 5000.00,
  category: 'Trabalho',
  date: DateTime.now(),
  isIncome: true,
);
```

### Buscar Transações

```dart
final supabaseService = SupabaseService();
final transactions = await supabaseService.getTransactions();
```

### Atualizar uma Transação

```dart
final supabaseService = SupabaseService();

await supabaseService.updateTransaction(
  id: 1,
  title: 'Novo título',
  amount: 5500.00,
);
```

### Deletar uma Transação

```dart
final supabaseService = SupabaseService();
await supabaseService.deleteTransaction(1);
```

## 🆘 Solução de Problemas

### Erro: "Row Level Security policy violation"

**Causa**: O usuário não está autenticado ou está tentando acessar dados de outro usuário.

**Solução**: 
1. Certifique-se de que o usuário está autenticado
2. Verifique se o `user_id` na transação corresponde ao usuário logado

### Erro: "relation 'transactions' does not exist"

**Causa**: A tabela não foi criada no banco de dados.

**Solução**: Execute o script SQL em `supabase_schema.sql` no SQL Editor.

### Erro de Conexão

**Causa**: URL ou Anon Key incorretos.

**Solução**: 
1. Verifique as credenciais em `lib/config/SupabaseConfig.dart`
2. Certifique-se de que o projeto está ativo no Supabase

## 📚 Recursos Adicionais

- [Documentação Oficial do Supabase](https://supabase.com/docs)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)

## 🎯 Próximos Passos

1. ✅ Configurar banco de dados
2. ⬜ Implementar autenticação no app
3. ⬜ Integrar CRUD de transações
4. ⬜ Adicionar Realtime para sincronização
5. ⬜ Implementar gráficos e relatórios

---

**Dica**: Mantenha este arquivo atualizado conforme você adiciona novas funcionalidades ao projeto!

