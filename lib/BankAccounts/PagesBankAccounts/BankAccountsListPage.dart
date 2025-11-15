import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/bank_account_service.dart';
import '../../models/bank_account_with_icon.dart';
import 'CreateBankAccountPage.dart';
import 'EditBankAccountPage.dart';

class BankAccountsListPage extends StatefulWidget {
  const BankAccountsListPage({super.key});

  @override
  State<BankAccountsListPage> createState() => _BankAccountsListPageState();
}

class _BankAccountsListPageState extends State<BankAccountsListPage> {
  final _bankAccountService = BankAccountService();
  List<BankAccountWithIcon> _accounts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _bankAccountService.listBankAccounts();
      
      if (mounted) {
        if (result['status'] == true) {
          setState(() {
            _accounts = result['data'] as List<BankAccountWithIcon>;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] as String;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar contas: $e';
          _isLoading = false;
        });
      }
    }
  }

  double get totalBalance {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }

  Future<void> _navigateToCreateAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBankAccountPage(),
      ),
    );

    if (result != null) {
      // Recarregar lista após criar conta
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Contas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _accounts.isEmpty
                  ? _buildEmptyState()
                  : _buildAccountsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateAccount,
        icon: const Icon(Icons.add),
        label: const Text('Nova Conta'),
        backgroundColor: const Color(0xFF08BF62),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Erro ao carregar contas',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAccounts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08BF62),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Color(0xFF08BF62),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma conta cadastrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione sua primeira conta bancária\npara começar a gerenciar suas finanças',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToCreateAccount,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08BF62),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
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

  Widget _buildAccountsList() {
    return RefreshIndicator(
      onRefresh: _loadAccounts,
      color: const Color(0xFF08BF62),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Card de saldo total
            _buildTotalBalanceCard(),
            
            // Lista de contas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Suas Contas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_accounts.length} ${_accounts.length == 1 ? "conta" : "contas"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      return _buildAccountCard(_accounts[index]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF08BF62),
            const Color(0xFF08BF62).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Saldo Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'R\$ ${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total em ${_accounts.length} ${_accounts.length == 1 ? "conta" : "contas"}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEditAccount(BankAccountWithIcon account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBankAccountPage(accountId: account.id),
      ),
    );

    if (result != null && result == true) {
      // Recarregar lista após editar conta
      _loadAccounts();
    }
  }

  Widget _buildAccountCard(BankAccountWithIcon account) {
    final hasColor = account.iconColor != null;
    final backgroundColor = hasColor
        ? Color(int.parse(account.iconColor!.substring(1), radix: 16) + 0xFF000000)
        : const Color(0xFF08BF62).withValues(alpha: 0.1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEditAccount(account),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícone da conta
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
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
                          );
                        },
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Informações da conta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.icon.isGeneric
                          ? 'Conta genérica'
                          : 'Instituição bancária',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Saldo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${account.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08BF62),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Saldo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

