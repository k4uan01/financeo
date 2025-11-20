# Módulo General

Este módulo contém componentes e páginas gerais reutilizáveis em todo o sistema Financeo.

## Estrutura

```
General/
├── ComponentsGeneral/      # Componentes reutilizáveis gerais
│   ├── AppHeader.dart          # Cabeçalho com informações do usuário
│   ├── AppLogo.dart            # Logo customizada do app
│   ├── ConfirmDialog.dart      # Diálogo de confirmação
│   ├── CustomBottomNavBar.dart # Barra de navegação inferior
│   ├── CustomCard.dart         # Card customizado reutilizável
│   ├── CustomSnackBar.dart     # SnackBar customizado com tipos
│   ├── EmptyStateWidget.dart   # Widget para estados vazios
│   ├── ErrorWidget.dart        # Widget para exibir erros
│   ├── LoadingWidget.dart      # Widget de carregamento
│   └── MainNavigationWrapper.dart # Wrapper principal de navegação
└── PagesGeneral/          # Páginas gerais do sistema
    ├── AboutPage.dart          # Página sobre o app
    ├── HelpPage.dart           # Página de ajuda e FAQ
    └── SettingsPage.dart       # Página de configurações
```

## Componentes

### AppHeader
Cabeçalho com informações do usuário, incluindo avatar, saudação e nome.

**Uso:**
```dart
import 'General/ComponentsGeneral/AppHeader.dart';

AppHeader()
```

### AppLogo
Logo customizada do Financeo (container verde com texto "FA").

**Props:**
- `size`: Tamanho do logo (padrão: 120)
- `borderRadius`: Border radius (padrão: 24)

**Uso:**
```dart
import 'General/ComponentsGeneral/AppLogo.dart';

AppLogo(size: 100, borderRadius: 20)
```

### CustomBottomNavBar
Barra de navegação inferior customizada.

**Props:**
- `currentIndex`: Índice da página atual
- `onTap`: Callback quando um item é tocado

**Uso:**
```dart
import 'General/ComponentsGeneral/CustomBottomNavBar.dart';

CustomBottomNavBar(
  currentIndex: 0,
  onTap: (index) => {},
)
```

### CustomCard
Card customizado reutilizável.

**Props:**
- `child`: Widget filho
- `onTap`: Callback opcional
- `padding`: Padding customizado
- `margin`: Margin customizado
- `color`: Cor customizada

**Uso:**
```dart
import 'General/ComponentsGeneral/CustomCard.dart';

CustomCard(
  child: Text('Conteúdo'),
  onTap: () => {},
)
```

### CustomSnackBar
SnackBar customizado com diferentes tipos.

**Métodos:**
- `showSuccess(context, message)`: SnackBar de sucesso (verde)
- `showError(context, message)`: SnackBar de erro (vermelho)
- `showInfo(context, message)`: SnackBar de informação (azul)
- `showWarning(context, message)`: SnackBar de aviso (laranja)

**Uso:**
```dart
import 'General/ComponentsGeneral/CustomSnackBar.dart';

CustomSnackBar.showSuccess(context, 'Operação realizada com sucesso!');
```

### ConfirmDialog
Diálogo de confirmação customizado.

**Uso:**
```dart
import 'General/ComponentsGeneral/ConfirmDialog.dart';

final confirmed = await ConfirmDialog.show(
  context,
  title: 'Confirmar',
  message: 'Tem certeza?',
);
```

### LoadingWidget
Widget de carregamento.

**Props:**
- `message`: Mensagem opcional
- `color`: Cor do indicador (padrão: #08BF62)

**Uso:**
```dart
import 'General/ComponentsGeneral/LoadingWidget.dart';

LoadingWidget(message: 'Carregando...')
```

### ErrorWidget
Widget para exibir erros.

**Props:**
- `message`: Mensagem de erro
- `onRetry`: Callback opcional para tentar novamente
- `icon`: Ícone customizado

**Uso:**
```dart
import 'General/ComponentsGeneral/ErrorWidget.dart';

ErrorWidget(
  message: 'Erro ao carregar dados',
  onRetry: () => {},
)
```

### EmptyStateWidget
Widget para estados vazios.

**Props:**
- `title`: Título
- `subtitle`: Subtítulo opcional
- `icon`: Ícone (padrão: Icons.inbox_outlined)
- `action`: Widget de ação opcional

**Uso:**
```dart
import 'General/ComponentsGeneral/EmptyStateWidget.dart';

EmptyStateWidget(
  title: 'Nenhum item encontrado',
  subtitle: 'Tente adicionar um novo item',
  action: ElevatedButton(...),
)
```

### MainNavigationWrapper
Wrapper principal de navegação do app.

**Uso:**
```dart
import 'General/ComponentsGeneral/MainNavigationWrapper.dart';

MainNavigationWrapper()
```

## Páginas

### SettingsPage
Página de configurações do app.

**Funcionalidades:**
- Toggle de modo escuro/claro
- Configurações de notificações
- Configurações de segurança
- Exportação de dados
- Links para outras páginas (Sobre, Ajuda)

**Uso:**
```dart
import 'General/PagesGeneral/SettingsPage.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SettingsPage()),
);
```

### AboutPage
Página sobre o app.

**Funcionalidades:**
- Informações da versão
- Detalhes sobre o desenvolvimento
- Informações de contato
- Links para política de privacidade e termos de uso

**Uso:**
```dart
import 'General/PagesGeneral/AboutPage.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AboutPage()),
);
```

### HelpPage
Página de ajuda e perguntas frequentes.

**Funcionalidades:**
- Lista de perguntas frequentes
- Informações de contato
- Links para suporte

**Uso:**
```dart
import 'General/PagesGeneral/HelpPage.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HelpPage()),
);
```

## Notas

- Todos os componentes seguem o padrão de design do Financeo
- Cores principais: #08BF62 (verde)
- Suporte a Dark Mode e Light Mode
- Design responsivo para mobile

