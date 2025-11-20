import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_with_category.dart';
import '../../models/bank_account_with_icon.dart';
import '../../models/category_with_icon.dart';
import '../../services/transaction_service.dart';
import '../../services/bank_account_service.dart';
import '../../services/category_service.dart';
import 'ViewTransactionPage.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionService _transactionService = TransactionService();
  final BankAccountService _bankAccountService = BankAccountService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  List<TransactionWithCategory> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearchVisible = false;
  Timer? _debounceTimer;

  DateTime _selectedMonth = DateTime.now();
  final int _itemsPerPage = 100;

  // Filtros
  String? _filterType; // 'revenue' ou 'expense'
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterBankAccountId;
  String? _filterCategoryId;

  // Listas para dropdowns
  List<BankAccountWithIcon> _bankAccounts = [];
  List<CategoryWithIcon> _categories = [];
  bool _isLoadingAccounts = false;
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_onSearchChanged);
    _loadBankAccounts();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancela o timer anterior se existir
    _debounceTimer?.cancel();
    
    // Cria um novo timer que executa após 500ms de inatividade
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadTransactions();
      }
    });
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Calcular início e fim do mês selecionado
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final response = await _transactionService.getTransactions(
        itemsPerPage: _itemsPerPage,
        currentPage: 1,
        startDate: _filterStartDate ?? startDate,
        endDate: _filterEndDate ?? endDate,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        type: _filterType,
        bankAccountId: _filterBankAccountId,
        categoryId: _filterCategoryId,
      );

      if (mounted) {
        if (response.status) {
          setState(() {
            _transactions = response.transactions;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar transações: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadTransactions();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadTransactions();
  }

  String _getMonthName(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[date.month - 1];
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Dia atual';
    }

    return '${date.day} de ${_getMonthName(date).toLowerCase()}';
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    ).format(value);
  }

  Map<String, List<TransactionWithCategory>> _groupTransactionsByDate() {
    final grouped = <String, List<TransactionWithCategory>>{};
    final dateMap = <String, DateTime>{};

    for (final transaction in _transactions) {
      final dateKey = _formatDateHeader(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
      // Armazenar a data para ordenação
      if (!dateMap.containsKey(dateKey)) {
        dateMap[dateKey] = transaction.date;
      }
    }

    // Ordenar as chaves: "Dia atual" primeiro, depois por data (mais recente primeiro)
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      if (a == 'Dia atual') return -1;
      if (b == 'Dia atual') return 1;
      // Para outras datas, ordenar por data (mais recente primeiro)
      final dateA = dateMap[a]!;
      final dateB = dateMap[b]!;
      return dateB.compareTo(dateA);
    });

    final sortedGrouped = <String, List<TransactionWithCategory>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF08BF62);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _debounceTimer?.cancel();
        _searchController.clear();
        _loadTransactions();
      }
    });
  }

  bool _hasActiveFilters() {
    return _filterType != null ||
        _filterStartDate != null ||
        _filterEndDate != null ||
        _filterBankAccountId != null ||
        _filterCategoryId != null;
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
            _bankAccounts = result['data'] as List<BankAccountWithIcon>;
            _isLoadingAccounts = false;
          });
        } else {
          setState(() {
            _isLoadingAccounts = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAccounts = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final response = await _categoryService.getCategories(
        itemsPerPage: 100,
        currentPage: 1,
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
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheetContent(
        initialType: _filterType,
        initialStartDate: _filterStartDate,
        initialEndDate: _filterEndDate,
        initialBankAccountId: _filterBankAccountId,
        initialCategoryId: _filterCategoryId,
        bankAccounts: _bankAccounts,
        categories: _categories,
        isLoadingAccounts: _isLoadingAccounts,
        isLoadingCategories: _isLoadingCategories,
        onApply: (type, startDate, endDate, bankAccountId, categoryId) {
          setState(() {
            _filterType = type;
            _filterStartDate = startDate;
            _filterEndDate = endDate;
            _filterBankAccountId = bankAccountId;
            _filterCategoryId = categoryId;
          });
          _loadTransactions();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header customizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_isSearchVisible)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _toggleSearch,
                    tooltip: 'Fechar busca',
                  ),
                Expanded(
                  child: _isSearchVisible
                      ? ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            return TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar transações...',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                border: InputBorder.none,
                                suffixIcon: value.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _debounceTimer?.cancel();
                                          _searchController.clear();
                                          _toggleSearch();
                                        },
                                      )
                                    : null,
                              ),
                            );
                          },
                        )
                      : const Text(
                          'Transações',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (!_isSearchVisible) ...[
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _toggleSearch,
                    tooltip: 'Buscar',
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.filter_list),
                        if (_hasActiveFilters())
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF08BF62),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showFilterBottomSheet,
                    tooltip: 'Filtros',
                  ),
                ],
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF08BF62),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadTransactions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF08BF62),
                        ),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  color: const Color(0xFF08BF62),
                  child: ListView(
                    children: [
                      // Navegação de meses
                      _buildMonthNavigation(),
                      // Lista de transações ou mensagem vazia
                      _transactions.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhuma transação encontrada',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildTransactionsList(),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final previousMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mês anterior
          TextButton(
            onPressed: _previousMonth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_left, size: 20),
                const SizedBox(width: 4),
                Text(
                  _getMonthName(previousMonth),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Mês atual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[700]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getMonthName(_selectedMonth),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Próximo mês
          TextButton(
            onPressed: _nextMonth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMonthName(nextMonth),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final groupedTransactions = _groupTransactionsByDate();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedTransactions.entries.map((entry) {
          final dateKey = entry.key;
          final transactions = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da data
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  dateKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              // Lista de transações do dia
              ...transactions.map((transaction) => _buildTransactionItem(transaction)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionWithCategory transaction) {
    final isRevenue = transaction.isRevenue;
    final valueColor = isRevenue
        ? const Color(0xFF08BF62)
        : Colors.white;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewTransactionPage(
              transactionId: transaction.id,
            ),
          ),
        );
        // Recarregar transações se foi excluída ou editada
        if (result == true) {
          _loadTransactions();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
        children: [
          // Ícone da categoria
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _parseColor(transaction.category.iconColor),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: transaction.category.icon.svg.isNotEmpty
                  ? SvgPicture.string(
                      transaction.category.icon.svg,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (context) => const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.category,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Descrição e conta bancária
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : transaction.category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.bankAccount.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Valor
          Text(
            '${isRevenue ? '+' : '-'}${_formatCurrency(transaction.value)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final String? initialType;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialBankAccountId;
  final String? initialCategoryId;
  final List<BankAccountWithIcon> bankAccounts;
  final List<CategoryWithIcon> categories;
  final bool isLoadingAccounts;
  final bool isLoadingCategories;
  final Function(String?, DateTime?, DateTime?, String?, String?) onApply;

  const _FilterBottomSheetContent({
    required this.initialType,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialBankAccountId,
    required this.initialCategoryId,
    required this.bankAccounts,
    required this.categories,
    required this.isLoadingAccounts,
    required this.isLoadingCategories,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState
    extends State<_FilterBottomSheetContent> {
  late String? tempType;
  late DateTime? tempStartDate;
  late DateTime? tempEndDate;
  late String? tempBankAccountId;
  late String? tempCategoryId;

  @override
  void initState() {
    super.initState();
    tempType = widget.initialType;
    tempStartDate = widget.initialStartDate;
    tempEndDate = widget.initialEndDate;
    tempBankAccountId = widget.initialBankAccountId;
    tempCategoryId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempType = null;
                            tempStartDate = null;
                            tempEndDate = null;
                            tempBankAccountId = null;
                            tempCategoryId = null;
                          });
                        },
                        child: const Text('Limpar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onApply(
                            tempType,
                            tempStartDate,
                            tempEndDate,
                            tempBankAccountId,
                            tempCategoryId,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF08BF62),
                        ),
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[850],
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(value: 'revenue', child: Text('Receita')),
                        DropdownMenuItem(value: 'expense', child: Text('Despesa')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tempType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Data inicial
                    const Text(
                      'Data Inicial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            tempStartDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[850],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tempStartDate != null
                                  ? DateFormat('dd/MM/yyyy').format(tempStartDate!)
                                  : 'Selecione a data inicial',
                              style: TextStyle(
                                color: tempStartDate != null
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    if (tempStartDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  tempStartDate = null;
                                });
                              },
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Remover'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Data final
                    const Text(
                      'Data Final',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate ?? DateTime.now(),
                          firstDate: tempStartDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            tempEndDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[850],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tempEndDate != null
                                  ? DateFormat('dd/MM/yyyy').format(tempEndDate!)
                                  : 'Selecione a data final',
                              style: TextStyle(
                                color: tempEndDate != null
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    if (tempEndDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  tempEndDate = null;
                                });
                              },
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Remover'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Conta bancária
                    const Text(
                      'Conta Bancária',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    widget.isLoadingAccounts
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: tempBankAccountId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[850],
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todas'),
                              ),
                              ...widget.bankAccounts.map((account) {
                                return DropdownMenuItem(
                                  value: account.id,
                                  child: Text(account.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                tempBankAccountId = value;
                              });
                            },
                          ),
                    const SizedBox(height: 24),
                    // Categoria
                    const Text(
                      'Categoria',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    widget.isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: tempCategoryId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[850],
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todas'),
                              ),
                              ...widget.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                tempCategoryId = value;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

