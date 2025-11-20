import 'package:flutter/material.dart';
import '../../General/ComponentsGeneral/AppLogo.dart';
import '../../General/ComponentsGeneral/CustomCard.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String version = '1.0.0';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const AppLogo(size: 120, borderRadius: 24),
            const SizedBox(height: 24),
            const Text(
              'Financeo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versão $version',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sistema de gerenciamento de entradas e gastos para mobile. '
                'Gerencie suas finanças de forma simples e eficiente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomCard(
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.code,
                    title: 'Desenvolvido com',
                    value: 'Flutter',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.storage,
                    title: 'Backend',
                    value: 'Supabase',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.palette,
                    title: 'Design',
                    value: 'Material Design 3',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.email,
                    title: 'Suporte',
                    value: 'suporte@financeo.com',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.policy,
                    title: 'Política de Privacidade',
                    value: 'Ver detalhes',
                    onTap: () {
                      // TODO: Implementar página de política de privacidade
                    },
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.description,
                    title: 'Termos de Uso',
                    value: 'Ver detalhes',
                    onTap: () {
                      // TODO: Implementar página de termos de uso
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© 2025 Financeo. Todos os direitos reservados.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF08BF62), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

