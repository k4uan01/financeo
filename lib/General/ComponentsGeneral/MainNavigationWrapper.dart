import 'package:flutter/material.dart';
import '../../main.dart';
import '../../Transactions/PagesTransactions/TransactionsPage.dart';
import '../../Transactions/PagesTransactions/CreateTransactionPage.dart';
import '../../BankAccounts/PagesBankAccounts/BankAccountsListPage.dart';
import '../../Categories/PagesCategories/CategoriesPage.dart';
import '../../Profile/PagesProfile/ProfilePage.dart';
import '../../services/user_provider.dart';
import '../../General/ComponentsGeneral/CustomBottomNavBar.dart';

// Instância global do UserProvider
final UserProvider userProvider = UserProvider();

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Carregar dados do usuário na inicialização
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await userProvider.loadUserOnInit();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == 2) {
      // Botão de adicionar transação
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateTransactionPage(),
        ),
      );
    } else if (index == 3) {
      // Opções rápidas - mostrar bottom sheet
      _showQuickOptionsBottomSheet();
    } else {
      setState(() {
        _currentIndex = index;
      });
      // Mapeia o índice da navbar para o índice da página
      // 0 = Home (página 0), 1 = Transactions (página 1), 4 = Profile (página 2)
      int pageIndex = index == 4 ? 2 : index;
      _pageController.jumpToPage(pageIndex);
    }
  }

  void _showQuickOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Opções Rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Opção: Categorias
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF08BF62),
                  ),
                ),
                title: const Text('Categorias'),
                subtitle: const Text('Gerenciar categorias'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesPage(),
                    ),
                  );
                },
              ),
              // Opção: Contas Bancárias
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF08BF62),
                  ),
                ),
                title: const Text('Contas Bancárias'),
                subtitle: const Text('Gerenciar contas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankAccountsListPage(),
                    ),
                  );
                },
              ),
              // Opção: Transações
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF08BF62),
                  ),
                ),
                title: const Text('Transações'),
                subtitle: const Text('Ver todas as transações'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 1;
                  });
                  _pageController.jumpToPage(1);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          // Mapeia o índice da página para o índice da navbar
          // 0 = Home, 1 = Transactions, 2 = Profile
          setState(() {
            if (index == 0) {
              _currentIndex = 0;
            } else if (index == 1) {
              _currentIndex = 1;
            } else if (index == 2) {
              _currentIndex = 4; // Profile está no índice 4 da navbar
            }
          });
        },
        children: const [
          HomePage(),
          TransactionsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

