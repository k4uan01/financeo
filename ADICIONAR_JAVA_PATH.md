# Como Adicionar Java ao PATH no Windows

Este guia explica como adicionar o Java JDK ao PATH do Windows para que você possa usar comandos como `java` e `keytool` de qualquer lugar.

## Método 1: Script Automático (Recomendado)

Execute o script PowerShell fornecido:

```powershell
.\scripts\add_java_to_path.ps1
```

O script irá:
- Procurar automaticamente instalações do Java no seu sistema
- Permitir que você escolha qual instalação adicionar
- Adicionar ao PATH automaticamente

**Nota**: Para modificar o PATH do sistema (todos os usuários), execute o PowerShell como Administrador.

## Método 2: Manualmente via Interface Gráfica

### Passo 1: Encontrar o Caminho do Java

Primeiro, você precisa encontrar onde o Java está instalado. Locais comuns:

- `C:\Program Files\Java\jdk-XX.X.X\bin`
- `C:\Program Files\Eclipse Adoptium\jdk-XX.X.X-hotspot\bin`
- `%LOCALAPPDATA%\Android\Sdk\jbr\bin` (se tiver Android Studio)
- `C:\Program Files\Android\Android Studio\jbr\bin`

### Passo 2: Abrir Configurações do Sistema

1. Pressione `Win + X` e escolha **Sistema**
2. Ou vá em **Configurações** > **Sistema** > **Sobre**
3. Clique em **Configurações avançadas do sistema** (no lado direito)

### Passo 3: Editar Variáveis de Ambiente

1. Na janela **Propriedades do Sistema**, clique em **Variáveis de Ambiente**
2. Na seção **Variáveis do sistema** (ou **Variáveis de usuário**), encontre a variável `Path`
3. Selecione `Path` e clique em **Editar**

### Passo 4: Adicionar o Caminho do Java

1. Clique em **Novo**
2. Cole o caminho completo para a pasta `bin` do Java (ex: `C:\Program Files\Java\jdk-21\bin`)
3. Clique em **OK** em todas as janelas

### Passo 5: Verificar

1. Feche todos os terminais/PowerShell abertos
2. Abra um novo PowerShell
3. Execute:
   ```powershell
   java -version
   keytool -help
   ```

Se funcionar, o Java foi adicionado corretamente!

## Método 3: Via PowerShell (Linha de Comando)

### Para o Usuário Atual

```powershell
# Substitua pelo caminho real do seu Java
$javaPath = "C:\Program Files\Java\jdk-21\bin"

# Adiciona ao PATH do usuário atual
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $currentPath + ";" + $javaPath
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "Java adicionado ao PATH. Feche e reabra o terminal."
```

### Para Todos os Usuários (Requer Administrador)

```powershell
# Execute o PowerShell como Administrador primeiro!

# Substitua pelo caminho real do seu Java
$javaPath = "C:\Program Files\Java\jdk-21\bin"

# Adiciona ao PATH do sistema
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $currentPath + ";" + $javaPath
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Write-Host "Java adicionado ao PATH do sistema. Feche e reabra o terminal."
```

## Método 4: Definir JAVA_HOME (Opcional mas Recomendado)

Além de adicionar ao PATH, é recomendado definir a variável `JAVA_HOME`:

### Via Interface Gráfica

1. Abra **Variáveis de Ambiente** (como no Método 2)
2. Clique em **Novo** (em Variáveis do sistema ou do usuário)
3. Nome da variável: `JAVA_HOME`
4. Valor da variável: Caminho para a pasta do JDK (sem `\bin`), ex: `C:\Program Files\Java\jdk-21`
5. Clique em **OK**

### Via PowerShell

```powershell
# Para o usuário atual
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-21", "User")

# Para todos os usuários (requer Admin)
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-21", "Machine")
```

## Verificação

Após adicionar ao PATH, **feche e reabra o terminal** e execute:

```powershell
# Verificar Java
java -version

# Verificar keytool
keytool -help

# Verificar JAVA_HOME (se definido)
echo $env:JAVA_HOME
```

## Troubleshooting

### "O comando ainda não funciona após adicionar ao PATH"

- **Feche e reabra** todos os terminais/PowerShell
- Reinicie o computador se necessário
- Verifique se o caminho está correto (deve apontar para a pasta `bin`)

### "Não encontro onde o Java está instalado"

Execute o script `add_java_to_path.ps1` que procura automaticamente, ou:

```powershell
# Procurar por java.exe
Get-ChildItem -Path "C:\Program Files" -Recurse -Filter "java.exe" -ErrorAction SilentlyContinue | Select-Object FullName

# Procurar por keytool.exe
Get-ChildItem -Path "C:\Program Files" -Recurse -Filter "keytool.exe" -ErrorAction SilentlyContinue | Select-Object FullName
```

### "Preciso instalar o Java primeiro"

1. **Android Studio** (recomendado): https://developer.android.com/studio
2. **Eclipse Adoptium**: https://adoptium.net/temurin/releases/
3. **Oracle JDK**: https://www.oracle.com/java/technologies/downloads/

## Dicas

- Use o **PATH do usuário** se você não tiver permissões de administrador
- O **PATH do sistema** afeta todos os usuários do computador
- Sempre adicione a pasta `bin` do Java, não a pasta raiz do JDK
- Defina `JAVA_HOME` apontando para a pasta raiz do JDK (sem `\bin`)

