import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primary = Colors.indigo;

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _loading         = false;
  bool _googleLoading   = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─── Handlers ─────────────────────────────────────────────────

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMessage = null; });

    try {
      await context.read<AppAuthProvider>().loginWithEmail(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // AuthGate redirige automáticamente
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _resolveFirebaseError(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'Ocurrió un error. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() { _googleLoading = true; _errorMessage = null; });

    try {
      await context.read<AppAuthProvider>().loginWithGoogle();
      // AuthGate redirige automáticamente
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _resolveFirebaseError(e.code));
    } catch (e) {
      // El usuario canceló el flujo de Google
      if (!e.toString().contains('cancelado')) {
        setState(() => _errorMessage = 'Error al iniciar con Google.');
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  String _resolveFirebaseError(String code) {
    const map = {
      'user-not-found':         'No existe una cuenta con este correo.',
      'wrong-password':         'Contraseña incorrecta.',
      'invalid-credential':     'Correo o contraseña incorrectos.',
      'invalid-email':          'El correo no es válido.',
      'user-disabled':          'Esta cuenta ha sido deshabilitada.',
      'too-many-requests':      'Demasiados intentos. Espera un momento.',
      'network-request-failed': 'Sin conexión. Revisa tu internet.',
    };
    return map[code] ?? 'Ocurrió un error. Intenta de nuevo.';
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo ──────────────────────────────────────
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 64, bottom: 48),
                    child: Text(
                      'Bookio',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // ── Error banner ──────────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Email ─────────────────────────────────────
                _buildLabel('Correo Electrónico'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'El correo es requerido.';
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Ingresa un correo válido.';
                    return null;
                  },
                  decoration: _inputDecoration(hint: 'ejemplo@correo.com', icon: Icons.email_outlined),
                ),
                const SizedBox(height: 24),

                // ── Password ──────────────────────────────────
                _buildLabel('Contraseña'),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => (v == null || v.isEmpty) ? 'La contraseña es requerida.' : null,
                  decoration: _inputDecoration(
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Forgot password ───────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(),
                    style: TextButton.styleFrom(foregroundColor: _primary, padding: EdgeInsets.zero),
                    child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Login Button ──────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_loading || _googleLoading) ? null : _handleEmailLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('O', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: (_loading || _googleLoading) ? null : _handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _googleLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/3840px-Google_%22G%22_logo.svg.png',
                                height: 22, width: 22,
                                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                              ),
                              const SizedBox(width: 14),
                              const Text('Continuar con Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes una cuenta?', style: TextStyle(color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterSelectionScreen()),
                      ),
                      style: TextButton.styleFrom(foregroundColor: _primary),
                      child: const Text('Regístrate', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Forgot Password Dialog ───────────────────────────────────

  void _showForgotPasswordDialog() {
    final resetCtrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Recuperar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: resetCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(hint: 'ejemplo@correo.com', icon: Icons.email_outlined),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (resetCtrl.text.trim().isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                await FirebaseAuth.instance.sendPasswordResetEmail(email: resetCtrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Correo de recuperación enviado ✔'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      );

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _primary, width: 2)),
        errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade400)),
      );
}