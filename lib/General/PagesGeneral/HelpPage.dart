import 'package:flutter/material.dart';
import '../../General/ComponentsGeneral/CustomCard.dart';
import '../../General/ComponentsGeneral/CustomSnackBar.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Perguntas Frequentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildQuestionCard(
            context,
            question: 'Como adicionar uma nova transação?',
            answer:
                'Toque no botão "+" no centro da barra de navegação inferior '
                'ou acesse a página de Transações e toque em "Nova Transação".',
          ),
          _buildQuestionCard(
            context,
            question: 'Como criar uma categoria?',
            answer:
                'Acesse o menu de Categorias através das opções rápidas ou '
                'pela navegação principal, depois toque em "Criar Categoria".',
          ),
          _buildQuestionCard(
            context,
            question: 'Como adicionar uma conta bancária?',
            answer:
                'Acesse "Contas Bancárias" pelo menu principal ou pelas '
                'opções rápidas, depois toque em "Adicionar Conta".',
          ),
          _buildQuestionCard(
            context,
            question: 'Como editar uma transação?',
            answer:
                'Na página de Transações, toque na transação que deseja editar '
                'e depois toque no ícone de edição.',
          ),
          _buildQuestionCard(
            context,
            question: 'Como excluir uma transação?',
            answer:
                'Na página de detalhes da transação, toque no ícone de excluir '
                'e confirme a ação.',
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Contato',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomCard(
            onTap: () {
              CustomSnackBar.showInfo(
                context,
                'Email: suporte@financeo.com',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.email, color: Color(0xFF08BF62)),
              title: Text('Enviar Email'),
              subtitle: Text('suporte@financeo.com'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          CustomCard(
            onTap: () {
              CustomSnackBar.showInfo(
                context,
                'Funcionalidade de chat será implementada em breve',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: Color(0xFF08BF62)),
              title: Text('Chat de Suporte'),
              subtitle: Text('Fale conosco em tempo real'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

