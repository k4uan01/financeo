import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Auth/ComponentsAuth/CustomTextField.dart';
import '../../Auth/ComponentsAuth/PrimaryButton.dart';
import '../../models/category_icon_model.dart';
import '../../models/category_icon_selection.dart';
import '../../models/category_with_icon.dart';
import '../../services/category_service.dart';
import '../ComponentsCategories/CategoryIconSelectorBottomSheet.dart';

class EditCategoryPage extends StatefulWidget {
  final String categoryId;

  const EditCategoryPage({
    super.key,
    required this.categoryId,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  bool _isLoadingCategory = true;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String _categoryType = 'expense';
  bool _isStandardCategory = false;

  CategoryWithIcon? _category;
  CategoryIconSelection? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    setState(() {
      _isLoadingCategory = true;
      _errorMessage = null;
    });

    final response = await _categoryService.getCategory(widget.categoryId);

    if (!mounted) return;

    if (!response.status || response.category == null) {
      setState(() {
        _isLoadingCategory = false;
        _errorMessage = response.message;
      });
      return;
    }

    final category = response.category!;

    setState(() {
      _category = category;
      _nameController.text = category.name;
      _categoryType = category.type;
      _isStandardCategory = category.isStandard;
      _selectedIcon = CategoryIconSelection(
        icon: CategoryIconModel(
          id: category.icon.id,
          svg: category.icon.svg,
        ),
        color: category.iconColor,
      );
      _isLoadingCategory = false;
    });
  }

  Future<void> _openIconSelector() async {
    if (_isStandardCategory) {
      return;
    }

    final result = await showCategoryIconSelector(context);
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _selectedIcon = result;
      });
    }
  }

  Future<void> _handleEditCategory() async {
    if (_isStandardCategory || _category == null) {
      return;
    }

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
      final response = await _categoryService.editCategory(
        categoryId: widget.categoryId,
        name: _nameController.text,
        iconId: _selectedIcon!.icon.id,
        iconColor: _selectedIcon!.color,
        type: _categoryType,
      );

      if (!mounted) return;

      if (response.status && response.category != null) {
        _showSuccessSnackBar(response.message);
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erro ao editar categoria: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteCategory() async {
    if (_isStandardCategory || _category == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir categoria'),
          content: const Text(
            'Tem certeza de que deseja excluir esta categoria? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await _categoryService.deleteCategory(
        categoryId: widget.categoryId,
      );

      if (!mounted) {
        return;
      }

      if (response.status) {
        _showSuccessSnackBar(response.message);
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Erro ao excluir categoria: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar categoria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _isLoadingCategory ? null : _loadCategory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingCategory
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Erro ao carregar categoria',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCategory,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08BF62),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderPreview(isDark),
            const SizedBox(height: 32),
            if (_isStandardCategory) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Categorias padrão não podem ser editadas. Você pode criar uma nova categoria personalizada se preferir.',
                        style: TextStyle(
                          color: Colors.orange[200],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
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
                    onChanged: _isStandardCategory
                        ? null
                        : (value) {
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
                    onChanged: _isStandardCategory
                        ? null
                        : (value) {
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
              enabled: !_isStandardCategory,
              validator: (value) {
                if (_isStandardCategory) {
                  return null;
                }
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
              text: 'Salvar alterações',
              onPressed: _isSubmitting || _isDeleting || _isStandardCategory
                  ? null
                  : _handleEditCategory,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isSubmitting || _isDeleting
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
            const SizedBox(height: 16),
            if (!_isStandardCategory)
              TextButton.icon(
                onPressed:
                    _isSubmitting || _isDeleting ? null : _confirmDeleteCategory,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(
                  _isDeleting ? 'Excluindo...' : 'Excluir categoria',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPreview(bool isDark) {
    final hasSelection = _selectedIcon != null;
    final backgroundColor = hasSelection
        ? Color(
            int.parse(_selectedIcon!.color.substring(1), radix: 16) + 0xFF000000,
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
          hasSelection ? _nameController.text.trim() : 'Categoria',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIconSelectorCard(bool isDark) {
    final hasSelection = _selectedIcon != null;

    return InkWell(
      onTap: _isSubmitting || _isStandardCategory ? null : _openIconSelector,
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
                      fontWeight:
                          hasSelection ? FontWeight.bold : FontWeight.normal,
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
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
  final ValueChanged<String>? onChanged;

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
      onTap: onChanged == null ? null : () => onChanged!(value),
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

