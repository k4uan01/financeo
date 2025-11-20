# Script para gerar keystore para assinatura do aplicativo Android
# Este script tenta localizar o keytool e gerar a keystore

Write-Host "=== Gerador de Keystore para Financeo ===" -ForegroundColor Green
Write-Host ""

# Função para encontrar o keytool
function Find-Keytool {
    Write-Host "Procurando keytool em locais comuns..." -ForegroundColor Gray
    
    # Lista expandida de possíveis locais
    $searchPaths = @()
    
    # JAVA_HOME
    if ($env:JAVA_HOME) {
        $searchPaths += "$env:JAVA_HOME\bin\keytool.exe"
    }
    
    # Locais padrão do Java
    $searchPaths += @(
        "$env:ProgramFiles\Java\*\bin\keytool.exe",
        "$env:ProgramFiles(x86)\Java\*\bin\keytool.exe",
        "$env:ProgramFiles\Eclipse Adoptium\*\bin\keytool.exe",
        "$env:ProgramFiles\Microsoft\jdk-*\bin\keytool.exe",
        "$env:ProgramFiles\Amazon Corretto\*\bin\keytool.exe"
    )
    
    # Android Studio / Android SDK
    $androidStudioPaths = @(
        "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe",
        "$env:LOCALAPPDATA\Android\Sdk\jre\bin\keytool.exe",
        "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
        "$env:ProgramFiles\Android\Android Studio\jre\bin\keytool.exe",
        "$env:ProgramFiles(x86)\Android\Android Studio\jbr\bin\keytool.exe"
    )
    $searchPaths += $androidStudioPaths
    
    # Busca recursiva em locais comuns
    $commonSearchDirs = @(
        "$env:ProgramFiles",
        "$env:ProgramFiles(x86)",
        "$env:LOCALAPPDATA",
        "$env:USERPROFILE"
    )
    
    foreach ($path in $searchPaths) {
        try {
            # Expande wildcards
            $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
            if ($resolved) {
                if ($resolved -is [Array]) {
                    $resolved = $resolved[0]
                }
                if (Test-Path $resolved.Path) {
                    Write-Host "  ✓ Encontrado: $($resolved.Path)" -ForegroundColor Green
                    return $resolved.Path
                }
            }
        } catch {
            # Continua procurando
        }
    }
    
    # Busca recursiva mais profunda em locais específicos
    Write-Host "Buscando recursivamente..." -ForegroundColor Gray
    foreach ($dir in $commonSearchDirs) {
        if (Test-Path $dir) {
            try {
                $found = Get-ChildItem -Path $dir -Recurse -Filter "keytool.exe" -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 1
                if ($found) {
                    Write-Host "  ✓ Encontrado: $($found.FullName)" -ForegroundColor Green
                    return $found.FullName
                }
            } catch {
                # Continua procurando
            }
        }
    }
    
    # Tenta encontrar via Get-Command (se estiver no PATH)
    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if ($keytool) {
        Write-Host "  ✓ Encontrado no PATH: $($keytool.Path)" -ForegroundColor Green
        return $keytool.Path
    }
    
    return $null
}

# Tenta encontrar o keytool
Write-Host "Procurando keytool..." -ForegroundColor Yellow
$keytoolPath = Find-Keytool

if (-not $keytoolPath) {
    Write-Host ""
    Write-Host "ERRO: keytool não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "O keytool faz parte do Java JDK. Você precisa:" -ForegroundColor Yellow
    Write-Host "1. Instalar o Android Studio (recomendado):" -ForegroundColor Cyan
    Write-Host "   https://developer.android.com/studio"
    Write-Host ""
    Write-Host "2. OU instalar o Java JDK separadamente:" -ForegroundColor Cyan
    Write-Host "   https://adoptium.net/temurin/releases/"
    Write-Host ""
    Write-Host "3. Depois de instalar, adicione o Java ao PATH ou execute este script novamente."
    Write-Host ""
    Write-Host "Alternativamente, você pode usar o caminho completo do keytool:" -ForegroundColor Yellow
    Write-Host '   $keytoolPath = "C:\caminho\para\java\bin\keytool.exe"'
    Write-Host ""
    exit 1
}

Write-Host "keytool encontrado em: $keytoolPath" -ForegroundColor Green
Write-Host ""

# Configurações da keystore
$keystorePath = "$env:USERPROFILE\upload-keystore.jks"
$alias = "upload"
$keyPassword = "android"
$storePassword = "android"
$validity = 10000

Write-Host "Configurações da keystore:" -ForegroundColor Cyan
Write-Host "  Caminho: $keystorePath"
Write-Host "  Alias: $alias"
Write-Host "  Senha da chave: $keyPassword"
Write-Host "  Senha do keystore: $storePassword"
Write-Host "  Validade: $validity dias"
Write-Host ""

# Verifica se a keystore já existe
if (Test-Path $keystorePath) {
    Write-Host "AVISO: A keystore já existe em: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Deseja sobrescrever? (s/N)"
    if ($overwrite -ne "s" -and $overwrite -ne "S") {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        exit 0
    }
}

# Solicita informações do certificado
Write-Host "Informações do certificado (pressione Enter para usar valores padrão):" -ForegroundColor Cyan
$cn = Read-Host "Nome completo (CN) [Financeo]"
if ([string]::IsNullOrWhiteSpace($cn)) { $cn = "Financeo" }

$ou = Read-Host "Unidade organizacional (OU) [Development]"
if ([string]::IsNullOrWhiteSpace($ou)) { $ou = "Development" }

$o = Read-Host "Organização (O) [Financeo]"
if ([string]::IsNullOrWhiteSpace($o)) { $o = "Financeo" }

$l = Read-Host "Cidade (L) [São Paulo]"
if ([string]::IsNullOrWhiteSpace($l)) { $l = "São Paulo" }

$st = Read-Host "Estado (ST) [SP]"
if ([string]::IsNullOrWhiteSpace($st)) { $st = "SP" }

$c = Read-Host "País (C) [BR]"
if ([string]::IsNullOrWhiteSpace($c)) { $c = "BR" }

# Gera a keystore
Write-Host ""
Write-Host "Gerando keystore..." -ForegroundColor Yellow

$dname = "CN=$cn, OU=$ou, O=$o, L=$l, ST=$st, C=$c"

& $keytoolPath -genkey -v `
    -keystore $keystorePath `
    -alias $alias `
    -keyalg RSA `
    -keysize 2048 `
    -validity $validity `
    -storepass $storePassword `
    -keypass $keyPassword `
    -dname $dname

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Keystore gerada com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Localização: $keystorePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "IMPORTANTE: Guarde este arquivo e as senhas em local seguro!" -ForegroundColor Yellow
    Write-Host "Você precisará deles para publicar atualizações do aplicativo na Play Store."
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Cyan
    Write-Host "1. Adicione as informações da keystore ao arquivo android/key.properties"
    Write-Host "2. Configure o build.gradle.kts para usar a keystore em builds de release"
} else {
    Write-Host ""
    Write-Host "ERRO: Falha ao gerar keystore!" -ForegroundColor Red
    exit 1
}

