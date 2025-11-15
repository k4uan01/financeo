import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/category_with_icon.dart';
import '../../services/category_service.dart';
import 'CreateCategoryPage.dart';
import 'EditCategoryPage.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _categoryService = CategoryService();
  final int _itemsPerPage = 50;

  _CategoryType _currentType = _CategoryType.expense;
  bool _isLoading = true;
  String? _errorMessage;

  List<CategoryWithIcon> _userCategories = const [];
  List<CategoryWithIcon> _standardCategories = const [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _categoryService.getCategories(
      itemsPerPage: _itemsPerPage,
      currentPage: 1,
      type: _currentType.value,
    );

    if (!mounted) {
      return;
    }

    if (!response.status) {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
        _userCategories = const [];
        _standardCategories = const [];
      });
      return;
    }

    final categories = response.categories;
    setState(() {
      _userCategories =
          categories.where((category) => !category.isStandard).toList();
      _standardCategories =
          categories.where((category) => category.isStandard).toList();
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadCategories();
  }

  Future<void> _navigateToCreateCategory() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateCategoryPage(),
      ),
    );

    if (result == true) {
      await _loadCategories();
    }
  }

  Future<void> _navigateToEditCategory(CategoryWithIcon category) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditCategoryPage(categoryId: category.id),
      ),
    );

    if (result == true) {
      await _loadCategories();
    }
  }

  void _onTypeChanged(_CategoryType type) {
    if (type == _currentType) {
      return;
    }
    setState(() {
      _currentType = type;
    });
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categorias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF08BF62),
        foregroundColor: Colors.white,
        onPressed: _navigateToCreateCategory,
        icon: const Icon(Icons.add),
        label: const Text('Criar categoria'),
      ),
      body: SafeArea(
        child: _isLoading
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
              _errorMessage ?? 'Erro ao carregar categorias',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCategories,
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
    final hasAnyCategory =
        _userCategories.isNotEmpty || _standardCategories.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF08BF62),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 24),
            if (!hasAnyCategory) ...[
              _buildEmptyState(),
            ] else ...[
              if (_userCategories.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Minhas categorias',
                  count: _userCategories.length,
                ),
                const SizedBox(height: 12),
                _buildCategoriesList(_userCategories),
                const SizedBox(height: 24),
              ],
              if (_standardCategories.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Categorias padrão',
                  count: _standardCategories.length,
                ),
                const SizedBox(height: 12),
                _buildCategoriesList(_standardCategories),
              ],
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _CategoryTypeButton(
              label: 'Despesas',
              isSelected: _currentType == _CategoryType.expense,
              onTap: () => _onTypeChanged(_CategoryType.expense),
            ),
          ),
          Expanded(
            child: _CategoryTypeButton(
              label: 'Receitas',
              isSelected: _currentType == _CategoryType.revenue,
              onTap: () => _onTypeChanged(_CategoryType.revenue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required int count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$count ${count == 1 ? "categoria" : "categorias"}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(List<CategoryWithIcon> categories) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryTile(
          category: category,
          onTap: () => _navigateToEditCategory(category),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF08BF62).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.category_outlined,
            size: 40,
            color: Color(0xFF08BF62),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhuma categoria encontrada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Comece criando suas categorias personalizadas\nou atualize para carregar novamente.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _navigateToCreateCategory,
          icon: const Icon(Icons.add),
          label: const Text('Criar categoria'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF08BF62),
            side: const BorderSide(color: Color(0xFF08BF62)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

enum _CategoryType { expense, revenue }

extension on _CategoryType {
  String get value => this == _CategoryType.expense ? 'expense' : 'revenue';
}

class _CategoryTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF08BF62) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryWithIcon category;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.iconColor);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: SvgPicture.string(
              category.icon.svg,
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          category.isStandard ? 'Categoria padrão' : 'Categoria personalizada',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
        trailing: Icon(
          category.isStandard ? Icons.lock_outline : Icons.chevron_right,
          color: category.isStandard ? Colors.grey[700] : Colors.grey[500],
        ),
        enabled: !category.isStandard,
        onTap: category.isStandard ? null : onTap,
      ),
    );
  }
}

Color _parseColor(String hexColor) {
  var formatted = hexColor.toUpperCase().replaceAll('#', '');
  if (formatted.length == 6) {
    formatted = 'FF$formatted';
  }
  if (formatted.length != 8) {
    return const Color(0xFF08BF62);
  }
  return Color(int.parse(formatted, radix: 16));
}

