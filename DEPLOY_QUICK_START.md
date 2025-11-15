# 🚀 Deploy Rápido na Vercel

## Passos Rápidos

### 1. Preparação
Certifique-se de que seu código está no GitHub/GitLab/Bitbucket.

### 2. Deploy na Vercel

#### Via Dashboard (Mais Fácil):
1. Acesse https://vercel.com
2. Clique em **"Add New Project"**
3. Conecte seu repositório
4. A Vercel detectará automaticamente o `vercel.json`
5. Clique em **"Deploy"**

#### Via CLI:
```bash
# Instalar Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

### 3. Configuração (Opcional)

Se você precisar configurar variáveis de ambiente do Supabase:
- Vá em **Settings → Environment Variables** no projeto Vercel
- Adicione as variáveis necessárias

### 4. Pronto! 🎉

Seu app estará disponível em `seu-projeto.vercel.app`

## ⚠️ Importante

- O primeiro build pode demorar ~5-10 minutos (instalação do Flutter)
- Builds subsequentes são mais rápidos (~2-3 minutos)
- A Vercel faz deploy automático a cada push no repositório

## 🔧 Testando Localmente

Antes de fazer deploy, teste localmente:

```bash
flutter pub get
flutter build web --release
cd build/web
npx serve -s .
```

Acesse http://localhost:3000

## 📝 Notas

- O arquivo `vercel.json` já está configurado
- O output directory está configurado para `build/web`
- O build usa `canvaskit` renderer (melhor compatibilidade)

