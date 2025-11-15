import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Auth/ComponentsAuth/CustomTextField.dart';
import '../../Auth/ComponentsAuth/PrimaryButton.dart';
import '../../services/bank_account_service.dart';
import '../../models/bank_account_model.dart';
import '../../models/bank_account_icon_model.dart';
import '../../models/icon_with_color.dart';
import '../ComponentsBankAccounts/IconSelectorBottomSheet.dart';

class CreateBankAccountPage extends StatefulWidget {
  const CreateBankAccountPage({super.key});

  @override
  State<CreateBankAccountPage> createState() => _CreateBankAccountPageState();
}

class _CreateBankAccountPageState extends State<CreateBankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _bankAccountService = BankAccountService();
  
  bool _isLoading = false;
  BankAccountIconModel? _selectedIcon;
  String? _selectedColor;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar se o ícone foi selecionado
    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Por favor, selecione um ícone'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validar se a cor foi selecionada para ícones genéricos
    if (_selectedIcon!.isGeneric && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Por favor, selecione uma cor para o ícone'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Converter saldo de texto para double
      final balance = double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0;

      // Chamar o serviço para criar a conta
      final result = await _bankAccountService.createBankAccount(
        name: _nameController.text.trim(),
        balance: balance,
        iconId: _selectedIcon!.id,
        iconColor: _selectedColor,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        final bankAccount = result['data'] as BankAccountModel;
        
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result['message'] ?? 'Conta criada com sucesso!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF08BF62),
            duration: const Duration(seconds: 3),
          ),
        );

        // Voltar para a tela anterior com os dados da conta criada
        Navigator.of(context).pop(bankAccount);
      } else {
        // Mostrar mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result['message'] ?? 'Erro ao criar conta'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Erro ao criar conta: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Conta Bancária',
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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone ilustrativo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08BF62).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Color(0xFF08BF62),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Título e descrição
                const Text(
                  'Criar nova conta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Adicione uma nova conta bancária para gerenciar suas finanças',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Campo Nome
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nome da Conta',
                  prefixIcon: Icons.account_balance,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, digite o nome da conta';
                    }
                    if (value.trim().length < 3) {
                      return 'O nome deve ter no mínimo 3 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),

                // Campo de Seleção de Ícone
                InkWell(
                  onTap: () async {
                    final result = await showIconSelector(context);
                    if (result != null) {
                      setState(() {
                        _selectedIcon = result.icon;
                        _selectedColor = result.color;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedIcon != null
                            ? const Color(0xFF08BF62)
                            : Colors.grey[300]!,
                        width: _selectedIcon != null ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Ícone selecionado ou placeholder
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _selectedIcon != null && _selectedColor != null
                                ? Color(int.parse(_selectedColor!.substring(1), radix: 16) + 0xFF000000)
                                : (_selectedIcon != null
                                    ? const Color(0xFF08BF62).withValues(alpha: 0.1)
                                    : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedIcon != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _selectedIcon!.isGeneric
                                      ? SvgPicture.string(
                                          _selectedIcon!.image,
                                          fit: BoxFit.contain,
                                          placeholderBuilder: (context) => const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : Image.network(
                                          _selectedIcon!.image,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.account_balance,
                                              color: Color(0xFF08BF62),
                                            );
                                          },
                                        ),
                                )
                              : Icon(
                                  Icons.account_balance_outlined,
                                  color: Colors.grey[400],
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedIcon != null
                                    ? _selectedIcon!.name
                                    : 'Selecionar ícone',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: _selectedIcon != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedIcon != null
                                      ? null
                                      : Colors.grey[600],
                                ),
                              ),
                              if (_selectedIcon != null)
                                Text(
                                  _selectedIcon!.type == 'generic'
                                      ? (_selectedColor != null
                                          ? 'Ícone genérico'
                                          : 'Selecione uma cor')
                                      : 'Instituição bancária',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedIcon!.isGeneric && _selectedColor == null
                                        ? Colors.orange[700]
                                        : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo Saldo
                CustomTextField(
                  controller: _balanceController,
                  labelText: 'Saldo Inicial',
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, digite o saldo inicial';
                    }
                    
                    final balance = double.tryParse(value.replaceAll(',', '.'));
                    if (balance == null) {
                      return 'Digite um valor válido';
                    }
                    
                    if (balance < 0) {
                      return 'O saldo não pode ser negativo';
                    }
                    
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Dica de formato
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Ex: 1000.00 ou 1000,00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botão de criar
                PrimaryButton(
                  text: 'Criar Conta',
                  onPressed: _handleCreateAccount,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Botão de cancelar
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: Colors.grey[600]!,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

