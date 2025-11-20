# Guia de Publicação na Google Play Store

Este guia explica como preparar e publicar o Financeo na Google Play Store.

## Pré-requisitos

1. **Conta de Desenvolvedor Google Play**: Você precisa de uma conta de desenvolvedor ($25 USD, pagamento único)
2. **Keystore configurada**: Veja [KEYSTORE_SETUP.md](./KEYSTORE_SETUP.md)
3. **Flutter SDK**: Versão 3.8.1 ou superior
4. **Android SDK**: Configurado e funcionando

## Passo 1: Configurar a Keystore

Se você ainda não tem uma keystore, siga as instruções em [KEYSTORE_SETUP.md](./KEYSTORE_SETUP.md).

**IMPORTANTE**: Guarde a keystore e as senhas em local seguro! Você precisará delas para todas as atualizações futuras.

## Passo 2: Atualizar a Versão do App

Antes de cada build, atualize a versão no arquivo `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

O formato é: `versionName+versionCode`
- `versionName`: Versão visível ao usuário (ex: 1.0.0)
- `versionCode`: Número interno que deve ser incrementado a cada publicação (ex: 1, 2, 3...)

**Exemplo**:
- Primeira versão: `1.0.0+1`
- Atualização de correção: `1.0.1+2`
- Nova funcionalidade: `1.1.0+3`

## Passo 3: Verificar Configurações

### 3.1 Verificar key.properties

Certifique-se de que o arquivo `android/key.properties` existe e está configurado:

```properties
storePassword=sua_senha_do_keystore
keyPassword=sua_senha_da_chave
keyAlias=upload
storeFile=C:\\Users\\SeuUsuario\\upload-keystore.jks
```

### 3.2 Verificar Application ID

O Application ID está definido em `android/app/build.gradle.kts`:
- Application ID: `com.financeo.financeo`

Este ID deve ser único e não pode ser alterado após a primeira publicação.

## Passo 4: Build do App Bundle (Recomendado)

O Google Play Store prefere App Bundles (.aab) em vez de APKs. Eles são mais eficientes e permitem que o Google otimize o download para cada dispositivo.

### 4.1 Build do App Bundle

Execute o comando:

```bash
flutter build appbundle --release
```

O arquivo será gerado em:
```
build/app/outputs/bundle/release/app.aab
```

### 4.2 Build com Ofuscação (Opcional mas Recomendado)

Para proteger seu código Dart, use ofuscação:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Importante**: Guarde a pasta `build/app/outputs/symbols`! Você precisará dela para desofuscar stack traces de erros em produção.

## Passo 5: Testar o App Bundle

### 5.1 Teste Local com bundletool

1. Baixe o [bundletool](https://github.com/google/bundletool/releases)
2. Gere APKs de teste:
   ```bash
   java -jar bundletool.jar build-apks --bundle=build/app/outputs/bundle/release/app.aab --output=app.apks
   ```
3. Instale em um dispositivo:
   ```bash
   java -jar bundletool.jar install-apks --apks=app.apks
   ```

### 5.2 Teste no Google Play Console

1. Faça upload do bundle para a trilha de teste interno
2. Teste em dispositivos reais
3. Verifique se tudo funciona corretamente

## Passo 6: Preparar Assets para a Play Store

Antes de publicar, você precisará de:

1. **Ícone do App**: 512x512 pixels (PNG, sem transparência)
2. **Screenshots**: 
   - Telefone: Pelo menos 2, máximo 8 (16:9 ou 9:16)
   - Tablet (opcional): Pelo menos 1
3. **Descrição do App**: Até 4000 caracteres
4. **Descrição Curta**: Até 80 caracteres
5. **Categoria**: Financeira
6. **Classificação de Conteúdo**: Preencha o questionário
7. **Política de Privacidade**: URL obrigatória

## Passo 7: Publicar na Play Store

1. Acesse o [Google Play Console](https://play.google.com/console)
2. Crie um novo app ou selecione um existente
3. Preencha todas as informações obrigatórias
4. Faça upload do App Bundle (.aab)
5. Preencha o formulário de classificação de conteúdo
6. Configure preços e distribuição
7. Revise e publique

## Passo 8: Atualizações Futuras

Para atualizar o app:

1. Atualize a versão no `pubspec.yaml` (incremente o `versionCode`)
2. Execute `flutter build appbundle --release`
3. Faça upload do novo bundle na Play Console
4. Preencha as notas de versão
5. Revise e publique

## Troubleshooting

### Erro: "key.properties não encontrado"

Certifique-se de que o arquivo `android/key.properties` existe e está no diretório `android/`.

### Erro: "Keystore não encontrada"

Verifique o caminho no `key.properties`. No Windows, use barras duplas (`\\`) ou barras normais (`/`).

### Erro: "Senha incorreta"

Verifique as senhas no `key.properties`. Elas devem corresponder às senhas usadas ao criar a keystore.

### App Bundle muito grande

- Use `--split-debug-info` para reduzir o tamanho
- Verifique se há assets desnecessários
- Considere usar App Bundle (o Google otimiza automaticamente)

### Problemas com ProGuard

Se o app crashar após build com ProGuard, verifique o arquivo `proguard-rules.pro` e adicione regras para classes que estão sendo removidas incorretamente.

## Comandos Úteis

```bash
# Build App Bundle
flutter build appbundle --release

# Build com ofuscação
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Build APK (não recomendado para Play Store)
flutter build apk --release --split-per-abi

# Verificar versão atual
flutter --version

# Limpar build anterior
flutter clean

# Verificar configuração
flutter doctor -v
```

## Recursos Adicionais

- [Documentação Flutter - Android Deployment](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Bundle Guide](https://developer.android.com/guide/app-bundle)

## Checklist Final Antes de Publicar

- [ ] Keystore configurada e testada
- [ ] Versão atualizada no `pubspec.yaml`
- [ ] App Bundle gerado e testado
- [ ] Todos os assets preparados (ícone, screenshots)
- [ ] Descrição e metadados preenchidos
- [ ] Política de privacidade disponível
- [ ] Classificação de conteúdo preenchida
- [ ] App testado em dispositivos reais
- [ ] Nenhum erro crítico conhecido

---

**Boa sorte com a publicação! 🚀**

