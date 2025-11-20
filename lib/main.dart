import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'config/supabase_config.dart';
import 'Auth/PagesAuth/AuthGatePage.dart';
import 'General/ComponentsGeneral/MainNavigationWrapper.dart';
import 'General/ComponentsGeneral/AppHeader.dart';
import 'BankAccounts/PagesBankAccounts/BankAccountsListPage.dart';
import 'Categories/PagesCategories/CategoriesPage.dart';
import 'Categories/PagesCategories/CreateCategoryPage.dart';
import 'Transactions/PagesTransactions/CreateTransactionPage.dart';
import 'Transactions/PagesTransactions/TransactionsPage.dart';
import 'services/metric_service.dart';
import 'models/metric_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const FinanceoApp());
}

// Get a reference to the Supabase client
final supabase = Supabase.instance.client;

class FinanceoApp extends StatelessWidget {
  const FinanceoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financeo',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF08BF62),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardThemeData(
          elevation: 2,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF08BF62),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const AuthGatePage(authenticatedScreen: MainNavigationWrapper()),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MetricService _metricService = MetricService();
  
  // Tabs: DESPESAS ou RENDA
  String _selectedType = 'expense'; // 'expense' ou 'income'
  
  // Período selecionado
  String _selectedPeriod = 'week'; // 'day', 'week', 'month', 'year', 'custom'
  
  // Datas do período
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  
  // Dados das métricas
  MetricData? _metricData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculateWeekDates();
    _loadMetrics();
  }

  void _calculateWeekDates() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    _startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    _endDate = _startDate.add(const Duration(days: 6));
  }

  void _calculatePeriodDates() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'day':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = _startDate;
        break;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        _startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        _endDate = _startDate.add(const Duration(days: 6));
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      default:
        break;
    }
    
    setState(() {});
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _metricService.getMetrics(
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedType,
      );

      if (mounted) {
        if (response.status && response.data != null) {
          setState(() {
            _metricData = response.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message;
            _isLoading = false;
            _metricData = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar métricas: $e';
          _isLoading = false;
          _metricData = null;
        });
      }
    }
  }

  void _navigatePeriod(bool isPrevious) {
    // Não navegar se for período personalizado
    if (_selectedPeriod == 'custom') {
      return;
    }
    
    if (isPrevious) {
      switch (_selectedPeriod) {
        case 'day':
          _startDate = _startDate.subtract(const Duration(days: 1));
          _endDate = _startDate;
          break;
        case 'week':
          _startDate = _startDate.subtract(const Duration(days: 7));
          _endDate = _startDate.add(const Duration(days: 6));
          break;
        case 'month':
          _startDate = DateTime(_startDate.year, _startDate.month - 1, 1);
          _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
          break;
        case 'year':
          _startDate = DateTime(_startDate.year - 1, 1, 1);
          _endDate = DateTime(_startDate.year, 12, 31);
          break;
      }
    } else {
      switch (_selectedPeriod) {
        case 'day':
          _startDate = _startDate.add(const Duration(days: 1));
          _endDate = _startDate;
          break;
        case 'week':
          _startDate = _startDate.add(const Duration(days: 7));
          _endDate = _startDate.add(const Duration(days: 6));
          break;
        case 'month':
          _startDate = DateTime(_startDate.year, _startDate.month + 1, 1);
          _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
          break;
        case 'year':
          _startDate = DateTime(_startDate.year + 1, 1, 1);
          _endDate = DateTime(_startDate.year, 12, 31);
          break;
      }
    }
    
    setState(() {});
    _loadMetrics();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF08BF62);
    }
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('d \'de\' MMM', 'pt_BR');
    if (_startDate.year != _endDate.year ||
        _startDate.month != _endDate.month ||
        _startDate.day != _endDate.day) {
      return '${dateFormat.format(_startDate)} – ${dateFormat.format(_endDate)}';
    } else {
      return dateFormat.format(_startDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const AppHeader(),
            
            // Tabs DESPESAS/RENDA
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'expense';
                      });
                      _loadMetrics();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedType == 'expense'
                                ? const Color(0xFF08BF62)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'DESPESAS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedType == 'expense'
                              ? const Color(0xFF08BF62)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'income';
                      });
                      _loadMetrics();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedType == 'income'
                                ? const Color(0xFF08BF62)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'RENDA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedType == 'income'
                              ? const Color(0xFF08BF62)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Navegação de período
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: _selectedPeriod == 'custom' ? null : () => _navigatePeriod(true),
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPeriodButton('Dia', 'day'),
                              const SizedBox(width: 8),
                              _buildPeriodButton('Semana', 'week'),
                              const SizedBox(width: 8),
                              _buildPeriodButton('Mês', 'month'),
                              const SizedBox(width: 8),
                              _buildPeriodButton('Ano', 'year'),
                              const SizedBox(width: 8),
                              _buildPeriodButton('Personalizado', 'custom'),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: _selectedPeriod == 'custom' ? null : () => _navigatePeriod(false),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Text(
                        _formatDateRange(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF08BF62),
                    ))
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.grey[600]),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadMetrics,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF08BF62),
                                ),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      : _metricData == null || _metricData!.categories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pie_chart_outline,
                                      size: 64, color: Colors.grey[600]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum dado encontrado para este período',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  // Gráfico Donut
                                  _buildDonutChartWithCenter(),
                                  const SizedBox(height: 24),
                                  // Lista de categorias
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      children: _metricData!.categories
                                          .map((category) =>
                                              _buildCategoryItem(category))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 80), // Espaço para o botão flutuante
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () async {
        if (period == 'custom') {
          // Abrir date range picker customizado como popup
          final DateTimeRange? picked = await _showCustomDateRangePicker();
          
          if (picked != null) {
            setState(() {
              _selectedPeriod = 'custom';
              _startDate = DateTime(picked.start.year, picked.start.month, picked.start.day);
              _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
            });
            _loadMetrics();
          }
        } else {
          setState(() {
            _selectedPeriod = period;
          });
          _calculatePeriodDates();
          _loadMetrics();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFF08BF62)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? const Color(0xFF08BF62)
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<DateTimeRange?> _showCustomDateRangePicker() async {
    // Inicializar com as datas atuais se houver período personalizado
    List<DateTime?> initialDates = [];
    if (_selectedPeriod == 'custom') {
      initialDates = [_startDate, _endDate];
    }
    
    return showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        List<DateTime?> selectedDates = List.from(initialDates);
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                  maxHeight: MediaQuery.of(context).size.height * 0.65,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const Expanded(
                          child: Text(
                            'Selecione o intervalo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedDates.length == 2 && 
                                selectedDates[0] != null && 
                                selectedDates[1] != null) {
                              Navigator.pop(
                                context,
                                DateTimeRange(
                                  start: selectedDates[0]!,
                                  end: selectedDates[1]!,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF08BF62),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Range display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDates.length == 2 && 
                              selectedDates[0] != null && 
                              selectedDates[1] != null
                                  ? '${DateFormat('d \'de\' MMM', 'pt_BR').format(selectedDates[0]!)} – ${DateFormat('d \'de\' MMM', 'pt_BR').format(selectedDates[1]!)}'
                                  : selectedDates.isNotEmpty && selectedDates[0] != null
                                      ? '${DateFormat('d \'de\' MMM', 'pt_BR').format(selectedDates[0]!)} – Data de término'
                                      : 'Data inicial – Data de término',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Calendar
                    Flexible(
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.range,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          currentDate: DateTime.now(),
                          firstDayOfWeek: 1, // Segunda-feira
                          weekdayLabelTextStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          weekdayLabels: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
                          selectedDayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          selectedDayHighlightColor: const Color(0xFF4ADE80), // Verde claro para início/fim
                          selectedRangeDayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          // Usar cor muito clara para criar o efeito visual de range contínuo
                          // O calendário criará automaticamente a borda contínua ao redor do range
                          selectedRangeHighlightColor: const Color(0xFF4ADE80).withOpacity(0.15),
                          dayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          todayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          disabledDayTextStyle: TextStyle(
                            color: Colors.grey[600]!,
                            fontSize: 14,
                          ),
                          calendarViewMode: CalendarDatePicker2Mode.day,
                          centerAlignModePicker: true,
                          lastMonthIcon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF08BF62),
                            size: 24,
                          ),
                          nextMonthIcon: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF08BF62),
                            size: 24,
                          ),
                          controlsHeight: 50,
                          dayBorderRadius: BorderRadius.circular(8),
                        ),
                        value: selectedDates,
                        onValueChanged: (dates) {
                          setDialogState(() {
                            selectedDates = dates;
                          });
                        },
                        displayedMonthDate: _selectedPeriod == 'custom' ? _startDate : DateTime.now(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDonutChartWithCenter() {
    if (_metricData == null || _metricData!.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = _metricData!.categories;
    final colors = categories.map((c) => _parseColor(c.category.iconColor)).toList();
    
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 0,
    );

    // Preparar dados do gráfico
    final pieChartSections = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return PieChartSectionData(
        value: category.totalValue,
        color: colors[index],
        title: '',
        radius: 50,
        showTitle: false,
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: pieChartSections,
              centerSpaceRadius: 65,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
            swapAnimationCurve: Curves.easeInOut,
          ),
          // Anel interno com borda tracejada (opcional)
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currencyFormat.format(_metricData!.totalValue),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryMetric category) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Ícone da categoria
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(category.category.iconColor).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.string(
                category.category.icon.svg,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _parseColor(category.category.iconColor),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nome da categoria
          Expanded(
            child: Text(
              category.category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Porcentagem
          Text(
            '${category.percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          // Valor
          Text(
            currencyFormat.format(category.totalValue),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
