import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../Auth/ComponentsAuth/CustomTextField.dart';
import '../../Auth/ComponentsAuth/PrimaryButton.dart';
import '../../models/category_with_icon.dart';
import '../../models/bank_account_with_icon.dart' as bank_account_models;
import '../../services/transaction_service.dart';
import '../../services/category_service.dart';
import '../../services/bank_account_service.dart';

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Valor como string de dígitos (ex: "1234" = R$ 12,34)
  String _valueDigits = '';

  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final BankAccountService _bankAccountService = BankAccountService();

  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _isLoadingAccounts = false;

  String _transactionType = 'expense'; // 'expense' ou 'income'
  DateTime _selectedDate = DateTime.now();
  CategoryWithIcon? _selectedCategory;
  bank_account_models.BankAccountWithIcon? _selectedBankAccount;
  String _dateSelectionType = 'today'; // 'today', 'yesterday', 'custom'

  List<CategoryWithIcon> _categories = [];
  List<bank_account_models.BankAccountWithIcon> _bankAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBankAccounts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      // Converter 'income' para 'revenue' para a API de categorias
      final categoryType = _transactionType == 'income' ? 'revenue' : _transactionType;
      
      final response = await _categoryService.getCategories(
        itemsPerPage: 100,
        currentPage: 1,
        type: categoryType,
      );

      if (mounted) {
        if (response.status) {
          setState(() {
            _categories = response.categories;
            _isLoadingCategories = false;
          });
        } else {
          setState(() {
            _isLoadingCategories = false;
          });
          _showErrorSnackBar(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        _showErrorSnackBar('Erro ao carregar categorias: $e');
      }
    }
  }

  Future<void> _loadBankAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
    });

    try {
      final result = await _bankAccountService.listBankAccounts();

      if (mounted) {
        if (result['status'] == true) {
          setState(() {
            _bankAccounts = result['data'] as List<bank_account_models.BankAccountWithIcon>;
            _isLoadingAccounts = false;
          });
        } else {
          setState(() {
            _isLoadingAccounts = false;
          });
          _showErrorSnackBar(result['message'] as String);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAccounts = false;
        });
        _showErrorSnackBar('Erro ao carregar contas: $e');
      }
    }
  }

  double _getValue() {
    if (_valueDigits.isEmpty) return 0.0;
    return int.parse(_valueDigits) / 100;
  }

  String _getFormattedValue() {
    if (_valueDigits.isEmpty) return '0,00';
    final value = int.parse(_valueDigits) / 100;
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    ).format(value).replaceAll('R\$ ', '');
  }

  void _addDigit(String digit) {
    setState(() {
      _valueDigits += digit;
    });
  }

  void _removeDigit() {
    if (_valueDigits.isNotEmpty) {
      setState(() {
        _valueDigits = _valueDigits.substring(0, _valueDigits.length - 1);
      });
    }
  }

  void _clearValue() {
    setState(() {
      _valueDigits = '';
    });
  }

  Future<void> _openValueSelector() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ValueSelectorBottomSheet(
        currentValue: _valueDigits,
        onValueChanged: (newValue) {
          setState(() {
            _valueDigits = newValue;
          });
        },
        onConfirm: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateSelectionType = 'custom';
      });
    }
  }

  void _updateDateSelection(String type) {
    setState(() {
      _dateSelectionType = type;
      final now = DateTime.now();
      switch (type) {
        case 'today':
          _selectedDate = now;
          break;
        case 'yesterday':
          _selectedDate = now.subtract(const Duration(days: 1));
          break;
        case 'custom':
          _selectDate();
          break;
      }
    });
  }

  String _getDateDisplayText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return 'Hoje';
    } else if (selected == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate);
    }
  }

  Future<void> _selectCategory() async {
    if (_categories.isEmpty) {
      _showErrorSnackBar('Nenhuma categoria disponível');
      return;
    }

    final selected = await showModalBottomSheet<CategoryWithIcon>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selecione uma categoria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            category.iconColor.substring(1),
                            radix: 16,
                          ) + 0xFF000000,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SvgPicture.string(
                          category.icon.svg,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    title: Text(category.name),
                    onTap: () => Navigator.pop(context, category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedCategory = selected;
      });
    }
  }

  Future<void> _selectBankAccount() async {
    if (_bankAccounts.isEmpty) {
      _showErrorSnackBar('Nenhuma conta bancária disponível');
      return;
    }

    final selected = await showModalBottomSheet<bank_account_models.BankAccountWithIcon>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selecione uma conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _bankAccounts.length,
                itemBuilder: (context, index) {
                  final account = _bankAccounts[index];
                  final hasColor = account.iconColor != null;
                  final backgroundColor = hasColor
                      ? Color(int.parse(account.iconColor!.substring(1), radix: 16) + 0xFF000000)
                      : const Color(0xFF08BF62).withValues(alpha: 0.1);

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: account.icon.isGeneric
                          ? SvgPicture.string(
                              account.icon.image,
                              fit: BoxFit.contain,
                            )
                          : Image.network(
                              account.icon.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.account_balance,
                                  color: Color(0xFF08BF62),
                                  size: 24,
                                );
                              },
                            ),
                    ),
                    title: Text(account.name),
                    subtitle: Text(
                      'R\$ ${account.balance.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () => Navigator.pop(context, account),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedBankAccount = selected;
      });
    }
  }

  Future<void> _handleCreateTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final value = _getValue();
    if (value <= 0) {
      _showErrorSnackBar('O valor deve ser maior que zero');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackBar('Selecione uma categoria');
      return;
    }

    if (_selectedBankAccount == null) {
      _showErrorSnackBar('Selecione uma conta bancária');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Converter 'income' para 'revenue' para a API
      final apiType = _transactionType == 'income' ? 'revenue' : _transactionType;
      
      final response = await _transactionService.createTransaction(
        title: _titleController.text.trim(),
        value: value,
        categoryId: _selectedCategory!.id,
        bankAccountId: _selectedBankAccount!.id,
        date: _selectedDate,
        type: apiType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (response.status) {
        _showSuccessSnackBar(response.message);
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erro ao criar transação: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
          'Nova Transação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header verde com valor e tabs
            _buildHeaderSection(),
            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    _buildSectionTitle('Título'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Título',
                      prefixIcon: Icons.title,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite um título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Descrição
                    _buildSectionTitle('Descrição'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Adicione uma descrição',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Data
                    _buildSectionTitle('Data'),
                    const SizedBox(height: 8),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    // Categoria
                    _buildSectionTitle('Categoria'),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    // Conta ou cartão
                    _buildSectionTitle('Conta ou cartão'),
                    const SizedBox(height: 8),
                    _buildBankAccountSelector(),
                    const SizedBox(height: 32),
                    // Botão Adicionar
                    PrimaryButton(
                      text: 'Adicionar',
                      onPressed: _isLoading ? null : _handleCreateTransaction,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final formattedValue = _getFormattedValue();
    final headerColor = _transactionType == 'expense' 
        ? Colors.red[700]! 
        : const Color(0xFF08BF62);

    return Container(
      color: headerColor,
      child: Column(
        children: [
          // Tabs
          Row(
            children: [
              Expanded(
                child: _TransactionTypeTab(
                  label: 'Despesa',
                  value: 'expense',
                  groupValue: _transactionType,
                  onChanged: (value) {
                    setState(() {
                      _transactionType = value;
                      _selectedCategory = null; // Reset category when type changes
                    });
                    _loadCategories();
                  },
                ),
              ),
              Expanded(
                child: _TransactionTypeTab(
                  label: 'Receita',
                  value: 'income',
                  groupValue: _transactionType,
                  onChanged: (value) {
                    setState(() {
                      _transactionType = value;
                      _selectedCategory = null; // Reset category when type changes
                    });
                    _loadCategories();
                  },
                ),
              ),
            ],
          ),
          // Valor
          InkWell(
            onTap: _openValueSelector,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Valor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formattedValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildDateSelector() {
    // Determinar o label do botão de data customizada
    String customDateLabel = 'Selecionar data';
    if (_dateSelectionType == 'custom') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      
      if (selected != today && selected != yesterday) {
        customDateLabel = DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate);
      }
    }
    
    return Row(
      children: [
        Expanded(
          child: _DateButton(
            label: 'Hoje',
            isSelected: _dateSelectionType == 'today',
            onTap: () => _updateDateSelection('today'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateButton(
            label: 'Ontem',
            isSelected: _dateSelectionType == 'yesterday',
            onTap: () => _updateDateSelection('yesterday'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateButton(
            label: customDateLabel,
            isSelected: _dateSelectionType == 'custom',
            onTap: () => _updateDateSelection('custom'),
            icon: _dateSelectionType == 'custom' && customDateLabel != 'Selecionar data' 
                ? null 
                : Icons.calendar_today,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return InkWell(
      onTap: _isLoadingCategories ? null : _selectCategory,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedCategory != null
                ? const Color(0xFF08BF62)
                : Colors.grey[700]!,
            width: _selectedCategory != null ? 2 : 1,
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
        ),
        child: Row(
          children: [
            if (_selectedCategory != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      _selectedCategory!.iconColor.substring(1),
                      radix: 16,
                    ) + 0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.string(
                    _selectedCategory!.icon.svg,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              )
            else
              Icon(Icons.list, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedCategory?.name ?? 'Selecione',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedCategory != null
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
              ),
            ),
            if (_isLoadingCategories)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountSelector() {
    final hasAccount = _selectedBankAccount != null;
    final hasColor = hasAccount && _selectedBankAccount!.iconColor != null;
    final backgroundColor = hasColor
        ? Color(int.parse(_selectedBankAccount!.iconColor!.substring(1), radix: 16) + 0xFF000000)
        : const Color(0xFF08BF62).withValues(alpha: 0.1);

    return InkWell(
      onTap: _isLoadingAccounts ? null : _selectBankAccount,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasAccount
                ? const Color(0xFF08BF62)
                : Colors.grey[700]!,
            width: hasAccount ? 2 : 1,
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
        ),
        child: Row(
          children: [
            if (hasAccount)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _selectedBankAccount!.icon.isGeneric
                    ? SvgPicture.string(
                        _selectedBankAccount!.icon.image,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        _selectedBankAccount!.icon.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.account_balance,
                            color: Color(0xFF08BF62),
                            size: 24,
                          );
                        },
                      ),
              )
            else
              Icon(
                Icons.account_balance_wallet,
                color: Colors.grey[600],
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedBankAccount?.name ?? 'Selecione',
                style: TextStyle(
                  fontSize: 16,
                  color: hasAccount
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
              ),
            ),
            if (_isLoadingAccounts)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

}

class _TransactionTypeTab extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _TransactionTypeTab({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueSelectorBottomSheet extends StatefulWidget {
  final String currentValue;
  final Function(String) onValueChanged;
  final VoidCallback onConfirm;

  const _ValueSelectorBottomSheet({
    required this.currentValue,
    required this.onValueChanged,
    required this.onConfirm,
  });

  @override
  State<_ValueSelectorBottomSheet> createState() => _ValueSelectorBottomSheetState();
}

class _ValueSelectorBottomSheetState extends State<_ValueSelectorBottomSheet> {
  late String _valueDigits;

  @override
  void initState() {
    super.initState();
    _valueDigits = widget.currentValue;
  }

  void _addDigit(String digit) {
    setState(() {
      _valueDigits += digit;
    });
    widget.onValueChanged(_valueDigits);
  }

  void _removeDigit() {
    if (_valueDigits.isNotEmpty) {
      setState(() {
        _valueDigits = _valueDigits.substring(0, _valueDigits.length - 1);
      });
      widget.onValueChanged(_valueDigits);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Teclado numérico
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Linhas 1-3 (números 1-9)
                  Expanded(
                    child: Row(
                      children: [
                        _buildNumberButton('1'),
                        const SizedBox(width: 12),
                        _buildNumberButton('2'),
                        const SizedBox(width: 12),
                        _buildNumberButton('3'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        _buildNumberButton('4'),
                        const SizedBox(width: 12),
                        _buildNumberButton('5'),
                        const SizedBox(width: 12),
                        _buildNumberButton('6'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        _buildNumberButton('7'),
                        const SizedBox(width: 12),
                        _buildNumberButton('8'),
                        const SizedBox(width: 12),
                        _buildNumberButton('9'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Última linha (0, backspace)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildNumberButton('0'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.backspace,
                            onTap: _removeDigit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botão de confirmar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08BF62),
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                ),
                child: const Icon(
                  Icons.check,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String digit) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addDigit(digit),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
class _DateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _DateButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF08BF62) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF08BF62) : Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[300],
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[300],
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


