#!/bin/bash
set -e

echo "=== Iniciando build do Flutter Web ==="

# Instalar Flutter se não estiver disponível
if ! command -v flutter &> /dev/null; then
    echo "Flutter não encontrado. Instalando..."
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git || exit 1
    export PATH="$PATH:$(pwd)/flutter/bin"
    echo "Flutter instalado. Verificando..."
    flutter --version || exit 1
fi

echo "Configurando Flutter para web..."
flutter config --enable-web || echo "Aviso: config --enable-web falhou, continuando..."

echo "Obtendo dependências..."
flutter pub get || exit 1

echo "Fazendo build para produção..."
flutter build web --release --web-renderer canvaskit || exit 1

echo "=== Build concluído com sucesso! ==="
ls -la build/web/ || exit 1

