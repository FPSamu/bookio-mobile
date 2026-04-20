import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'api_service.dart';

/// Servicio de autenticación — combina Firebase Auth con el backend propio.
///
/// Equivalente al `AuthContext` del frontend React.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _api = ApiService.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ────────────────────── Email / Password ──────────────────────

  /// Registro con email: crea usuario en Firebase + backend.
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String role,
    required String name,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final idToken = await credential.user!.getIdToken();

    final data = await _api.post('/auth/register', body: {
      'idToken': idToken,
      'role': role,
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });

    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Login con email: autentica en Firebase y obtiene perfil del backend.
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getMe();
  }

  // ────────────────────── Google Sign-In ──────────────────────

  /// Flujo completo de Google Sign-In.
  ///
  /// Si [role] es proporcionado, se registra al usuario en el backend (sign-up).
  /// Si es `null`, solo inicia sesión (el usuario ya debe existir).
  Future<AppUser> loginWithGoogle({String? role, String? name, String? phone}) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google Sign-In cancelado');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user!.getIdToken();

    if (role != null) {
      // Sign-up: crear usuario en el backend
      final data = await _api.post('/auth/register', body: {
        'idToken': idToken,
        'role': role,
        'name': name ?? userCredential.user!.displayName ?? '',
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (userCredential.user!.photoURL != null)
          'avatarUrl': userCredential.user!.photoURL,
      });
      return AppUser.fromJson(data['user'] as Map<String, dynamic>);
    }

    // Login: el usuario ya existe en el backend
    return getMe();
  }

  // ────────────────────── Perfil ──────────────────────

  /// Obtiene el perfil del usuario actual desde el backend.
  Future<AppUser> getMe() async {
    final data = await _api.get('/auth/me');
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ────────────────────── Logout ──────────────────────

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
