# Guia de Seleção de Cores - Ícones Genéricos

## ✅ Funcionalidade Implementada

Adicionado sistema de **seleção de cor** para ícones genéricos. Quando o usuário seleciona um ícone genérico, uma paleta de cores aparece para escolher a cor de fundo do ícone.

## 📁 Novos Arquivos Criados

### `lib/models/icon_with_color.dart`

**Classes criadas:**

#### 1. `IconWithColor`
Classe que representa um ícone com a cor selecionada.

```dart
class IconWithColor {
  final BankAccountIconModel icon;
  final String? color;  // Hex color (ex: "#FF5733")
}
```

#### 2. `IconColors`
Paleta de cores disponíveis para seleção.

**Cores disponíveis (12 opções):**
- Branco (`#FFFFFF`)
- Cinza (`#9E9E9E`)
- Amarelo (`#FFEB3B`)
- Vermelho (`#F44336`)
- Azul (`#2196F3`)
- Verde (`#4CAF50`)
- Bege (`#D7CCC8`)
- Laranja (`#FF9800`)
- Rosa (`#E91E63`)
- Roxo (`#9C27B0`)
- Verde Água (`#00BCD4`)
- Marrom (`#795548`)

## 🔄 Arquivos Atualizados

### 1. `IconSelectorBottomSheet.dart`

**Novas funcionalidades:**

#### Estado adicionado:
```dart
BankAccountIconModel? _selectedIcon;
String? _selectedColor;
```

#### Métodos novos:

**`_handleIconTap(icon)`**
- Se ícone **genérico**: Mostra paleta de cores
- Se ícone **bancário**: Retorna imediatamente

**`_handleColorSelected(color)`**
- Retorna `IconWithColor` com ícone + cor selecionada

**`_buildColorPalette()`**
- Widget da paleta de cores
- Aparece fixado no fundo do bottom sheet
- Mostra preview do ícone selecionado

**`_buildColorOption(hexColor)`**
- Widget de cada cor
- Círculo colorido
- Borda verde quando selecionado
- Ícone de check quando selecionado

### 2. `CreateBankAccountPage.dart`

**Estado adicionado:**
```dart
BankAccountIconModel? _selectedIcon;
String? _selectedColor;
```

**Validações:**
- ✅ Ícone obrigatório
- ✅ Cor obrigatória para ícones genéricos
- ✅ Alertas visuais para cada validação

**Preview do ícone:**
- Fundo com a cor selecionada
- Mensagem "Selecione uma cor" se cor não foi escolhida
- Cor laranja no texto de aviso

**Envio para API:**
```dart
await _bankAccountService.createBankAccount(
  name: name,
  balance: balance,
  iconId: iconId,
  iconColor: selectedColor,  // Cor em hex
);
```

## 🎨 Fluxo de UX

### Fluxo Completo:

```
1. Usuário clica em "Selecionar ícone"
   ↓
2. Bottom sheet abre
   ↓
3. Usuário clica em ícone GENÉRICO
   ↓
4. Ícone fica com borda verde (selecionado)
   ↓
5. Paleta de cores aparece no fundo
   ↓
6. Preview do ícone aparece acima das cores
   ↓
7. Usuário clica em uma cor
   ↓
8. Bottom sheet fecha
   ↓
9. Campo atualiza com ícone + cor de fundo
   ↓
10. Usuário clica em "Criar Conta"
    ↓
11. API recebe icon_id + icon_color
```

### Fluxo para Ícones Bancários:

```
1. Usuário clica em "Selecionar ícone"
   ↓
2. Bottom sheet abre
   ↓
3. Usuário clica em ícone BANCÁRIO
   ↓
4. Bottom sheet fecha imediatamente
   ↓
5. Campo atualiza com logo do banco
   ↓
6. (Sem seleção de cor)
```

## 📊 Estados Visuais

### Ícone Genérico - Não selecionado
```
┌─────────────────────────┐
│ [?] Selecionar ícone    │
└─────────────────────────┘
```

### Ícone Genérico - Selecionado sem cor
```
┌─────────────────────────┐
│ [💰] Carteira           │
│      Selecione uma cor  │ ⚠️ (laranja)
└─────────────────────────┘
```

### Ícone Genérico - Com cor
```
┌─────────────────────────┐
│ [🔴💰] Carteira         │
│        Ícone genérico   │
└─────────────────────────┘
```

### Ícone Bancário
```
┌─────────────────────────┐
│ [🏦] Nubank             │
│      Instituição banc.  │
└─────────────────────────┘
```

## 🎯 Layout do Bottom Sheet

### Quando ícone genérico está selecionado:

```
┌─────────────────────────────────┐
│ Selecionar um ícone        [X]  │
│                                 │
│ 🔍 Buscar...                    │
│                                 │
│ Ícone genéricos                 │
│ ┌───┬───┬───┬───┐               │
│ │ 💰│ 🏦│ 🐷│   │               │
│ └───┴───┴───┴───┘               │
│                                 │
│ Ícones de instituições...       │
│ ┌───┬───┬───┬───┐               │
│ │99P│Nu │   │   │               │
│ └───┴───┴───┴───┘               │
├─────────────────────────────────┤
│ [💰] Carteira                   │
│ Selecione uma cor               │
│                                 │
│ ⚪ ⚫ 🟡 🔴 🔵 🟢 🟤 🟠         │
│ 🌸 🟣 💚 🟤                      │
└─────────────────────────────────┘
```

## 🔧 Detalhes Técnicos

### Conversão de Cor Hex para Color:
```dart
Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000)
```

### Detecção de tipo de ícone:
```dart
icon.isGeneric  // true se type == "generic"
icon.isBankingInstitution  // true se type == "banking institution"
```

### Retorno do Bottom Sheet:
```dart
// Ícone genérico
IconWithColor(
  icon: carteiraIcon,
  color: "#F44336"
)

// Ícone bancário
IconWithColor(
  icon: nubank Icon,
  color: null
)
```

## ✅ Validações Implementadas

### Na CreateBankAccountPage:

1. **Ícone não selecionado:**
   - Alerta laranja: "Por favor, selecione um ícone"

2. **Ícone genérico sem cor:**
   - Alerta laranja: "Por favor, selecione uma cor para o ícone"
   - Texto "Selecione uma cor" em laranja no campo

3. **Tudo OK:**
   - Campo com ícone + cor de fundo
   - Pronto para criar conta

## 🎨 Visual Design

### Círculo de Cor:
- **Tamanho**: 50x50px
- **Borda normal**: 1px cinza (branco) ou transparente
- **Borda selecionada**: 3px verde (#08BF62)
- **Shadow selecionada**: Brilho verde
- **Check**: Ícone branco quando selecionado

### Paleta:
- **Posição**: Fixada no fundo do bottom sheet
- **Padding**: 16px
- **Spacing**: 12px entre cores
- **Wrap**: Quebra linha automaticamente
- **Preview**: Ícone 48x48 com a cor de fundo

## 🚀 Como Testar

### 1. Hot Restart
```bash
R  # No terminal Flutter
```

### 2. Testar Ícone Genérico
1. Ir para criar conta
2. Clicar em "Selecionar ícone"
3. Clicar em "Carteira" (genérico)
4. Ver paleta de cores aparecer
5. Clicar em vermelho
6. Ver campo atualizar com fundo vermelho

### 3. Testar Ícone Bancário
1. Clicar em "Selecionar ícone"
2. Clicar em "Nubank" (bancário)
3. Bottom sheet fecha imediatamente
4. Ver logo do banco no campo

### 4. Testar Validações
1. Tentar criar sem selecionar ícone
   - ✅ Ver alerta laranja
2. Selecionar ícone genérico sem cor
   - ✅ Ver "Selecione uma cor" laranja
3. Tentar criar sem cor
   - ✅ Ver alerta laranja

## 📝 Dados Enviados para API

### Ícone Genérico (com cor):
```json
{
  "p_name": "Minha Carteira",
  "p_icon_id": "uuid-carteira",
  "p_balance": 1000.00,
  "p_icon_color": "#F44336"
}
```

### Ícone Bancário (sem cor):
```json
{
  "p_name": "Conta Nubank",
  "p_icon_id": "uuid-nubank",
  "p_balance": 500.00,
  "p_icon_color": null
}
```

## 🎯 Resumo

| Tipo de Ícone | Seleção de Cor | Cor Enviada | Fundo do Preview |
|---------------|----------------|-------------|------------------|
| **Genérico** | Obrigatória | Hex color | Cor selecionada |
| **Bancário** | Não disponível | null | Transparente |

---

**Status:** ✅ IMPLEMENTADO E FUNCIONANDO  
**Cores disponíveis:** 12  
**Data:** 06/11/2025

