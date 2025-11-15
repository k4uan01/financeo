# 💰 Financeo

Um aplicativo moderno de controle financeiro pessoal desenvolvido em Flutter.

## 📱 Sobre o Projeto

Financeo é um aplicativo de gerenciamento financeiro pessoal com uma interface limpa e intuitiva. O app permite que você acompanhe suas receitas e despesas de forma simples e visual.

## ✨ Características

- 📊 Visualização do saldo total
- 💵 Acompanhamento de receitas e despesas
- 📝 Lista de transações recentes
- 🎨 Interface moderna e intuitiva
- 🎯 Design Material 3
- 📱 Responsivo para diferentes tamanhos de tela

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Android Studio / VS Code / IntelliJ IDEA
- Emulador Android ou dispositivo físico conectado

### Instalação

1. Clone o repositório ou navegue até o diretório do projeto:
```bash
cd financeo
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o Supabase:
   - As credenciais já estão configuradas em `lib/config/supabase_config.dart`
   - Acesse seu projeto no Supabase: https://jsycwyuiqqijrcjhlbao.supabase.co
   - Execute o SQL em `supabase_schema.sql` no SQL Editor do Supabase para criar as tabelas
   - Veja o arquivo `SUPABASE_SETUP.md` para instruções detalhadas

4. Execute o aplicativo:
```bash
flutter run
```

## 🎮 Como Usar

### Início Rápido
Veja o arquivo `QUICK_START.md` para instruções detalhadas de início.

### Status do Projeto
Veja o arquivo `PROJECT_STATUS.md` para o status completo do desenvolvimento.

### Testar Agora
```bash
# Executar o aplicativo
flutter run

# Criar uma conta de teste
# - Email: teste@financeo.com
# - Senha: 123456

# Fazer login e explorar a interface
```

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework para desenvolvimento multiplataforma
- **Dart** - Linguagem de programação
- **Material 3** - Design system moderno do Google
- **Supabase** - Backend as a Service (BaaS) para autenticação e banco de dados

## 📂 Estrutura do Projeto

```
financeo/
├── lib/
│   ├── main.dart                    # Arquivo principal do aplicativo
│   ├── config/
│   │   └── supabase_config.dart     # Configurações do Supabase
│   ├── models/
│   │   └── transaction_model.dart   # Modelo de dados de transação
│   └── services/
│       └── supabase_service.dart    # Serviços do Supabase
├── android/                          # Configurações Android
├── ios/                              # Configurações iOS
├── test/                             # Testes
├── pubspec.yaml                      # Dependências do projeto
├── supabase_schema.sql               # Schema SQL para o Supabase
├── SUPABASE_SETUP.md                 # Guia de configuração do Supabase
├── USAGE_EXAMPLES.md                 # Exemplos de uso
├── SETUP_CHECKLIST.md                # Checklist de setup
└── README.md                         # Documentação
```

## 🎯 Funcionalidades Atuais

- ✅ **Sistema de Autenticação Completo**
  - Login com email e senha
  - Registro de novos usuários
  - Logout
  - Proteção de rotas (AuthGate)
- ✅ **Interface Moderna**
  - Visualização de saldo total
  - Exibição de receitas e despesas
  - Lista de transações com dados de exemplo
  - Formatação de datas (Hoje, Ontem, dd/mm/aaaa)
  - Tema Dark Mode (padrão) e Light Mode
  - Design responsivo para mobile
  - Cor principal: #08BF62

## 🔮 Próximos Passos

- [x] ✅ Implementar sistema de autenticação
- [x] ✅ Modo escuro (ativo por padrão)
- [ ] ⬜ Integrar transações com Supabase (CRUD completo)
- [ ] ⬜ Adicionar funcionalidade de criar nova transação
- [ ] ⬜ Adicionar categorias personalizadas
- [ ] ⬜ Gráficos e relatórios
- [ ] ⬜ Filtros e busca de transações
- [ ] ⬜ Exportação de dados
- [ ] ⬜ Lembretes e notificações
- [ ] ⬜ Sincronização em tempo real com Realtime do Supabase

## 📸 Screenshots

_Em breve: capturas de tela do aplicativo_

## 👨‍💻 Desenvolvedor

Desenvolvido com ❤️ usando Flutter

## 📄 Licença

Este projeto está sob a licença MIT.

---

**Nota:** Este é um projeto de demonstração. Para uso em produção, recomenda-se adicionar validações, tratamento de erros e persistência de dados adequada.
