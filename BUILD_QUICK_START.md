# Build Rápido para Play Store

## Pré-requisitos Rápidos

1. ✅ Keystore configurada (veja [KEYSTORE_SETUP.md](./KEYSTORE_SETUP.md))
2. ✅ Arquivo `android/key.properties` criado e preenchido

## Build em 3 Passos

### Opção 1: Script Automatizado (Recomendado)

```powershell
# Build simples
.\scripts\build_release.ps1

# Build com ofuscação (recomendado para produção)
.\scripts\build_release.ps1 --obfuscate
```

### Opção 2: Comandos Manuais

```bash
# 1. Limpar e obter dependências
flutter clean
flutter pub get

# 2. Build do App Bundle
flutter build appbundle --release

# 3. Build com ofuscação (opcional)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## Localização do Arquivo

O App Bundle será gerado em:
```
build/app/outputs/bundle/release/app.aab
```

## Atualizar Versão

Antes de cada build, atualize no `pubspec.yaml`:

```yaml
version: 1.0.0+1  # Incremente o número após o + para cada publicação
```

## Próximos Passos

1. Faça upload do `.aab` no [Google Play Console](https://play.google.com/console)
2. Siga o guia completo em [PLAY_STORE_DEPLOY.md](./PLAY_STORE_DEPLOY.md)

---

**Dica**: Use `--obfuscate` para proteger seu código em produção! 🔒

