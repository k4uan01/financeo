import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  // Inicializa o binding do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Cria a imagem do ícone
  const size = 1024.0;
  const borderRadius = 24.0;
  const backgroundColor = Color(0xFF08BF62);

  // Cria um PictureRecorder para capturar o desenho
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Desenha o fundo verde com bordas arredondadas
  final rect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, size, size),
    const Radius.circular(borderRadius),
  );
  final paint = Paint()..color = backgroundColor;
  canvas.drawRRect(rect, paint);

  // Desenha o texto "FA"
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'FA',
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.3, // 30% do tamanho da imagem
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );

  // Finaliza o desenho
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  // Salva a imagem
  final file = File('assets/images/app_icon.png');
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);

  print('Ícone gerado com sucesso em: ${file.path}');
}

