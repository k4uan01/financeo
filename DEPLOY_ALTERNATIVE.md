# 🚀 Alternativa: Deploy com Build Local

Se o build automático na Vercel não funcionar (porque o Flutter não está instalado), você pode fazer o build localmente e fazer deploy apenas dos arquivos estáticos.

## Método 1: Build Local + Deploy Manual

### Passo 1: Build Local
```bash
# No seu computador, execute:
flutter pub get
flutter build web --release
```

### Passo 2: Deploy apenas da pasta build/web

#### Opção A: Via Vercel CLI
```bash
# Instalar Vercel CLI
npm i -g vercel

# Login
vercel login

# Fazer deploy apenas da pasta build/web
cd build/web
vercel --prod
```

#### Opção B: Via Dashboard Vercel
1. Acesse https://vercel.com
2. Clique em "Add New Project"
3. Escolha "Upload" (não conecte ao Git)
4. Arraste a pasta `build/web` para o upload
5. Clique em "Deploy"

## Método 2: GitHub Actions + Vercel

Crie um workflow do GitHub Actions que faz o build e depois faz deploy na Vercel automaticamente.

### Criar arquivo `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
          channel: 'stable'
      
      - run: flutter pub get
      - run: flutter build web --release
      
      - uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./build/web
```

## Método 3: Usar Netlify (Alternativa à Vercel)

A Netlify tem melhor suporte para Flutter. Você pode:

1. Criar arquivo `netlify.toml`:
```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"
```

2. Conectar seu repositório na Netlify
3. O build será automático

## Recomendação

Para começar rapidamente, use o **Método 1** (build local + deploy manual). É o mais simples e funciona sempre!

