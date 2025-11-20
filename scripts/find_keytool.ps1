# Script para encontrar e mostrar o caminho do keytool
# Util quando keytool nao esta no PATH

Write-Host "=== Localizador de Keytool ===" -ForegroundColor Green
Write-Host ""

# Funcao para encontrar o keytool
function Find-Keytool {
    Write-Host "Procurando keytool..." -ForegroundColor Yellow
    
    $found = @()
    
    # JAVA_HOME
    if ($env:JAVA_HOME) {
        $path = "$env:JAVA_HOME\bin\keytool.exe"
        if (Test-Path $path) {
            $found += $path
        }
    }
    
    # Locais padrao do Java
    $searchLocations = @(
        "$env:ProgramFiles\Java",
        "$env:ProgramFiles(x86)\Java",
        "$env:ProgramFiles\Eclipse Adoptium",
        "$env:ProgramFiles\Microsoft",
        "$env:ProgramFiles\Amazon Corretto",
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:ProgramFiles\Android\Android Studio"
    )
    
    foreach ($baseDir in $searchLocations) {
        if (Test-Path $baseDir) {
            try {
                $keytools = Get-ChildItem -Path $baseDir -Recurse -Filter "keytool.exe" -ErrorAction SilentlyContinue -Depth 4
                foreach ($kt in $keytools) {
                    if ($kt.FullName -notin $found) {
                        $found += $kt.FullName
                    }
                }
            } catch {
                # Continua procurando
            }
        }
    }
    
    # Tenta encontrar via Get-Command (se estiver no PATH)
    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if ($keytool) {
        if ($keytool.Path -notin $found) {
            $found += $keytool.Path
        }
    }
    
    return $found
}

$keytools = Find-Keytool

if ($keytools.Count -eq 0) {
    Write-Host "ERRO: keytool nao encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solucoes:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Adicionar Java ao PATH:" -ForegroundColor Cyan
    Write-Host "   .\scripts\add_java_to_path.ps1"
    Write-Host ""
    Write-Host "2. Instalar Java JDK:" -ForegroundColor Cyan
    Write-Host "   - Android Studio: https://developer.android.com/studio"
    Write-Host "   - Eclipse Adoptium: https://adoptium.net/temurin/releases/"
    Write-Host ""
    Write-Host "3. Usar o script generate_keystore.ps1 que procura automaticamente:"
    Write-Host "   .\scripts\generate_keystore.ps1"
    Write-Host ""
    exit 1
}

Write-Host "OK: keytool encontrado em:" -ForegroundColor Green
Write-Host ""

for ($i = 0; $i -lt $keytools.Count; $i++) {
    $path = $keytools[$i]
    Write-Host "  [$($i + 1)] $path" -ForegroundColor Cyan
    
    # Verifica se esta no PATH
    $envPath = $env:Path -split ';'
    $binPath = Split-Path $path -Parent
    if ($binPath -in $envPath) {
        Write-Host "      OK - Esta no PATH" -ForegroundColor Green
    } else {
        Write-Host "      X - NAO esta no PATH" -ForegroundColor Yellow
    }
}

Write-Host ""

if ($keytools.Count -eq 1) {
    $selected = $keytools[0]
} else {
    Write-Host "Multiplas instalacoes encontradas." -ForegroundColor Yellow
    $selection = Read-Host "Qual deseja usar? (1-$($keytools.Count))"
    $selectedIndex = [int]$selection - 1
    if ($selectedIndex -lt 0 -or $selectedIndex -ge $keytools.Count) {
        Write-Host "Selecao invalida!" -ForegroundColor Red
        exit 1
    }
    $selected = $keytools[$selectedIndex]
}

Write-Host ""
Write-Host "Usando: $selected" -ForegroundColor Green
Write-Host ""

# Verifica se esta no PATH
$binPath = Split-Path $selected -Parent
$envPath = $env:Path -split ';'
if ($binPath -notin $envPath) {
    Write-Host "AVISO: Este keytool NAO esta no PATH." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opcoes:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Adicionar ao PATH automaticamente:" -ForegroundColor White
    Write-Host "   .\scripts\add_java_to_path.ps1"
    Write-Host ""
    Write-Host "2. Usar o caminho completo diretamente:" -ForegroundColor White
    Write-Host "   `"$selected`" -genkey -v ..."
    Write-Host ""
    Write-Host "3. Usar o script generate_keystore.ps1 (recomendado):" -ForegroundColor White
    Write-Host "   .\scripts\generate_keystore.ps1"
    Write-Host "   (Ele usa este caminho automaticamente)"
    Write-Host ""
} else {
    Write-Host "OK: Este keytool esta no PATH e pode ser usado diretamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Teste com:" -ForegroundColor Cyan
    Write-Host "   keytool -help"
}
