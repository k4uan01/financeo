# Sistema de Autenticação - Financeo

## 🔐 Visão Geral

O sistema de autenticação do Financeo foi projetado para gerenciar automaticamente o acesso dos usuários, redirecionando para as páginas apropriadas com base no estado de autenticação.

## 📁 Estrutura

```
Auth/
├── PagesAuth/
│   ├── AuthGatePage.dart    # Gerenciador de rotas de autenticação
│   ├── LoginPage.dart        # Página de login
│   └── SignUpPage.dart       # Página de criar conta
└── ComponentsAuth/
    ├── CustomTextField.dart  # Campo de texto customizado
    ├── PrimaryButton.dart    # Botão principal
    └── LogoutButton.dart     # Botão de logout
```

## 🚀 Como Funciona

### AuthGatePage (Portão de Autenticação)

É a página principal do app que gerencia automaticamente o fluxo de autenticação:

1. **Verifica o estado inicial**
   - Se usuário está logado → mostra a HomePage
   - Se usuário não está logado → mostra a LoginPage

2. **Monitora mudanças em tempo real**
   - Usa `StreamBuilder` com `supabase.auth.onAuthStateChange`
   - Redireciona automaticamente quando o estado muda

3. **Splash Screen**
   - Mostra logo e loading enquanto verifica autenticação
   - Transição suave entre estados

### Fluxo de Autenticação

```
App Inicia
    ↓
AuthGatePage
    ↓
Verifica Sessão
    ├─ Logado → HomePage
    └─ Deslogado → LoginPage
         ↓
    Usuário faz login/signup
         ↓
    AuthGatePage detecta mudança
         ↓
    Redireciona para HomePage
```

### Fluxo de Logout

```
HomePage
    ↓
Usuário clica em "Sair"
    ↓
Confirma ação
    ↓
supabase.auth.signOut()
    ↓
AuthGatePage detecta mudança
    ↓
Redireciona para LoginPage
```

## 🔑 Funcionalidades Implementadas

### ✅ Login
- Validação de e-mail e senha
- Feedback visual de erros
- Integração com Supabase Auth
- Redirecionamento automático após sucesso

### ✅ Criar Conta
- Validação de campos (nome, e-mail, senha)
- Confirmação de senha
- Armazenamento de metadados (nome completo)
- Redirecionamento automático após sucesso

### ✅ Logout
- Confirmação antes de sair
- Limpeza de sessão
- Redirecionamento automático para Login

### ✅ Proteção de Rotas
- HomePage só acessível quando logado
- Redirecionamento automático se tentar acessar sem login
- Monitoramento contínuo do estado de autenticação

## 💻 Implementação

### No main.dart

```dart
home: const AuthGatePage(
  authenticatedScreen: HomePage(),
),
```

### Menu de Usuário na HomePage

```dart
PopupMenuButton<String>(
  icon: const Icon(Icons.person_outline),
  onSelected: (value) async {
    if (value == 'logout') {
      await supabase.auth.signOut();
    }
  },
  itemBuilder: (context) => [
    // Mostra e-mail e nome do usuário
    PopupMenuItem(
      child: Column(
        children: [
          Text(supabase.auth.currentUser?.email ?? 'Usuário'),
          Text(supabase.auth.currentUser?.userMetadata?['full_name'] ?? ''),
        ],
      ),
    ),
    // Opção de logout
    PopupMenuItem(
      value: 'logout',
      child: Text('Sair'),
    ),
  ],
)
```

## 🎯 Acessar Dados do Usuário

### E-mail do usuário
```dart
final email = supabase.auth.currentUser?.email;
```

### Nome completo
```dart
final fullName = supabase.auth.currentUser?.userMetadata?['full_name'];
```

### ID do usuário
```dart
final userId = supabase.auth.currentUser?.id;
```

### Verificar se está logado
```dart
final isLoggedIn = supabase.auth.currentUser != null;
```

## 🔄 Monitorar Mudanças de Autenticação

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  if (session != null) {
    // Usuário logado
    print('Usuário: ${session.user.email}');
  } else {
    // Usuário deslogado
    print('Nenhum usuário logado');
  }
});
```

## 🎨 Personalização

### Cores
Todas as páginas usam a cor principal: **#08BF62**

### Logo
Logo exibida em:
- Splash screen (120x120)
- Login page (120x120)
- SignUp page (100x100)

### Validações
- **Nome**: mínimo 3 caracteres
- **E-mail**: formato válido (regex)
- **Senha**: mínimo 6 caracteres
- **Confirmação**: deve coincidir com senha

## 🚨 Tratamento de Erros

O sistema trata os seguintes casos:
- E-mail já cadastrado
- Credenciais inválidas
- Problemas de conexão
- Sessão expirada

Todos os erros são exibidos via SnackBar com mensagens claras.

## 📱 Responsividade

- Design otimizado para mobile
- Campos de entrada com tamanhos adequados
- Botões com área de toque apropriada
- Layout que se adapta a diferentes tamanhos de tela

## 🔒 Segurança

- Senhas ocultadas por padrão
- Toggle para visualizar senha
- Validação no frontend e backend
- Sessões gerenciadas pelo Supabase
- Tokens JWT seguros

## 🎉 Benefícios

1. **Automático**: Não precisa gerenciar navegação manualmente
2. **Reativo**: Responde a mudanças em tempo real
3. **Seguro**: Proteção de rotas integrada
4. **UX Superior**: Transições suaves e feedback claro
5. **Manutenível**: Código organizado e documentado

