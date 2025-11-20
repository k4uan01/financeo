import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  const backgroundColor = 0xFF08BF62; // Verde #08BF62
  const textColor = 0xFFFFFFFF; // Branco
  const borderRadius = 24.0;

  // Cria uma imagem com fundo verde
  final image = img.Image(width: size, height: size);
  
  // Preenche com a cor de fundo
  img.fill(image, color: backgroundColor);
  
  // Aplica bordas arredondadas (simplificado - preenche os cantos)
  // Para uma implementação completa de bordas arredondadas, seria necessário
  // usar uma máscara, mas para o ícone launcher isso pode não ser crítico
  // já que o sistema operacional pode aplicar suas próprias bordas arredondadas
  
  // Adiciona o texto "FA"
  // Nota: O pacote image tem suporte limitado para texto
  // Vamos criar um texto simples usando formas básicas
  // Para um resultado melhor, seria necessário usar uma fonte bitmap
  
  // Por enquanto, vamos criar um placeholder simples
  // O ideal seria usar uma ferramenta externa ou um serviço online
  
  // Salva a imagem
  final file = File('assets/images/app_icon.png');
  file.createSync(recursive: true);
  final pngBytes = Uint8List.fromList(img.encodePng(image));
  file.writeAsBytesSync(pngBytes);
  
  print('Ícone base gerado. Para melhor resultado, adicione manualmente o texto "FA"');
  print('ou use uma ferramenta de edição de imagens.');
  print('Arquivo salvo em: ${file.path}');
}

