import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/business_service.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _teal    = Colors.teal;

const _businessTypes = [
  _BusinessType('restaurant', 'Restaurante', Icons.restaurant),
  _BusinessType('spa',        'Spa',         Icons.spa),
  _BusinessType('medical',    'Médico',      Icons.local_hospital_outlined),
  _BusinessType('salon',      'Salón',       Icons.content_cut),
];

const _businessNameHints = {
  'restaurant': 'El Origen',
  'spa':        'Zen Garden Spa',
  'medical':    'Clínica Salud Integral',
  'salon':      'Studio 54 Hair',
};

// ─── Data class ───────────────────────────────────────────────────────────────

class _BusinessType {
  final String value;
  final String label;
  final IconData icon;
  const _BusinessType(this.value, this.label, this.icon);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _businessNameCtrl = TextEditingController();
  final _addressCtrl      = TextEditingController();
  final _contactNameCtrl  = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmCtrl      = TextEditingController();

  String _businessType   = 'restaurant';
  bool _obscurePassword  = true;
  bool _obscureConfirm   = true;
  bool _loading          = false;
  String? _apiError;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _addressCtrl.dispose();
    _contactNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─── Validation ───────────────────────────────────────────────

  String? _req(String? v, String msg)   => (v == null || v.trim().isEmpty) ? msg : null;
  String? _validateEmail(String? v)     => _req(v, 'El correo es requerido.') ??
      (RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? null : 'Ingresa un correo válido.');
  String? _validatePhone(String? v)     => _req(v, 'El teléfono es requerido.') ??
      (RegExp(r'^\+?[\d\s\-()]{7,15}$').hasMatch(v!.trim()) ? null : 'Ingresa un teléfono válido.');
  String? _validatePassword(String? v)  => _req(v, 'La contraseña es requerida.') ??
      (v!.length >= 8 ? null : 'Mínimo 8 caracteres.');
  String? _validateConfirm(String? v)   => _req(v, 'Confirma tu contraseña.') ??
      (v == _passwordCtrl.text ? null : 'Las contraseñas no coinciden.');

  // ─── Submit ───────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; _apiError = null; });

    try {
      // 1. Crear usuario en Firebase + registrar en backend como BUSINESS_OWNER
      await context.read<AppAuthProvider>().registerBusinessOwner(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name:     _contactNameCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim(),
      );

      // 2. Registrar el negocio en el backend
      await BusinessService.instance.registerBusiness(
        name:    _businessNameCtrl.text.trim(),
        type:    _businessType,
        address: _addressCtrl.text.trim(),
      );

      // 3. Limpiar stack para que AuthGate muestre el dashboard de negocio
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _apiError = _resolveFirebaseError(e.code));
    } catch (e) {
      setState(() => _apiError = 'Ocurrió un error. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _resolveFirebaseError(String code) {
    const map = {
      'email-already-in-use':   'Este correo ya está registrado.',
      'invalid-email':          'El correo no es válido.',
      'weak-password':          'La contraseña es muy débil.',
      'network-request-failed': 'Sin conexión. Revisa tu internet.',
    };
    return map[code] ?? 'Ocurrió un error. Intenta de nuevo.';
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────
                const Text(
                  'Registrar negocio',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text('Publica tus servicios y gestiona tu agenda.', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                const SizedBox(height: 28),

                // ── Error banner ──────────────────────────────
                if (_apiError != null) ...[
                  _errorBanner(_apiError!),
                  const SizedBox(height: 20),
                ],

                // ── Business type selector ────────────────────
                _buildTypeSelector(),
                const SizedBox(height: 20),

                // ── Business name ─────────────────────────────
                _buildField(
                  controller: _businessNameCtrl,
                  label: 'Nombre del negocio',
                  hint: _businessNameHints[_businessType] ?? 'Mi Negocio',
                  icon: Icons.storefront_outlined,
                  validator: (v) => _req(v, 'El nombre del negocio es requerido.'),
                ),
                const SizedBox(height: 20),

                // ── Address (optional) ────────────────────────
                _buildField(
                  controller: _addressCtrl,
                  label: 'Dirección (opcional)',
                  hint: 'Av. Presidente Masaryk 61, CDMX',
                  icon: Icons.location_on_outlined,
                  validator: (_) => null,
                ),
                const SizedBox(height: 20),

                // ── Contact name ──────────────────────────────
                _buildField(
                  controller: _contactNameCtrl,
                  label: 'Nombre de contacto',
                  hint: 'Juan Pérez',
                  icon: Icons.person_outline,
                  validator: (v) => _req(v, 'El nombre de contacto es requerido.'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),

                // ── Email + Phone side by side ────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _emailCtrl,
                        label: 'Correo electrónico',
                        hint: 'contacto@negocio.com',
                        icon: Icons.email_outlined,
                        validator: _validateEmail,
                        keyboard: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _phoneCtrl,
                        label: 'Teléfono',
                        hint: '+52 55 0000 0000',
                        icon: Icons.phone_outlined,
                        validator: _validatePhone,
                        keyboard: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Passwords ─────────────────────────────────
                _buildPasswordField(
                  controller: _passwordCtrl,
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmCtrl,
                  label: 'Confirmar contraseña',
                  hint: 'Repite tu contraseña',
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 32),

                // ── Submit ────────────────────────────────────
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Registrar negocio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Components ───────────────────────────────────────────────

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tipo de negocio'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _businessTypes.map((t) {
            final isActive = _businessType == t.value;
            return GestureDetector(
              onTap: () => setState(() {
                _businessType = t.value;
                _businessNameCtrl.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? _teal : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isActive ? _teal : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: (_teal as Color).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon, size: 15, color: isActive ? Colors.white : Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: _inputDecoration(
            hint: hint,
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
      );

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border:             OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _teal, width: 1.8)),
        errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade300)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade400)),
      );

  Widget _errorBanner(String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Text(message, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
      );
}
