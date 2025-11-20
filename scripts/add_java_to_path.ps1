# Script para adicionar Java ao PATH do Windows
# Execute como Administrador para modificar o PATH do sistema

Write-Host "=== Adicionar Java ao PATH ===" -ForegroundColor Green
Write-Host ""

# Verifica se esta executando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "AVISO: Este script precisa ser executado como Administrador para modificar o PATH do sistema." -ForegroundColor Yellow
    Write-Host "Voce pode modificar apenas o PATH do usuario atual." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Deseja continuar apenas para o usuario atual? (S/n)"
    if ($continue -eq "n" -or $continue -eq "N") {
        exit 0
    }
    $scope = "User"
} else {
    Write-Host "Executando como Administrador - modificando PATH do sistema." -ForegroundColor Green
    $scope = "Machine"
}

# Funcao para encontrar instalacoes do Java
function Find-JavaInstallations {
    $javaPaths = @()
    
    # Locais comuns do Java
    $searchPaths = @(
        "$env:ProgramFiles\Java",
        "$env:ProgramFiles(x86)\Java",
        "$env:LOCALAPPDATA\Programs\Eclipse Adoptium",
        "C:\Program Files\Eclipse Adoptium",
        "C:\Program Files\Java",
        "$env:LOCALAPPDATA\Android\Sdk\jbr",
        "$env:LOCALAPPDATA\Android\Sdk\jre",
        "C:\Program Files\Android\Android Studio\jbr",
        "C:\Program Files\Android\Android Studio\jre"
    )
    
    foreach ($basePath in $searchPaths) {
        if (Test-Path $basePath) {
            # Procura por subpastas que contenham bin\java.exe
            $jdkFolders = Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue
            foreach ($folder in $jdkFolders) {
                $javaExe = Join-Path $folder.FullName "bin\java.exe"
                if (Test-Path $javaExe) {
                    $binPath = Join-Path $folder.FullName "bin"
                    if ($binPath -notin $javaPaths) {
                        $javaPaths += $binPath
                    }
                }
            }
            
            # Tambem verifica se ha java.exe diretamente em bin
            $directBin = Join-Path $basePath "bin\java.exe"
            if (Test-Path $directBin) {
                $binPath = Join-Path $basePath "bin"
                if ($binPath -notin $javaPaths) {
                    $javaPaths += $binPath
                }
            }
        }
    }
    
    return $javaPaths
}

Write-Host "Procurando instalacoes do Java..." -ForegroundColor Yellow
$javaInstallations = Find-JavaInstallations

if ($javaInstallations.Count -eq 0) {
    Write-Host ""
    Write-Host "Nenhuma instalacao do Java encontrada!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, instale o Java JDK primeiro:" -ForegroundColor Yellow
    Write-Host "1. Android Studio (recomendado): https://developer.android.com/studio" -ForegroundColor Cyan
    Write-Host "2. Eclipse Adoptium: https://adoptium.net/temurin/releases/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ou informe o caminho manualmente:" -ForegroundColor Yellow
    $manualPath = Read-Host "Caminho completo para a pasta bin do Java (ex: C:\Program Files\Java\jdk-21\bin)"
    
    if ([string]::IsNullOrWhiteSpace($manualPath)) {
        Write-Host "Operacao cancelada." -ForegroundColor Yellow
        exit 0
    }
    
    if (-not (Test-Path $manualPath)) {
        Write-Host "ERRO: Caminho nao encontrado: $manualPath" -ForegroundColor Red
        exit 1
    }
    
    if (-not (Test-Path (Join-Path $manualPath "java.exe"))) {
        Write-Host "ERRO: java.exe nao encontrado em: $manualPath" -ForegroundColor Red
        exit 1
    }
    
    $javaInstallations = @($manualPath)
}

Write-Host ""
Write-Host "Instalacoes do Java encontradas:" -ForegroundColor Green
for ($i = 0; $i -lt $javaInstallations.Count; $i++) {
    Write-Host "  [$($i + 1)] $($javaInstallations[$i])" -ForegroundColor Cyan
}

if ($javaInstallations.Count -gt 1) {
    Write-Host ""
    $selection = Read-Host "Qual instalacao deseja adicionar ao PATH? (1-$($javaInstallations.Count))"
    $selectedIndex = [int]$selection - 1
    if ($selectedIndex -lt 0 -or $selectedIndex -ge $javaInstallations.Count) {
        Write-Host "Selecao invalida!" -ForegroundColor Red
        exit 1
    }
    $javaPath = $javaInstallations[$selectedIndex]
} else {
    $javaPath = $javaInstallations[0]
}

Write-Host ""
Write-Host "Adicionando ao PATH: $javaPath" -ForegroundColor Yellow

# Obtem o PATH atual
$currentPath = [Environment]::GetEnvironmentVariable("Path", $scope)

# Verifica se ja esta no PATH
if ($currentPath -split ';' -contains $javaPath) {
    Write-Host "Este caminho ja esta no PATH!" -ForegroundColor Yellow
    exit 0
}

# Adiciona ao PATH
$newPath = $currentPath + ";" + $javaPath
[Environment]::SetEnvironmentVariable("Path", $newPath, $scope)

Write-Host ""
Write-Host "Java adicionado ao PATH com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Yellow
Write-Host "- Feche e reabra o terminal/PowerShell para que as mudancas tenham efeito"
Write-Host "- Ou execute: refreshenv (se tiver Chocolatey instalado)"
Write-Host ""
Write-Host "Para verificar, execute em um novo terminal:" -ForegroundColor Cyan
Write-Host "  java -version"
Write-Host "  keytool -help"
