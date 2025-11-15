import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Auth/ComponentsAuth/CustomTextField.dart';
import '../../Auth/ComponentsAuth/PrimaryButton.dart';
import '../../models/category_icon_selection.dart';
import '../../services/category_service.dart';
import '../ComponentsCategories/CategoryIconSelectorBottomSheet.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  bool _isSubmitting = false;
  String _categoryType = 'expense';
  CategoryIconSelection? _selectedIcon;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openIconSelector() async {
    final result = await showCategoryIconSelector(context);
    if (result != null) {
      setState(() {
        _selectedIcon = result;
      });
    }
  }

  Future<void> _handleCreateCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um ícone para a categoria'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _categoryService.createCategory(
        name: _nameController.text,
        iconId: _selectedIcon!.icon.id,
        iconColor: _selectedIcon!.color,
        type: _categoryType,
      );

      if (!mounted) return;

      if (response.status && response.data != null) {
        _showSuccessSnackBar(response.message);
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erro ao criar categoria: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF08BF62),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar categoria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderPreview(isDark),
                const SizedBox(height: 32),
                const Text(
                  'Categoria de:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CategoryTypeButton(
                        label: 'Despesa',
                        value: 'expense',
                        groupValue: _categoryType,
                        onChanged: (value) {
                          setState(() {
                            _categoryType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CategoryTypeButton(
                        label: 'Receita',
                        value: 'revenue',
                        groupValue: _categoryType,
                        onChanged: (value) {
                          setState(() {
                            _categoryType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nome da categoria',
                  prefixIcon: Icons.edit_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite um nome para a categoria';
                    }
                    if (value.trim().length < 3) {
                      return 'O nome deve ter ao menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Escolha um ícone:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 12),
                _buildIconSelectorCard(isDark),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Criar categoria',
                  onPressed: _isSubmitting ? null : _handleCreateCategory,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[600]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPreview(bool isDark) {
    final hasSelection = _selectedIcon != null;
    final backgroundColor = hasSelection
        ? Color(
            int.parse(_selectedIcon!.color.substring(1), radix: 16) +
                0xFF000000,
          )
        : (isDark ? const Color(0xFF1E1E1E) : Colors.grey[200]!);

    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: hasSelection
                ? SvgPicture.string(
                    _selectedIcon!.icon.svg,
                    width: 72,
                    height: 72,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    Icons.category_outlined,
                    size: 72,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          hasSelection ? _nameController.text.trim() : 'Nova categoria',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIconSelectorCard(bool isDark) {
    final hasSelection = _selectedIcon != null;

    return InkWell(
      onTap: _isSubmitting ? null : _openIconSelector,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection ? const Color(0xFF08BF62) : Colors.grey[700]!,
            width: hasSelection ? 2 : 1,
          ),
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasSelection
                    ? Color(
                        int.parse(
                              _selectedIcon!.color.substring(1),
                              radix: 16,
                            ) +
                            0xFF000000,
                      )
                    : Colors.grey[900],
              ),
              child: Center(
                child: hasSelection
                    ? SvgPicture.string(
                        _selectedIcon!.icon.svg,
                        width: 32,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        Icons.add,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSelection ? 'Ícone selecionado' : 'Selecione um ícone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: hasSelection
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    hasSelection
                        ? 'Cor ${_selectedIcon!.color}'
                        : 'Toque para escolher o ícone',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

class _CategoryTypeButton extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _CategoryTypeButton({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF08BF62) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF08BF62) : Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}
