# Guia de API - BankAccounts

## 🔌 Endpoint de Criação de Conta

### URL Base
```
https://jsycwyuiqqijrcjhlbao.supabase.co/rest/v1/rpc/post_create_bank_account
```

### Método
`POST`

### Autenticação
Bearer Token (JWT) - Obtido através do Supabase Auth

### Headers
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
apikey: {SUPABASE_ANON_KEY}
```

### Parâmetros da Função RPC

```json
{
  "p_name": "string (TEXT)",
  "p_icon_id": "string (UUID)",
  "p_balance": "number (REAL)",
  "p_icon_color": "string (TEXT) | null"
}
```

#### Descrição dos Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição | Padrão |
|-----------|------|-------------|-----------|--------|
| `p_name` | TEXT | Sim | Nome da conta bancária | - |
| `p_icon_id` | UUID | Sim | ID do ícone da conta (referência à tabela `bank_account_icons`) | - |
| `p_balance` | REAL | Não | Saldo inicial da conta | 0 |
| `p_icon_color` | TEXT | Não | Cor do ícone em hexadecimal (ex: "#08BF62") | null |

### Resposta de Sucesso

**Status:** 200 OK

```json
{
  "status": true,
  "message": "Conta bancária criada com sucesso",
  "data": {
    "id": "uuid",
    "name": "string",
    "balance": 0.0,
    "icon_id": "uuid",
    "icon_color": "#08BF62",
    "user_id": "uuid",
    "created_at": "2025-11-06T20:00:00.000Z"
  }
}
```

### Resposta de Erro

**Status:** 200 OK (a função retorna JSON com status false)

```json
{
  "status": false,
  "message": "Mensagem de erro descritiva",
  "data": null
}
```

### Erros Possíveis

| Erro | Mensagem | Causa |
|------|----------|-------|
| Não autenticado | "Usuário não autenticado" | Token JWT inválido ou ausente |
| Nome vazio | "Nome da conta é obrigatório" | Parâmetro `p_name` vazio ou null |
| Ícone inválido | "ID do ícone é obrigatório" | Parâmetro `p_icon_id` vazio ou null |
| Ícone não existe | "Ícone não encontrado" | UUID do ícone não existe na tabela `bank_account_icons` |
| Saldo negativo | "Saldo inicial não pode ser negativo" | Parâmetro `p_balance` menor que 0 |
| Foreign Key | "Ícone ou usuário não encontrado" | Violação de chave estrangeira |
| Genérico | "Erro ao criar conta bancária: {detalhes}" | Outros erros do banco de dados |

## 📋 Exemplo de Uso com cURL

```bash
curl -X POST \
  'https://jsycwyuiqqijrcjhlbao.supabase.co/rest/v1/rpc/post_create_bank_account' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'apikey: YOUR_SUPABASE_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "p_name": "Conta Corrente",
    "p_icon_id": "00000000-0000-0000-0000-000000000000",
    "p_balance": 1000.00,
    "p_icon_color": "#08BF62"
  }'
```

## 🔧 Exemplo de Uso no Flutter (SDK do Supabase)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<String, dynamic>> createBankAccount({
  required String name,
  required String iconId,
  double balance = 0,
  String? iconColor,
}) async {
  try {
    final response = await supabase.rpc(
      'post_create_bank_account',
      params: {
        'p_name': name,
        'p_icon_id': iconId,
        'p_balance': balance,
        'p_icon_color': iconColor,
      },
    );

    return response as Map<String, dynamic>;
  } catch (e) {
    return {
      'status': false,
      'message': 'Erro: $e',
      'data': null,
    };
  }
}

// Uso:
final result = await createBankAccount(
  name: 'Minha Conta',
  iconId: '00000000-0000-0000-0000-000000000000',
  balance: 500.0,
  iconColor: '#08BF62',
);

if (result['status'] == true) {
  print('Sucesso: ${result['message']}');
  print('Conta criada: ${result['data']}');
} else {
  print('Erro: ${result['message']}');
}
```

## 🗄️ Estrutura da Tabela `bank_accounts`

```sql
CREATE TABLE bank_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  balance REAL DEFAULT 0 NOT NULL,
  icon_id UUID REFERENCES bank_account_icons(id),
  icon_color TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);
```

## 🔐 Row Level Security (RLS)

A tabela `bank_accounts` possui políticas RLS que garantem que:
- Usuários só podem ver suas próprias contas
- Usuários só podem criar contas para si mesmos
- Usuários só podem atualizar/deletar suas próprias contas

## 💡 Dicas

1. **Ícones padrão**: Você pode criar uma lista de ícones padrão na tabela `bank_account_icons` e buscar um para usar quando o usuário criar a conta.

2. **Validação de cores**: O campo `icon_color` aceita qualquer string, mas é recomendado validar o formato hexadecimal no frontend (ex: `#RRGGBB`).

3. **Saldo inicial**: Por padrão, o saldo é 0. Se o usuário não informar, a conta será criada com saldo zero.

4. **Token JWT**: O token JWT é obtido automaticamente pelo SDK do Supabase após o login do usuário. Ele é incluído automaticamente em todas as requisições.

5. **Error Handling**: Sempre verifique o campo `status` na resposta para saber se a operação foi bem-sucedida.

## 📚 Próximas Funcionalidades

- [ ] Endpoint para listar contas bancárias
- [ ] Endpoint para atualizar conta bancária
- [ ] Endpoint para deletar conta bancária
- [ ] Endpoint para listar ícones disponíveis
- [ ] Endpoint para buscar saldo total de todas as contas

