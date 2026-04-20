import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Proveedor de estado de autenticación — equivalente al `AuthContext` React.
///
/// Escucha `authStateChanges` de Firebase y sincroniza el perfil del backend.
/// Nombrado [AppAuthProvider] para evitar conflicto con la clase interna de Firebase.
class AppAuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = true;

  AppUser? get user        => _user;
  bool get isLoading       => _isLoading;
  bool get isAuthenticated => _user != null;
  String get role          => _user?.role ?? '';

  AppAuthProvider() {
    _listenToAuthState();
  }

  // ────────────────────── Listener ──────────────────────

  void _listenToAuthState() {
    AuthService.instance.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _user = await AuthService.instance.getMe();
    } catch (_) {
      // 401: Firebase session exists but user not in backend yet (first visit)
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────── Email / Password ──────────────────────

  Future<void> registerClient({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _user = await AuthService.instance.registerWithEmail(
      email: email,
      password: password,
      role: 'CLIENT',
      name: name,
      phone: phone,
    );
    notifyListeners();
  }

  Future<void> registerBusinessOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _user = await AuthService.instance.registerWithEmail(
      email: email,
      password: password,
      role: 'BUSINESS_OWNER',
      name: name,
      phone: phone,
    );
    notifyListeners();
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _user = await AuthService.instance.loginWithEmail(
      email: email,
      password: password,
    );
    notifyListeners();
  }

  // ────────────────────── Google ──────────────────────

  /// [role] nulo = login (usuario ya existe). Con role = sign-up.
  Future<void> loginWithGoogle({String? role}) async {
    _user = await AuthService.instance.loginWithGoogle(role: role);
    notifyListeners();
  }

  // ────────────────────── Logout ──────────────────────

  Future<void> logout() async {
    await AuthService.instance.logout();
    _user = null;
    notifyListeners();
  }
}
