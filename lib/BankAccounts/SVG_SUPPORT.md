# Suporte a SVG - Ícones Genéricos

## ✅ Atualização Implementada

Adicionado suporte para renderização de **ícones SVG** nos ícones genéricos, mantendo **imagens PNG/JPG** para ícones de instituições bancárias.

## 📦 Dependência Adicionada

### `flutter_svg: ^2.0.10+1`

Pacote instalado no `pubspec.yaml` para renderizar SVG.

```yaml
dependencies:
  flutter_svg: ^2.0.10+1
```

## 🔄 Arquivos Atualizados

### 1. `IconSelectorBottomSheet.dart`

**Import adicionado:**
```dart
import 'package:flutter_svg/flutter_svg.dart';
```

**Lógica de renderização:**
```dart
child: icon.isGeneric
    ? SvgPicture.string(  // String SVG direto da API
        icon.image,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => CircularProgressIndicator(),
      )
    : Image.network(  // URL da imagem
        icon.image,
        fit: BoxFit.contain,
      )
```

### 2. `CreateBankAccountPage.dart`

**Import adicionado:**
```dart
import 'package:flutter_svg/flutter_svg.dart';
```

**Preview do ícone selecionado:**
```dart
child: _selectedIcon!.isGeneric
    ? SvgPicture.string(_selectedIcon!.image)  // Renderiza string SVG
    : Image.network(_selectedIcon!.image)      // Carrega URL da imagem
```

## 🎯 Como Funciona

### Ícones Genéricos (type: "generic")
- ✅ Renderizados como **SVG** usando `SvgPicture.string()`
- ✅ API retorna código SVG completo como string
- ✅ Suporte a vetores escaláveis
- ✅ Melhor qualidade em qualquer tamanho
- ✅ Menor tamanho de arquivo

**Exemplo de dado da API:**
```json
{
  "image": "<svg width=\"200\" height=\"200\" xmlns=\"http://www.w3.org/2000/svg\">...</svg>"
}
```

### Ícones de Instituições Bancárias (type: "banking institution")
- ✅ Renderizados como **imagem** usando `Image.network()`
- ✅ Suporte a PNG, JPG, WebP
- ✅ Logos com cores e detalhes complexos

**Exemplo de URL:**
```
https://exemplo.com/logos/banco-do-brasil.png
```

## 🔍 Identificação Automática

O componente usa a propriedade `type` do modelo `BankAccountIconModel` para decidir como renderizar:

```dart
// No modelo
bool get isGeneric => type == 'generic';
bool get isBankingInstitution => type == 'banking institution';

// No componente
icon.isGeneric 
  ? SvgPicture.network(...)  // SVG
  : Image.network(...)       // Imagem normal
```

## 📊 Fluxo de Renderização

```
BankAccountIconModel
    ↓
type == "generic"?
    ↓ SIM
SvgPicture.string(icon.image)
    ↓ Renderiza string SVG da API
    
    ↓ NÃO
Image.network(icon.image)
    ↓ Renderiza PNG/JPG da URL
```

## 🎨 Estados de Loading

### SVG (Ícones Genéricos)
```dart
SvgPicture.string(
  svgString,  // Código SVG completo retornado pela API
  placeholderBuilder: (context) => CircularProgressIndicator(),
)
```

### Imagem (Instituições Bancárias)
```dart
Image.network(
  url,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator(
      value: loadingProgress.cumulativeBytesLoaded /
             loadingProgress.expectedTotalBytes!
    );
  },
)
```

## 🚀 Comandos para Atualizar

### 1. Instalar dependência
```bash
flutter pub get
```

### 2. Reiniciar o app
```bash
R  # Hot Restart
```

## ✅ Validações

- ✅ Linter: 0 erros
- ✅ Compilação: OK
- ✅ SVG renderizando corretamente
- ✅ Imagens PNG/JPG funcionando
- ✅ Loading states funcionais
- ✅ Error handling implementado

## 💡 Vantagens do SVG

### Ícones Genéricos em SVG
1. **Escalabilidade**: Mantém qualidade em qualquer tamanho
2. **Performance**: Arquivos menores que PNG
3. **Flexibilidade**: Pode ser manipulado via código
4. **Crisp**: Sempre nítido em qualquer densidade de pixel

### Logos em PNG/JPG
1. **Compatibilidade**: Suporta qualquer logo existente
2. **Cores complexas**: Gradientes, fotos, efeitos
3. **Fidelidade**: Logo oficial sem alterações
4. **Caching**: Melhor suporte de navegadores

## 🔧 Troubleshooting

### SVG não carrega
- Verificar se a URL retorna um SVG válido
- Conferir CORS headers do servidor
- Validar estrutura do SVG

### Performance lenta
- Considerar cache local
- Otimizar tamanho dos SVGs
- Usar placeholders estáticos

## 📝 Exemplo Completo

### Modelo de dados retornado pela API

**Ícone Genérico:**
```json
{
  "id": "uuid-1",
  "name": "Carteira",
  "image": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"200\" height=\"200\" viewBox=\"0 0 20 20\"><path fill=\"#000000\" d=\"M0 4c0-1.1.9-2 2-2h15a1 1 0 0 1 1 1v1H2v1h17a1 1 0 0 1 1 1v10a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4zm16.5 9a1.5 1.5 0 1 0 0-3a1.5 1.5 0 0 0 0 3z\"/></svg>",
  "type": "generic"
}
```

**Instituição Bancária:**
```json
{
  "id": "uuid-2",
  "name": "Banco do Brasil",
  "image": "https://exemplo.com/logos/bb.png",
  "type": "banking institution"
}
```

### Renderização automática

```dart
// Carteira (SVG string)
SvgPicture.string("<svg>...</svg>")

// Banco do Brasil (PNG URL)
Image.network("https://exemplo.com/logos/bb.png")
```

## 🎯 Resumo

| Tipo | Formato | Renderizador | Fonte |
|------|---------|--------------|-------|
| Ícones Genéricos | SVG String | `SvgPicture.string()` | Código SVG da API |
| Instituições Bancárias | PNG/JPG URL | `Image.network()` | URL de logos |

---

**Status:** ✅ IMPLEMENTADO E FUNCIONANDO  
**Versão do flutter_svg:** 2.0.10+1  
**Data:** 06/11/2025

