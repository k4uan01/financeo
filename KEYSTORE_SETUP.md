# Configuração de Keystore para Android

Este guia explica como gerar uma keystore para assinar o aplicativo Android do Financeo.

## Pré-requisitos

Você precisa ter o Java JDK instalado. O `keytool` faz parte do JDK.

### Opção 1: Instalar Android Studio (Recomendado)

1. Baixe o Android Studio: https://developer.android.com/studio
2. Durante a instalação, o Android Studio instalará automaticamente o JDK
3. Após a instalação, execute `flutter doctor` para verificar se tudo está configurado

### Opção 2: Instalar Java JDK Separadamente

1. Baixe o JDK da Adoptium: https://adoptium.net/temurin/releases/
2. Instale o JDK
3. Adicione o Java ao PATH do sistema:
   - Adicione `C:\Program Files\Eclipse Adoptium\jdk-XX.X.X-hotspot\bin` ao PATH
   - Ou defina a variável `JAVA_HOME`

## Gerando a Keystore

### Método 1: Usando o Script PowerShell (Recomendado)

Execute o script fornecido:

```powershell
.\scripts\generate_keystore.ps1
```

O script irá:
- Procurar automaticamente o `keytool` no sistema
- Solicitar informações do certificado (ou usar valores padrão)
- Gerar a keystore em `%USERPROFILE%\upload-keystore.jks`

### Método 2: Comando Manual

Se você souber onde está o `keytool`, execute:

```powershell
$keytoolPath = "C:\caminho\para\java\bin\keytool.exe"

& $keytoolPath -genkey -v `
    -keystore $env:USERPROFILE\upload-keystore.jks `
    -alias upload `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -storepass android `
    -keypass android `
    -dname "CN=Financeo, OU=Development, O=Financeo, L=São Paulo, ST=SP, C=BR"
```

**IMPORTANTE**: Altere as senhas (`android`) por senhas seguras em produção!

## Configurando o Build

Após gerar a keystore, você precisa configurar o projeto para usá-la:

1. Crie o arquivo `android/key.properties`:

```properties
storePassword=sua_senha_do_keystore
keyPassword=sua_senha_da_chave
keyAlias=upload
storeFile=C:\\Users\\SeuUsuario\\upload-keystore.jks
```

2. Atualize o `android/app/build.gradle.kts` para usar a keystore em builds de release.

## Segurança

⚠️ **NUNCA** commite a keystore ou o arquivo `key.properties` no Git!

- Adicione `*.jks` e `key.properties` ao `.gitignore`
- Guarde a keystore e as senhas em local seguro
- Você precisará da mesma keystore para todas as atualizações do app na Play Store

## Troubleshooting

### "keytool não é reconhecido"

- Verifique se o Java JDK está instalado
- Verifique se o Java está no PATH
- Use o caminho completo do `keytool.exe`
- Execute o script `generate_keystore.ps1` que procura automaticamente

### "Android SDK não encontrado"

Execute:
```bash
flutter config --android-sdk C:\caminho\para\Android\Sdk
```

Ou instale o Android Studio que configurará automaticamente.

