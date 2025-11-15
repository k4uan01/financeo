# 🌙 Dark Mode - Financeo

## Configuração Aplicada

O Dark Mode agora está **ativo por padrão** em todo o aplicativo Financeo!

## 🎨 Cores do Dark Mode

### Cores Principais
- **Background**: `#121212` (cinza escuro)
- **Cards/Surface**: `#1E1E1E` (cinza médio)
- **Accent Color**: `#08BF62` (verde principal)

### Cores de Texto
- **Primary Text**: Branco/Cinza claro
- **Secondary Text**: `Grey[400]`
- **Disabled**: `Grey[600]`

### Bordas
- **Enabled**: `Grey[700]`
- **Focused**: `#08BF62`
- **Error**: Vermelho

## 📱 Páginas Atualizadas

### ✅ HomePage
- Background escuro automático
- Cards com fundo `#1E1E1E`
- AppBar escuro
- Texto adaptado para contraste

### ✅ LoginPage
- Background escuro
- Campos de input com bordas ajustadas
- Texto secundário em cinza claro
- Logo mantida (adapta automaticamente)

### ✅ SignUpPage
- Background escuro
- Campos de input com bordas ajustadas
- Texto secundário em cinza claro
- Logo mantida (adapta automaticamente)

### ✅ AuthGatePage
- Splash screen com background escuro
- Loading indicator verde (#08BF62)

## 🔧 Implementação Técnica

### main.dart
```dart
MaterialApp(
  themeMode: ThemeMode.dark, // Força dark mode
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF08BF62),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      // ...
    ),
  ),
)
```

### Detecção de Tema nas Páginas
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// Uso
color: isDark ? Colors.grey[400] : Colors.grey[600]
```

## 🎯 Benefícios

1. **Melhor Experiência Noturna**: Reduz fadiga visual
2. **Economia de Bateria**: Em telas OLED/AMOLED
3. **Design Moderno**: Segue tendências atuais
4. **Contraste Adequado**: Mantém legibilidade

## 🔄 Alternando entre Temas

Para alternar entre Light/Dark mode no futuro, basta mudar:

```dart
// Dark Mode (atual)
themeMode: ThemeMode.dark

// Light Mode
themeMode: ThemeMode.light

// Sistema (segue preferência do dispositivo)
themeMode: ThemeMode.system
```

## 📝 Checklist de Componentes

- [x] HomePage
- [x] LoginPage
- [x] SignUpPage
- [x] AuthGatePage (Splash)
- [x] AppBar
- [x] Cards
- [x] TextFields
- [x] Buttons
- [x] Dividers
- [x] PopupMenu

## 🎨 Paleta de Cores Completa

```
Dark Mode:
├─ Background: #121212
├─ Surface: #1E1E1E
├─ Primary: #08BF62 (Verde)
├─ Text Primary: #FFFFFF
├─ Text Secondary: Grey[400] (#BDBDBD)
├─ Borders: Grey[700] (#616161)
└─ Dividers: Grey[700] (#616161)

Light Mode (reserva):
├─ Background: #FFFFFF
├─ Surface: #FAFAFA
├─ Primary: #08BF62 (Verde)
├─ Text Primary: #000000
├─ Text Secondary: Grey[600] (#757575)
├─ Borders: Grey[300] (#E0E0E0)
└─ Dividers: Grey[300] (#E0E0E0)
```

## 🚀 Próximos Passos

Para estender o dark mode a novos componentes:

1. Adicione verificação de tema:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

2. Use cores condicionais:
```dart
color: isDark ? darkColor : lightColor
```

3. Utilize cores do tema:
```dart
Theme.of(context).colorScheme.primary
Theme.of(context).scaffoldBackgroundColor
```

## 💡 Dicas

- Sempre teste em ambos os temas antes de finalizar
- Use `Colors.grey[400]` para textos secundários no dark
- Use `Colors.grey[700]` para bordas no dark
- Mantenha contraste mínimo de 4.5:1 (WCAG AA)
- A cor principal `#08BF62` funciona bem em ambos os temas

---

**Status**: ✅ Implementado e Ativo  
**Última atualização**: Novembro 2025

