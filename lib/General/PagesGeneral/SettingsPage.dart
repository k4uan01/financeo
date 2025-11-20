import 'package:flutter/material.dart';
import '../../General/ComponentsGeneral/CustomCard.dart';
import '../../General/ComponentsGeneral/CustomSnackBar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Seção de Aparência
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Aparência',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          CustomCard(
            child: SwitchListTile(
              title: const Text('Modo Escuro'),
              subtitle: const Text('Ativar tema escuro'),
              value: _isDarkMode,
              activeColor: const Color(0xFF08BF62),
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // TODO: Implementar mudança de tema
                CustomSnackBar.showInfo(
                  context,
                  'Mudança de tema será implementada em breve',
                );
              },
            ),
          ),

          // Seção de Notificações
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Notificações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          CustomCard(
            child: SwitchListTile(
              title: const Text('Notificações Push'),
              subtitle: const Text('Receber notificações do app'),
              value: _notificationsEnabled,
              activeColor: const Color(0xFF08BF62),
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),

          // Seção de Segurança
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Segurança',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          CustomCard(
            child: SwitchListTile(
              title: const Text('Autenticação Biométrica'),
              subtitle: const Text('Usar impressão digital ou face ID'),
              value: _biometricEnabled,
              activeColor: const Color(0xFF08BF62),
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
                // TODO: Implementar autenticação biométrica
                CustomSnackBar.showInfo(
                  context,
                  'Autenticação biométrica será implementada em breve',
                );
              },
            ),
          ),

          // Seção de Dados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Dados',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          CustomCard(
            onTap: () {
              // TODO: Implementar exportação de dados
              CustomSnackBar.showInfo(
                context,
                'Exportação de dados será implementada em breve',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.download, color: Color(0xFF08BF62)),
              title: Text('Exportar Dados'),
              subtitle: Text('Baixar seus dados em formato JSON'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          CustomCard(
            onTap: () {
              // TODO: Implementar backup
              CustomSnackBar.showInfo(
                context,
                'Backup automático será implementado em breve',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.backup, color: Color(0xFF08BF62)),
              title: Text('Backup Automático'),
              subtitle: Text('Fazer backup dos seus dados'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),

          // Seção de Sobre
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Sobre',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          CustomCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF08BF62)),
              title: Text('Sobre o App'),
              subtitle: Text('Informações sobre o Financeo'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          CustomCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpPage(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(Icons.help_outline, color: Color(0xFF08BF62)),
              title: Text('Ajuda'),
              subtitle: Text('Perguntas frequentes e suporte'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

