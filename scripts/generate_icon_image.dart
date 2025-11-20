import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final backgroundColor = img.ColorRgb8(8, 191, 98); // #08BF62
  final textColor = img.ColorRgb8(255, 255, 255); // Branco

  // Cria uma imagem com fundo verde
  final image = img.Image(width: size, height: size);
  
  // Preenche com a cor de fundo
  img.fill(image, color: backgroundColor);
  
  // Adiciona o texto "FA" usando drawString
  // O pacote image tem suporte básico para texto
  try {
    img.drawString(
      image,
      'FA',
      font: img.arial24, // Fonte padrão
      x: (size / 2 - 60).toInt(), // Aproximadamente centralizado
      y: (size / 2 - 30).toInt(),
      color: textColor,
    );
  } catch (e) {
    // Se não conseguir desenhar o texto, pelo menos temos o fundo verde
    print('Aviso: Não foi possível adicionar o texto. A imagem foi criada apenas com o fundo verde.');
    print('Você pode adicionar o texto "FA" manualmente usando um editor de imagens.');
  }
  
  // Salva a imagem
  final file = File('assets/images/app_icon.png');
  file.createSync(recursive: true);
  final pngBytes = Uint8List.fromList(img.encodePng(image));
  file.writeAsBytesSync(pngBytes);
  
  print('Ícone gerado em: ${file.path}');
  print('Tamanho: ${size}x${size}px');
  print('Cor de fundo: #08BF62 (verde)');
}

