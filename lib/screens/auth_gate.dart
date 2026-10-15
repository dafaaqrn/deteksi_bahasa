import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        return switch (AuthService.instance.status) {
          AuthStatus.unknown => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          AuthStatus.authenticated => const MainScreen(),
          AuthStatus.unauthenticated => const LoginScreen(),
        };
      },
    );
  }
}