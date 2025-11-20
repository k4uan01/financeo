#!/usr/bin/env python3
"""
Script para gerar o ícone launcher do aplicativo Financeo
Gera uma imagem PNG 1024x1024px com container verde (#08BF62) e texto "FA" branco
"""

from PIL import Image, ImageDraw, ImageFont
import os

def generate_icon():
    # Configurações
    size = 1024
    background_color = (8, 191, 98)  # #08BF62 em RGB
    text_color = (255, 255, 255)  # Branco
    border_radius = 24
    
    # Cria a imagem
    img = Image.new('RGB', (size, size), background_color)
    draw = ImageDraw.Draw(img)
    
    # Desenha o container com bordas arredondadas
    # PIL não tem suporte direto para bordas arredondadas, então vamos criar uma máscara
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [(0, 0), (size, size)],
        radius=border_radius,
        fill=255
    )
    
    # Aplica a máscara
    output = Image.new('RGB', (size, size), background_color)
    output.paste(img, (0, 0), mask)
    
    # Adiciona o texto "FA"
    # Tenta usar uma fonte padrão, se não encontrar, usa a fonte padrão
    try:
        # Tenta usar uma fonte do sistema
        font_size = int(size * 0.3)  # 30% do tamanho
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", int(size * 0.3))
        except:
            # Se não encontrar, usa a fonte padrão
            font = ImageFont.load_default()
            font_size = int(size * 0.3)
    
    # Calcula a posição do texto para centralizar
    text = "FA"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    position = (
        (size - text_width) // 2,
        (size - text_height) // 2
    )
    
    # Desenha o texto
    draw.text(position, text, fill=text_color, font=font)
    
    # Salva a imagem
    output_path = 'assets/images/app_icon.png'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    output.save(output_path, 'PNG')
    
    print(f'Ícone gerado com sucesso em: {output_path}')
    print(f'Tamanho: {size}x{size}px')
    print(f'Cor de fundo: #08BF62')
    print(f'Texto: FA (branco)')

if __name__ == '__main__':
    generate_icon()

