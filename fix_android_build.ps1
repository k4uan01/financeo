# Script para limpar e reconstruir o projeto Android
Write-Host "🧹 Limpando projeto Flutter..." -ForegroundColor Cyan
flutter clean

Write-Host "📦 Obtendo dependências..." -ForegroundColor Cyan
flutter pub get

Write-Host "🗑️ Limpando cache do Gradle..." -ForegroundColor Cyan
if (Test-Path "android\.gradle") {
    Remove-Item -Recurse -Force "android\.gradle"
}
if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build"
}
if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build"
}

Write-Host "🔨 Tentando build do APK..." -ForegroundColor Cyan
flutter build apk

Write-Host "✅ Concluído!" -ForegroundColor Green

