import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/bank_account_icon_service.dart';
import '../../models/bank_account_icon_model.dart';
import '../../models/icon_with_color.dart';

class IconSelectorBottomSheet extends StatefulWidget {
  const IconSelectorBottomSheet({super.key});

  @override
  State<IconSelectorBottomSheet> createState() => _IconSelectorBottomSheetState();
}

class _IconSelectorBottomSheetState extends State<IconSelectorBottomSheet> {
  final _iconService = BankAccountIconService();
  final _searchController = TextEditingController();
  
  List<BankAccountIconModel> _genericIcons = [];
  List<BankAccountIconModel> _bankingIcons = [];
  
  bool _isLoadingGeneric = true;
  bool _isLoadingBanking = true;
  
  String _searchQuery = '';
  
  BankAccountIconModel? _selectedIcon;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIcons() async {
    setState(() {
      _isLoadingGeneric = true;
      _isLoadingBanking = true;
    });

    // Carregar ícones genéricos
    final genericResponse = await _iconService.getGenericIcons(
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );

    // Carregar ícones de instituições bancárias
    final bankingResponse = await _iconService.getBankingInstitutionIcons(
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );

    if (mounted) {
      setState(() {
        if (genericResponse.status) {
          _genericIcons = genericResponse.data;
        }
        if (bankingResponse.status) {
          _bankingIcons = bankingResponse.data;
        }
        _isLoadingGeneric = false;
        _isLoadingBanking = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _loadIcons();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecionar um ícone',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar um ícone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF08BF62),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: _selectedIcon != null && _selectedIcon!.isGeneric
                        ? 180  // Espaço para a paleta de cores
                        : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícones genéricos
                      const Text(
                        'Ícone genéricos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_isLoadingGeneric)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_genericIcons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Nenhum ícone genérico encontrado',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _genericIcons.length,
                          itemBuilder: (context, index) {
                            final icon = _genericIcons[index];
                            return _buildIconItem(icon);
                          },
                        ),

                      const SizedBox(height: 32),

                      // Ícones de instituições bancárias
                      const Text(
                        'Ícones de instituições bancárias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_isLoadingBanking)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_bankingIcons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Nenhum ícone de instituição bancária encontrado',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _bankingIcons.length,
                          itemBuilder: (context, index) {
                            final icon = _bankingIcons[index];
                            return _buildIconItem(icon);
                          },
                        ),
                    ],
                  ),
                ),
                
                // Paleta de cores (fixada no fundo)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildColorPalette(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleIconTap(BankAccountIconModel icon) {
    if (icon.isGeneric) {
      // Para ícones genéricos, mostrar seletor de cor
      setState(() {
        _selectedIcon = icon;
        _selectedColor = null; // Resetar cor ao selecionar novo ícone
      });
    } else {
      // Para ícones bancários, retornar diretamente
      Navigator.pop(
        context,
        IconWithColor(icon: icon, color: null),
      );
    }
  }

  void _handleColorSelected(String color) {
    if (_selectedIcon != null) {
      Navigator.pop(
        context,
        IconWithColor(icon: _selectedIcon!, color: color),
      );
    }
  }

  Widget _buildIconItem(BankAccountIconModel icon) {
    final isSelected = _selectedIcon?.id == icon.id;
    
    return InkWell(
      onTap: () => _handleIconTap(icon),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF08BF62)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem do ícone (SVG para genéricos, PNG/JPG para bancários)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: icon.isGeneric
                    ? SvgPicture.string(
                        icon.image,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Image.network(
                        icon.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.account_balance,
                            size: 32,
                            color: Colors.grey[400],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    if (_selectedIcon == null || !_selectedIcon!.isGeneric) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.string(
                  _selectedIcon!.image,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedIcon!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecione uma cor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: IconColors.colors.map((colorData) {
              final hex = colorData['hex']!;
              return _buildColorOption(hex);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String hexColor) {
    final color = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    final isSelected = _selectedColor == hexColor;
    
    return InkWell(
      onTap: () => _handleColorSelected(hexColor),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF08BF62)
                : (hexColor == '#FFFFFF' ? Colors.grey[300]! : Colors.transparent),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF08BF62).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              )
            : null,
      ),
    );
  }
}

// Função helper para mostrar o bottom sheet
Future<IconWithColor?> showIconSelector(BuildContext context) async {
  return await showModalBottomSheet<IconWithColor>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const IconSelectorBottomSheet(),
  );
}

