# Script para build de release do Financeo para Google Play Store
# Uso: .\scripts\build_release.ps1 [--obfuscate]

param(
    [switch]$Obfuscate = $false
)

Write-Host "🚀 Iniciando build de release para Google Play Store..." -ForegroundColor Green
Write-Host ""

# Verificar se está no diretório raiz do projeto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Erro: Execute este script a partir do diretório raiz do projeto!" -ForegroundColor Red
    exit 1
}

# Verificar se key.properties existe
if (-not (Test-Path "android\key.properties")) {
    Write-Host "⚠️  AVISO: Arquivo android\key.properties não encontrado!" -ForegroundColor Yellow
    Write-Host "   O build será assinado com a keystore de debug." -ForegroundColor Yellow
    Write-Host "   Para produção, configure a keystore seguindo KEYSTORE_SETUP.md" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($continue -ne "s" -and $continue -ne "S") {
        Write-Host "Build cancelado." -ForegroundColor Yellow
        exit 0
    }
}

# Verificar Flutter
Write-Host "📦 Verificando Flutter..." -ForegroundColor Cyan
flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro: Flutter não encontrado!" -ForegroundColor Red
    exit 1
}

# Limpar build anterior
Write-Host ""
Write-Host "🧹 Limpando build anterior..." -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao limpar build!" -ForegroundColor Red
    exit 1
}

# Obter dependências
Write-Host ""
Write-Host "📥 Obtendo dependências..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao obter dependências!" -ForegroundColor Red
    exit 1
}

# Ler versão do pubspec.yaml
Write-Host ""
Write-Host "📋 Verificando versão..." -ForegroundColor Cyan
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -match "version:\s*([\d.]+)\+(\d+)") {
    $versionName = $matches[1]
    $versionCode = $matches[2]
    Write-Host "   Versão: $versionName (Build: $versionCode)" -ForegroundColor Green
} else {
    Write-Host "⚠️  Não foi possível ler a versão do pubspec.yaml" -ForegroundColor Yellow
}

# Build do App Bundle
Write-Host ""
if ($Obfuscate) {
    Write-Host "🔒 Construindo App Bundle com ofuscação..." -ForegroundColor Cyan
    Write-Host "   (Isso pode levar alguns minutos)" -ForegroundColor Gray
    
    # Criar diretório de símbolos se não existir
    $symbolsDir = "build\app\outputs\symbols"
    if (-not (Test-Path $symbolsDir)) {
        New-Item -ItemType Directory -Path $symbolsDir -Force | Out-Null
    }
    
    flutter build appbundle --release --obfuscate --split-debug-info=$symbolsDir
} else {
    Write-Host "📦 Construindo App Bundle..." -ForegroundColor Cyan
    Write-Host "   (Isso pode levar alguns minutos)" -ForegroundColor Gray
    flutter build appbundle --release
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Erro ao construir App Bundle!" -ForegroundColor Red
    exit 1
}

# Verificar se o arquivo foi criado
$bundlePath = "build\app\outputs\bundle\release\app.aab"
if (Test-Path $bundlePath) {
    $fileInfo = Get-Item $bundlePath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    Write-Host ""
    Write-Host "✅ Build concluído com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Arquivo gerado:" -ForegroundColor Cyan
    Write-Host "   $bundlePath" -ForegroundColor White
    Write-Host "   Tamanho: $fileSizeMB MB" -ForegroundColor White
    Write-Host ""
    
    if ($Obfuscate) {
        Write-Host "🔒 Arquivos de símbolos (para desofuscar erros):" -ForegroundColor Cyan
        Write-Host "   build\app\outputs\symbols" -ForegroundColor White
        Write-Host "   ⚠️  GUARDE ESTA PASTA! Você precisará dela para desofuscar stack traces." -ForegroundColor Yellow
        Write-Host ""
    }
    
    Write-Host "📤 Próximos passos:" -ForegroundColor Cyan
    Write-Host "   1. Acesse o Google Play Console" -ForegroundColor White
    Write-Host "   2. Faça upload do arquivo app.aab" -ForegroundColor White
    Write-Host "   3. Preencha as informações necessárias" -ForegroundColor White
    Write-Host "   4. Revise e publique" -ForegroundColor White
    Write-Host ""
    Write-Host "📖 Para mais informações, consulte PLAY_STORE_DEPLOY.md" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Erro: App Bundle não foi gerado!" -ForegroundColor Red
    exit 1
}

