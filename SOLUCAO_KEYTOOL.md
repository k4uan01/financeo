# Solução: keytool não encontrado

Se você recebeu o erro `keytool : O termo 'keytool' não é reconhecido`, siga estas soluções:

## Solução Rápida (Recomendada)

Use o script que procura o keytool automaticamente:

```powershell
.\scripts\generate_keystore.ps1
```

Este script encontra o keytool mesmo que ele não esteja no PATH.

## Solução 1: Adicionar Java ao PATH

Execute o script que adiciona o Java ao PATH automaticamente:

```powershell
.\scripts\add_java_to_path.ps1
```

**Importante**: Feche e reabra o terminal após executar o script.

## Solução 2: Encontrar o keytool Manualmente

Execute o script para encontrar onde o keytool está instalado:

```powershell
.\scripts\find_keytool.ps1
```

Este script mostrará todos os locais onde o keytool foi encontrado.

## Solução 3: Instalar Java JDK

Se o Java não estiver instalado, você tem duas opções:

### Opção A: Android Studio (Recomendado para Flutter)
**Por que Android Studio?**
- O Android Studio JÁ VEM com o Java JDK incluído (não precisa instalar Java separadamente)
- É necessário para desenvolvimento Flutter/Android mesmo
- Configura tudo automaticamente

**Passos:**
1. Baixe: https://developer.android.com/studio
2. Instale o Android Studio
3. O Java JDK já estará disponível dentro do Android Studio
4. Execute `.\scripts\add_java_to_path.ps1` para adicionar ao PATH do sistema

**Onde o Java fica no Android Studio:**
- Normalmente em: `C:\Users\SeuUsuario\AppData\Local\Android\Sdk\jbr\bin\`
- Ou: `C:\Program Files\Android\Android Studio\jbr\bin\`

### Opção B: Java JDK Separado (Se não quiser Android Studio)
**Use esta opção apenas se:**
- Você não vai desenvolver para Android
- Você só precisa do Java para gerar a keystore

**Passos:**
1. Baixe: https://adoptium.net/temurin/releases/ (escolha Windows x64)
2. Instale o JDK
3. Execute `.\scripts\add_java_to_path.ps1` para adicionar ao PATH

## Solução 4: Usar Caminho Completo

Se você souber onde o keytool está, use o caminho completo:

```powershell
# Exemplo (ajuste o caminho):
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

## Verificação

Após resolver, verifique se funciona:

```powershell
keytool -help
```

Se mostrar a ajuda do keytool, está funcionando! ✅

## Próximos Passos

Depois de resolver o problema do keytool:

1. Gere a keystore:
   ```powershell
   .\scripts\generate_keystore.ps1
   ```

2. Configure o `android/key.properties` com as informações da keystore

3. Faça o build:
   ```powershell
   .\scripts\build_release.ps1 --obfuscate
   ```

---

**Dica**: O script `generate_keystore.ps1` é a forma mais fácil, pois encontra o keytool automaticamente mesmo que não esteja no PATH!

