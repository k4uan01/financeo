import 'package:flutter/material.dart';
import '../../main.dart';
import 'LoginPage.dart';

class AuthGatePage extends StatefulWidget {
  final Widget authenticatedScreen;

  const AuthGatePage({
    super.key,
    required this.authenticatedScreen,
  });

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Aguarda um pouco para evitar flash de tela
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    final session = supabase.auth.currentSession;
    
    if (session == null) {
      // Usuário não autenticado, redireciona para Login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          
          if (session != null) {
            // Usuário autenticado, mostra a tela principal
            return widget.authenticatedScreen;
          } else {
            // Usuário não autenticado, mostra a tela de login
            return const LoginPage();
          }
        }
        
        // Enquanto carrega, mostra splash screen
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF08BF62),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      'FA',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: Color(0xFF08BF62),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

