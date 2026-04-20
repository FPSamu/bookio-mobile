import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart'; // AppAuthProvider
import 'login_screen.dart';
import '../main_navigation.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bookio',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.indigo,
              ),
            ],
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return MainNavigation(userRole: auth.role);
    }

    return const LoginScreen();
  }
}
