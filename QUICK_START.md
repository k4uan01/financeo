# 🚀 Guia Rápido - Financeo

## ⚡ Início Rápido (5 minutos)

### 1️⃣ Instalar Dependências
```bash
flutter pub get
```
✅ **Já executado!**

### 2️⃣ Executar o Aplicativo
```bash
# Para Android/iOS
flutter run

# Para Web (Chrome)
flutter run -d chrome

# Para Windows
flutter run -d windows

# Listar dispositivos disponíveis
flutter devices
```

### 3️⃣ Testar Autenticação

**Criar uma nova conta:**
1. Abra o app
2. Clique em "Criar Conta"
3. Preencha os dados:
   - Nome: Seu nome
   - Email: seu@email.com
   - Senha: mínimo 6 caracteres
4. Clique em "Criar Conta"

**Fazer Login:**
1. Use o email e senha criados
2. Clique em "Entrar"
3. Você será redirecionado para a HomePage

**Fazer Logout:**
1. Na HomePage, clique no ícone de perfil (canto superior direito)
2. Clique em "Sair"

## 📱 O que você verá

### Tela de Login
- Logo "FA" verde customizada
- Campos de email e senha
- Toggle para mostrar/ocultar senha
- Link para criar conta

### Tela de Registro
- Logo "FA" verde customizada
- Campos: Nome, Email, Senha, Confirmar Senha
- Validações em tempo real
- Volta para login após criar conta

### Home Page
- **Saldo Total**: Card verde com gradient mostrando saldo
- **Receitas e Despesas**: Resumo em cards brancos
- **Transações Recentes**: Lista com dados de exemplo
  - Salário: +R$ 5.000,00
  - Supermercado: -R$ 350,00
  - Academia: -R$ 150,00
  - Freelance: +R$ 1.200,00
- **Botão Flutuante**: "Nova Transação" (ainda não funcional)
- **Menu de Usuário**: Acesso ao logout

## ⚠️ IMPORTANTE: Configurar Banco de Dados

Atualmente, a HomePage mostra **dados de exemplo** (mock). Para ter dados reais:

### Passo 1: Executar o Schema SQL
1. Acesse: https://app.supabase.com
2. Faça login
3. Selecione o projeto: `jsycwyuiqqijrcjhlbao`
4. Vá para **"SQL Editor"** (menu lateral)
5. Clique em **"New query"**
6. Abra o arquivo `supabase_schema.sql` deste projeto
7. Copie todo o conteúdo
8. Cole no SQL Editor do Supabase
9. Clique em **"Run"** (ou pressione Ctrl+Enter)

### Passo 2: Verificar Tabela Criada
1. No Supabase, vá para **"Table Editor"**
2. Você deve ver a tabela **"transactions"**
3. Clique nela para ver a estrutura:
   - `id` (uuid, primary key)
   - `user_id` (uuid, referência ao usuário)
   - `title` (text)
   - `amount` (numeric)
   - `category` (text)
   - `is_income` (boolean)
   - `date` (timestamp)
   - `created_at` (timestamp)

## 🎨 Temas

O aplicativo suporta dois temas:

### Dark Mode (Padrão)
- Fundo: `#121212`
- Cards: `#1E1E1E`
- Cor principal: `#08BF62`

### Light Mode
Para testar o Light Mode:
1. Seu dispositivo/emulador deve estar em modo claro
2. O app detectará automaticamente

Ou modifique no código (`lib/main.dart`):
```dart
MaterialApp(
  themeMode: ThemeMode.light, // Altere para .light
  // ...
)
```

## 🔧 Comandos Úteis

### Análise de Código
```bash
flutter analyze
```

### Formatação
```bash
flutter format .
```

### Limpar Cache (se tiver problemas)
```bash
flutter clean
flutter pub get
flutter run
```

### Ver Logs
```bash
flutter logs
```

## 📊 Estrutura de Dados

### Transaction (Transação)
```dart
{
  "id": "uuid",
  "user_id": "uuid",
  "title": "Salário",
  "amount": 5000.00,
  "category": "Trabalho",
  "is_income": true,
  "date": "2025-11-05T10:00:00Z",
  "created_at": "2025-11-05T10:00:00Z"
}
```

## 🎯 Próximos Passos

Depois de testar o básico:

1. ⬜ Configurar banco de dados (ver acima)
2. ⬜ Implementar CRUD de transações
3. ⬜ Adicionar filtros e busca
4. ⬜ Implementar gráficos
5. ⬜ Adicionar categorias customizadas

## 🆘 Problemas Comuns

### Erro: "Failed to connect to Supabase"
**Solução**: Verifique se a URL e anonKey estão corretas em `lib/config/supabase_config.dart`

### Erro: "Row Level Security policy violation"
**Solução**: Execute o schema SQL no Supabase. As políticas RLS precisam estar configuradas.

### Erro ao compilar
**Solução**:
```bash
flutter clean
flutter pub get
flutter run
```

### App não abre
**Solução**: Verifique se há um dispositivo/emulador conectado:
```bash
flutter devices
```

## 📞 Suporte

Consulte os arquivos:
- `README.md` - Visão geral
- `PROJECT_STATUS.md` - Status do projeto
- `SUPABASE_SETUP.md` - Setup detalhado do Supabase
- `SETUP_CHECKLIST.md` - Checklist completo

## 🎉 Pronto!

Agora você pode:
- ✅ Criar contas e fazer login
- ✅ Ver a interface do app
- ✅ Navegar pela HomePage
- ✅ Testar o logout

**Próximo passo crítico**: Configure o banco de dados para ter funcionalidades completas!

---

**Desenvolvido com ❤️ usando Flutter**

