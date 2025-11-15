# Guia de Seleção de Ícones - BankAccounts

## 🎨 Funcionalidade Implementada

Adicionado sistema completo de seleção de ícones para contas bancárias com bottom sheet interativo.

## 📁 Novos Arquivos Criados

### 1. `bank_account_icon_model.dart`
Modelo de dados para ícones de contas bancárias.

**Classes:**
- `BankAccountIconModel`: Modelo principal do ícone
- `BankAccountIconsResponse`: Resposta da API com lista de ícones
- `IconPagination`: Informações de paginação

**Propriedades do ícone:**
```dart
{
  "id": "UUID",
  "name": "String",
  "image": "URL da imagem",
  "type": "generic" ou "banking institution"
}
```

### 2. `bank_account_icon_service.dart`
Serviço para buscar ícones da API Supabase.

**Métodos:**
- `getIcons()`: Busca ícones com filtros
- `getGenericIcons()`: Busca apenas ícones genéricos
- `getBankingInstitutionIcons()`: Busca apenas ícones de instituições bancárias
- `getAllIcons()`: Busca todos os ícones

**Parâmetros da API:**
- `p_items_page`: Itens por página (padrão: 100)
- `p_current_page`: Página atual (padrão: 1)
- `p_search`: Termo de busca (opcional)
- `p_type`: Tipo de ícone (opcional)

### 3. `IconSelectorBottomSheet.dart`
Componente de bottom sheet para seleção de ícones.

**Características:**
- ✅ Campo de busca em tempo real
- ✅ Duas categorias: "Ícones genéricos" e "Ícones de instituições bancárias"
- ✅ Grid responsivo (4 colunas)
- ✅ Loading states
- ✅ Tratamento de erros de imagem
- ✅ Design moderno e intuitivo
- ✅ Suporte a Dark/Light Mode

**Como usar:**
```dart
final icon = await showIconSelector(context);
if (icon != null) {
  print('Ícone selecionado: ${icon.name}');
}
```

## 🔄 Alterações na CreateBankAccountPage

### Campo de Seleção Adicionado

Entre o campo "Nome" e "Saldo", foi adicionado um campo interativo de seleção de ícone:

**Estado inicial (sem ícone):**
```
┌─────────────────────────────────────┐
│ [📁] Selecionar ícone          [→] │
└─────────────────────────────────────┘
```

**Estado com ícone selecionado:**
```
┌─────────────────────────────────────┐
│ [🏦] Banco                     [→] │
│      Instituição bancária           │
└─────────────────────────────────────┘
```

### Validação
- ✅ Ícone é **obrigatório**
- ✅ Mostra alerta se tentar criar sem selecionar ícone
- ✅ Borda verde quando ícone está selecionado

### Fluxo de Uso
1. Usuário clica no campo "Selecionar ícone"
2. Bottom sheet abre com duas categorias
3. Usuário pode buscar por nome
4. Usuário seleciona um ícone
5. Campo atualiza mostrando o ícone escolhido
6. Ao criar a conta, o ID do ícone é enviado para a API

## 🔌 Integração com a API

### Endpoint: `get_bank_account_icons`

**Chamadas realizadas:**

1. **Ícones Genéricos:**
```dart
await _iconService.getGenericIcons(search: searchQuery);
```
API: `rpc('get_bank_account_icons', params: {'p_type': 'generic'})`

2. **Ícones de Instituições Bancárias:**
```dart
await _iconService.getBankingInstitutionIcons(search: searchQuery);
```
API: `rpc('get_bank_account_icons', params: {'p_type': 'banking institution'})`

### Resposta da API
```json
{
  "status": true,
  "message": "Ícones retornados com sucesso",
  "data": [
    {
      "id": "uuid",
      "name": "Carteira",
      "image": "https://...",
      "type": "generic"
    }
  ],
  "pagination": {
    "total_items": 10,
    "total_pages": 1,
    "current_page": 1
  }
}
```

## 🎨 Design e UX

### Layout do Bottom Sheet

```
┌─────────────────────────────────────┐
│  ─────  (handle bar)                │
│                                     │
│  Selecionar um ícone           [X]  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ 🔍 Buscar um ícone           │  │
│  └───────────────────────────────┘  │
│                                     │
│  Ícone genéricos                    │
│  ┌───┬───┬───┬───┐                  │
│  │ 💰│ 🏦│ 💳│ 🐷│                  │
│  ├───┼───┼───┼───┤                  │
│  │ 📊│ 💵│ 🏛️│ 📈│                  │
│  └───┴───┴───┴───┘                  │
│                                     │
│  Ícones de instituições bancárias   │
│  ┌───┬───┬───┬───┐                  │
│  │99P│Bari│BMG│Cora│                │
│  └───┴───┴───┴───┘                  │
└─────────────────────────────────────┘
```

### Cores
- **Borda selecionado**: `#08BF62` (cor principal)
- **Fundo do ícone**: `#08BF62` com 10% de opacidade
- **Estados de loading**: CircularProgressIndicator

### Responsividade
- ✅ Ocupa 85% da altura da tela
- ✅ Grid com 4 colunas
- ✅ Espaçamento adequado (12px)
- ✅ Rolagem suave

## 🔄 Como Testar

### 1. Reiniciar o App
```bash
R  # Hot Restart no terminal do Flutter
```

### 2. Navegar para Criação
1. Fazer login
2. Clicar em "Contas Bancárias" na HomePage
3. Preencher o nome
4. **Clicar em "Selecionar ícone"**

### 3. Testar o Bottom Sheet
- ✅ Verificar se carrega os ícones genéricos
- ✅ Verificar se carrega os ícones bancários
- ✅ Testar busca digitando um nome
- ✅ Selecionar um ícone
- ✅ Verificar se o campo atualiza

### 4. Criar Conta
- ✅ Tentar criar sem ícone (deve mostrar alerta)
- ✅ Selecionar ícone e criar
- ✅ Verificar sucesso

## 📊 Fluxo de Dados

```
CreateBankAccountPage
    ↓ (clica em selecionar)
IconSelectorBottomSheet
    ↓ (carrega dados)
BankAccountIconService
    ↓ (chama API)
Supabase RPC: get_bank_account_icons
    ↓ (retorna)
BankAccountIconsResponse
    ↓ (exibe no grid)
Usuário seleciona
    ↓ (retorna)
CreateBankAccountPage atualiza
    ↓ (cria conta)
BankAccountService.createBankAccount(iconId: selectedIcon.id)
```

## 💡 Funcionalidades Extras

### Busca em Tempo Real
- Busca funciona para ambas as categorias
- Atualiza automaticamente ao digitar
- Pode limpar a busca com o botão [X]

### Loading States
- Loading individual para cada categoria
- Skeleton/placeholder durante carregamento
- Mensagem quando não há resultados

### Error Handling
- Imagens com erro mostram ícone fallback
- Mensagens claras de erro da API
- Estados vazios bem tratados

## 🚀 Melhorias Futuras

### Curto Prazo
- [ ] Cache local de ícones para performance
- [ ] Lazy loading/infinite scroll
- [ ] Animações de transição

### Médio Prazo
- [ ] Upload de ícone customizado
- [ ] Favoritos/ícones recentes
- [ ] Prévia do ícone em tamanho maior

### Longo Prazo
- [ ] Organização por categorias adicionais
- [ ] Suporte a ícones coloridos/SVG
- [ ] Editor de ícones integrado

## 📝 Observações Técnicas

### Performance
- Carrega até 100 ícones por vez (configurável)
- Imagens com loading progressivo
- Otimização de rebuild com setState localizado

### Acessibilidade
- Todos os botões têm áreas de toque adequadas
- Textos descritivos para screen readers
- Contraste adequado de cores

### Segurança
- Validação de autenticação na API
- RLS (Row Level Security) no Supabase
- Tratamento seguro de URLs de imagem

---

**Status:** ✅ IMPLEMENTADO E TESTADO

**Data:** 06/11/2025

