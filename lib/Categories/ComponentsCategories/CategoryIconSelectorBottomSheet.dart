import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/category_icon_model.dart';
import '../../models/category_icon_selection.dart';
import '../../services/category_icon_service.dart';

class CategoryIconSelectorBottomSheet extends StatefulWidget {
  const CategoryIconSelectorBottomSheet({super.key});

  @override
  State<CategoryIconSelectorBottomSheet> createState() =>
      _CategoryIconSelectorBottomSheetState();
}

class _CategoryIconSelectorBottomSheetState
    extends State<CategoryIconSelectorBottomSheet> {
  final CategoryIconService _iconService = CategoryIconService();

  bool _isLoading = true;
  String? _errorMessage;

  List<CategoryIconModel> _icons = const [];
  String? _selectedColor;

  static const List<String> _availableColors = [
    '#FF5C8D',
    '#A259FF',
    '#5B4BFF',
    '#D053A5',
    '#FF6F61',
    '#FF8A80',
    '#5CD85C',
    '#FFB074',
  ];

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _iconService.getCategoryIcons();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.status) {
        _icons = response.data;
      } else {
        _errorMessage = response.message;
      }
    });
  }

  void _handleColorTap(String hexColor) {
    setState(() {
      _selectedColor = hexColor;
    });
  }

  void _handleIconTap(CategoryIconModel icon) {
    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma cor antes de escolher o ícone'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).pop(CategoryIconSelection(icon: icon, color: _selectedColor!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ícone da categoria',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Selecione uma cor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemBuilder: (context, index) {
                final hex = _availableColors[index];
                final color = Color(
                  int.parse(hex.substring(1), radix: 16) + 0xFF000000,
                );
                final isSelected = _selectedColor == hex;

                return GestureDetector(
                  onTap: () => _handleColorTap(hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 52 : 48,
                    height: isSelected ? 52 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF08BF62)
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(
                              0xFF08BF62,
                            ).withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _availableColors.length,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Selecione um ícone',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadIcons,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_icons.isEmpty) {
      return Center(
        child: Text(
          'Nenhum ícone disponível no momento.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _icons.length,
      itemBuilder: (context, index) {
        final icon = _icons[index];
        return _CategoryIconItem(
          icon: icon,
          colorHex: _selectedColor,
          onTap: _handleIconTap,
        );
      },
    );
  }
}

class _CategoryIconItem extends StatelessWidget {
  final CategoryIconModel icon;
  final String? colorHex;
  final ValueChanged<CategoryIconModel> onTap;

  const _CategoryIconItem({
    required this.icon,
    required this.colorHex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasColor = colorHex != null;
    final backgroundColor = hasColor
        ? Color(int.parse(colorHex!.substring(1), radix: 16) + 0xFF000000)
        : Colors.grey[900];

    return InkWell(
      onTap: () => onTap(icon),
      borderRadius: BorderRadius.circular(48),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        padding: const EdgeInsets.all(16),
        child: SvgPicture.string(
          icon.svg,
          colorFilter: hasColor
              ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}

Future<CategoryIconSelection?> showCategoryIconSelector(BuildContext context) {
  return showModalBottomSheet<CategoryIconSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CategoryIconSelectorBottomSheet(),
  );
}
