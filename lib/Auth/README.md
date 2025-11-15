# Módulo Auth

Este módulo contém toda a funcionalidade de autenticação do aplicativo Financeo.

## Estrutura

```
Auth/
├── PagesAuth/           # Páginas do módulo de autenticação
│   ├── AuthGatePage.dart   # Gerenciador de rotas de autenticação
│   ├── LoginPage.dart      # Página de login
│   └── SignUpPage.dart     # Página de criar conta
├── ComponentsAuth/      # Componentes reutilizáveis do módulo
│   ├── CustomTextField.dart  # Campo de texto customizado
│   ├── PrimaryButton.dart    # Botão principal customizado
│   └── LogoutButton.dart     # Botão de logout com confirmação
└── AUTH_SYSTEM.md       # Documentação completa do sistema
```

## Páginas

### AuthGatePage
Gerenciador central de autenticação que:
- Verifica o estado de autenticação do usuário
- Redireciona automaticamente para Login ou HomePage
- Monitora mudanças em tempo real via StreamBuilder
- Exibe splash screen durante verificação

**Como usar:**
```dart
home: const AuthGatePage(
  authenticatedScreen: HomePage(),
),
```

### SignUpPage
Página para criação de nova conta de usuário.

**Campos:**
- Nome Completo
- E-mail
- Senha
- Confirmar Senha

**Validações:**
- Nome: mínimo 3 caracteres
- E-mail: formato válido
- Senha: mínimo 6 caracteres
- Confirmação de senha: deve coincidir com a senha

**Funcionalidades:**
- Criação de conta via Supabase Auth
- Feedback visual durante o carregamento
- Mensagens de sucesso/erro
- Link para página de login

### LoginPage
Página de login para usuários existentes.

**Campos:**
- E-mail
- Senha

**Funcionalidades:**
- Login via Supabase Auth
- Opção "Esqueceu a senha?"
- Link para criar conta
- Feedback visual durante o carregamento

## Componentes

### CustomTextField
Campo de texto reutilizável com estilo padronizado.

**Props:**
- `controller`: TextEditingController
- `labelText`: String
- `prefixIcon`: IconData
- `obscureText`: bool (padrão: false)
- `keyboardType`: TextInputType?
- `validator`: Function?
- `suffixIcon`: Widget?

### PrimaryButton
Botão principal com estilo padronizado.

**Props:**
- `text`: String
- `onPressed`: VoidCallback?
- `isLoading`: bool (padrão: false)

## Como usar

### Navegando para SignUpPage

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const SignUpPage(),
  ),
);
```

### Navegando para LoginPage

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const LoginPage(),
  ),
);
```

## Integração com Supabase

O módulo utiliza o Supabase Auth para gerenciar autenticação:

- **SignUp**: `supabase.auth.signUp()`
- **SignIn**: `supabase.auth.signInWithPassword()`

## Cor Principal

Todas as páginas e componentes utilizam a cor principal do app: `#08BF62`

