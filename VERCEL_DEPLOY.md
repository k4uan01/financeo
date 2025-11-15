# Deploy do Financeo na Vercel

Este guia explica como fazer o deploy do projeto Flutter Web na Vercel.

## Pré-requisitos

1. Conta na Vercel (gratuita): https://vercel.com
2. Projeto no GitHub, GitLab ou Bitbucket
3. Flutter SDK instalado localmente (para testes)

## Opção 1: Deploy via Vercel Dashboard (Recomendado)

### Passo 1: Preparar o Repositório

Certifique-se de que seu código está no GitHub/GitLab/Bitbucket e que o arquivo `vercel.json` está na raiz do projeto.

### Passo 2: Conectar o Projeto na Vercel

1. Acesse https://vercel.com e faça login
2. Clique em "Add New Project"
3. Importe seu repositório do GitHub/GitLab/Bitbucket
4. A Vercel detectará automaticamente o arquivo `vercel.json`

### Passo 3: Configurar Variáveis de Ambiente (se necessário)

Se você usar variáveis de ambiente para o Supabase, configure-as nas configurações do projeto:
- Settings → Environment Variables
- Adicione as variáveis necessárias

### Passo 4: Deploy

1. Clique em "Deploy"
2. A Vercel irá:
   - Instalar o Flutter SDK
   - Executar `flutter pub get`
   - Executar `flutter build web --release`
   - Fazer o deploy dos arquivos em `build/web`

## Opção 2: Deploy via Vercel CLI

### Instalação da Vercel CLI

```bash
npm i -g vercel
```

### Login na Vercel

```bash
vercel login
```

### Deploy

```bash
# Deploy de produção
vercel --prod

# Ou deploy de preview
vercel
```

## Configuração do Build

O arquivo `vercel.json` já está configurado com:

- **Build Command**: Instala Flutter se necessário e executa `flutter build web --release`
- **Output Directory**: `build/web`
- **Rewrites**: Configurado para SPA (Single Page Application)
- **Headers**: Configurações de segurança e cache

### Alternativa: Se o build falhar

Se o build automático não funcionar, você pode:

1. **Opção 1**: Fazer build localmente e fazer deploy apenas dos arquivos estáticos:
   ```bash
   flutter build web --release
   # Fazer upload apenas da pasta build/web
   ```

2. **Opção 2**: Usar o arquivo `vercel.json.simple` (versão simplificada)
   - Renomeie `vercel.json.simple` para `vercel.json`
   - Configure manualmente o Flutter nas configurações do projeto

3. **Opção 3**: Usar GitHub Actions para fazer o build e depois fazer deploy na Vercel

## Notas Importantes

1. **Primeiro Build**: O primeiro build pode demorar mais porque a Vercel precisa instalar o Flutter SDK
2. **Builds Subsequentes**: Serão mais rápidos devido ao cache
3. **Variáveis de Ambiente**: Configure as variáveis do Supabase nas configurações do projeto na Vercel
4. **Domínio**: A Vercel fornece um domínio automático, mas você pode configurar um domínio customizado

## Troubleshooting

### Erro: Flutter não encontrado
- A Vercel deve detectar automaticamente o Flutter através do arquivo `pubspec.yaml`
- Se não funcionar, verifique se o arquivo `vercel.json` está correto

### Erro: Build falha
- Verifique os logs de build na Vercel
- Certifique-se de que todas as dependências estão no `pubspec.yaml`
- Verifique se não há erros de compilação no código

### Erro: Página em branco
- Verifique se o `outputDirectory` está correto (`build/web`)
- Verifique os logs do console do navegador
- Certifique-se de que as rotas estão configuradas corretamente no `vercel.json`

## Testando Localmente

Antes de fazer o deploy, teste localmente:

```bash
# Instalar dependências
flutter pub get

# Build para web
flutter build web --release

# Servir localmente (opcional)
cd build/web
python -m http.server 8000
# ou
npx serve -s build/web
```

## Atualizações

Após fazer push para o repositório conectado, a Vercel fará deploy automático se o "Auto Deploy" estiver habilitado.

## Suporte

Para mais informações sobre Flutter na Vercel:
- Documentação Vercel: https://vercel.com/docs
- Flutter Web: https://docs.flutter.dev/platform-integration/web

