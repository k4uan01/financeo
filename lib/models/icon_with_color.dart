import 'bank_account_icon_model.dart';

/// Classe para representar um ícone com a cor selecionada
class IconWithColor {
  final BankAccountIconModel icon;
  final String? color;

  IconWithColor({required this.icon, this.color});

  @override
  String toString() {
    return 'IconWithColor(icon: ${icon.name}, color: $color)';
  }
}

/// Cores disponíveis para ícones genéricos
class IconColors {
  static const List<Map<String, String>> colors = [
    {'name': 'Branco', 'hex': '#FFFFFF'},
    {'name': 'Cinza', 'hex': '#9E9E9E'},
    {'name': 'Amarelo', 'hex': '#FFEB3B'},
    {'name': 'Vermelho', 'hex': '#F44336'},
    {'name': 'Azul', 'hex': '#2196F3'},
    {'name': 'Verde', 'hex': '#4CAF50'},
    {'name': 'Bege', 'hex': '#D7CCC8'},
    {'name': 'Laranja', 'hex': '#FF9800'},
    {'name': 'Rosa', 'hex': '#E91E63'},
    {'name': 'Roxo', 'hex': '#9C27B0'},
    {'name': 'Verde Água', 'hex': '#00BCD4'},
    {'name': 'Marrom', 'hex': '#795548'},
  ];
}
