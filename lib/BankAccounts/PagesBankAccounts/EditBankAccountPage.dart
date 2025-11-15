import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Auth/ComponentsAuth/CustomTextField.dart';
import '../../Auth/ComponentsAuth/PrimaryButton.dart';
import '../../services/bank_account_service.dart';
import '../../models/bank_account_model.dart';
import '../../models/bank_account_with_icon.dart';
import '../../models/bank_account_icon_model.dart';
import '../../models/icon_with_color.dart';
import '../ComponentsBankAccounts/IconSelectorBottomSheet.dart';

class EditBankAccountPage extends StatefulWidget {
  final String accountId;

  const EditBankAccountPage({super.key, required this.accountId});

  @override
  State<EditBankAccountPage> createState() => _EditBankAccountPageState();
}

class _EditBankAccountPageState extends State<EditBankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _bankAccountService = BankAccountService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  BankAccountIconModel? _selectedIcon;
  String? _selectedColor;

  // Dados originais para comparação
  String? _originalName;
  double? _originalBalance;
  String? _originalIconId;
  String? _originalIconColor;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _bankAccountService.getBankAccount(widget.accountId);

      if (!mounted) return;

      if (result['status'] == true) {
        final account = result['data'] as BankAccountWithIcon;

        setState(() {
          // Preencher campos
          _nameController.text = account.name;
          _balanceController.text = account.balance.toStringAsFixed(2);

          // Converter IconData para BankAccountIconModel
          _selectedIcon = BankAccountIconModel(
            id: account.icon.id,
            name: '', // Nome não vem na resposta da API get_bank_account
            image: account.icon.image,
            type: account.icon.type,
          );
          _selectedColor = account.iconColor;

          // Guardar valores originais
          _originalName = account.name;
          _originalBalance = account.balance;
          _originalIconId = account.icon.id;
          _originalIconColor = account.iconColor;

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erro ao carregar conta'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar conta: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleSaveAccount() async {
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
              Expanded(child: Text('Por favor, selecione um ícone')),
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
      _isSaving = true;
    });

    try {
      // Converter saldo de texto para double
      final balance =
          double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0;
      final name = _nameController.text.trim();

      // Verificar quais campos foram alterados
      final nameChanged = name != _originalName;
      final balanceChanged = balance != _originalBalance;
      final iconChanged = _selectedIcon!.id != _originalIconId;
      final colorChanged = _selectedColor != _originalIconColor;

      if (!nameChanged && !balanceChanged && !iconChanged && !colorChanged) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma alteração foi feita'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Chamar o serviço para editar a conta (enviar apenas campos alterados)
      final result = await _bankAccountService.editBankAccount(
        accountId: widget.accountId,
        name: nameChanged ? name : null,
        balance: balanceChanged ? balance : null,
        iconId: iconChanged ? _selectedIcon!.id : null,
        iconColor: colorChanged ? _selectedColor : null,
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
                  child: Text(
                    result['message'] ?? 'Conta atualizada com sucesso!',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF08BF62),
            duration: const Duration(seconds: 3),
          ),
        );

        // Voltar para a tela anterior com os dados da conta atualizada
        Navigator.of(context).pop(true);
      } else {
        // Mostrar mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result['message'] ?? 'Erro ao atualizar conta'),
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
              Expanded(child: Text('Erro ao atualizar conta: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza de que deseja excluir esta conta bancária? '
          'Essa ação é permanente e não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await _bankAccountService.deleteBankAccount(
        accountId: widget.accountId,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_forever, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Conta bancária excluída com sucesso',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Erro ao excluir conta bancária',
                  ),
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
              Expanded(child: Text('Erro ao excluir conta bancária: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                          Icons.edit,
                          size: 80,
                          color: Color(0xFF08BF62),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Título e descrição
                      const Text(
                        'Editar conta bancária',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Atualize as informações da sua conta',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                              _selectedIcon = BankAccountIconModel(
                                id: result.icon.id,
                                name: result.icon.name,
                                image: result.icon.image,
                                type: result.icon.type,
                              );
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
                                  color:
                                      _selectedIcon != null &&
                                          _selectedColor != null
                                      ? Color(
                                          int.parse(
                                                _selectedColor!.substring(1),
                                                radix: 16,
                                              ) +
                                              0xFF000000,
                                        )
                                      : (_selectedIcon != null
                                            ? const Color(
                                                0xFF08BF62,
                                              ).withValues(alpha: 0.1)
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
                                                placeholderBuilder: (context) =>
                                                    const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                              )
                                            : Image.network(
                                                _selectedIcon!.image,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.account_balance,
                                                        color: Color(
                                                          0xFF08BF62,
                                                        ),
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
                                          ? 'Ícone selecionado'
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
                                          color:
                                              _selectedIcon!.isGeneric &&
                                                  _selectedColor == null
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
                        labelText: 'Saldo',
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, digite o saldo';
                          }

                          final balance = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
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

                      // Botão de salvar
                      PrimaryButton(
                        text: 'Salvar Alterações',
                        onPressed: _isSaving || _isDeleting
                            ? null
                            : _handleSaveAccount,
                        isLoading: _isSaving,
                      ),

                      const SizedBox(height: 16),

                      // Botão de excluir
                      TextButton.icon(
                        onPressed: _isSaving || _isDeleting
                            ? null
                            : _handleDeleteAccount,
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                        label: Text(
                          _isDeleting ? 'Excluindo...' : 'Excluir Conta',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botão de cancelar
                      OutlinedButton(
                        onPressed: _isSaving || _isDeleting
                            ? null
                            : () => Navigator.of(context).pop(),
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
