import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import 'client/edit_profile_screen.dart';
import 'client/notifications_screen.dart';
import 'client/help_center_screen.dart';
import 'client/privacy_policy_screen.dart';
import '../providers/business_provider.dart';
import 'business/edit_business_screen.dart';
import 'business/business_qr_screen.dart';
import 'client/business_detail_screen.dart';
import '../widgets/pending_feature_widget.dart';

class SettingsScreen extends StatefulWidget {
  final bool isBusiness;
  const SettingsScreen({super.key, this.isBusiness = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _logoutCtrl;
  late Animation<double> _logoutFade;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _logoutCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoutFade = CurvedAnimation(parent: _logoutCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _logoutCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sí, cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    await _logoutCtrl.forward();
    if (!mounted) return;
    await context.read<AppAuthProvider>().logout();
    // AuthGate handles the redirect
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              widget.isBusiness ? 'Mi Negocio' : 'Perfil',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Profile Card ───────────────────────────────────
                Consumer<AppAuthProvider>(
                  builder: (_, auth, _) => GestureDetector(
                    onTap: widget.isBusiness ? null : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ).then((_) => setState(() {})),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: cs.secondaryContainer,
                            backgroundImage: auth.user?.avatarUrl != null ? NetworkImage(auth.user!.avatarUrl!) : null,
                            child: auth.user?.avatarUrl == null
                                ? Icon(Icons.person, size: 40, color: cs.onSecondaryContainer)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.user?.name ?? 'Usuario',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                                ),
                                const SizedBox(height: 4),
                                Text(auth.user?.email ?? '', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
                                if (auth.user?.phone != null) ...[
                                  const SizedBox(height: 2),
                                  Text(auth.user!.phone!, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
                                ],
                                if (widget.isBusiness) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Cuenta de Negocio', style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!widget.isBusiness)
                            Icon(Icons.edit_outlined, size: 18, color: cs.onSurface.withValues(alpha: 0.3)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Cuenta ─────────────────────────────────────────
                if (!widget.isBusiness) ...[
                  _sectionTitle('CUENTA'),
                  _card([
                    _tile(context, 'Editar Perfil', Icons.person_outline, cs, onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ).then((_) => setState(() {}))),
                    _divider(),
                    _tile(context, 'Notificaciones', Icons.notifications_none, cs, onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    )),
                  ]),
                  const SizedBox(height: 24),
                ],

                // ── Preferencias ────────────────────────────────────
                _sectionTitle('PREFERENCIAS'),
                _card([
                  _tile(context, 'Idioma', Icons.language, cs,
                    trailing: Text('Español', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                    onTap: () => _showLanguageSheet(context),
                  ),
                  _divider(),
                  // Dark mode toggle
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.dark_mode_outlined, size: 20, color: cs.onSurface.withValues(alpha: 0.7)),
                    ),
                    title: Text('Modo Oscuro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface)),
                    activeThumbColor: cs.secondary,
                    value: BookioApp.of(context)?.isDarkMode ?? false,
                    onChanged: (value) => BookioApp.of(context)?.toggleDarkMode(value),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Negocio ────────────────────────────────────────
                if (widget.isBusiness) ...[
                  _sectionTitle('MI NEGOCIO'),
                  _card([
                    _tile(context, 'Configuración del Negocio', Icons.settings_applications_outlined, cs,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditBusinessScreen()),
                        ),
                      ),
                      _divider(),
                      _divider(),
                    _tile(context, 'Ver Perfil (Vista Cliente)', Icons.remove_red_eye_outlined, cs,
                      iconColor: Colors.teal,
                      iconBg: Colors.teal.shade50,
                      onTap: () {
                        final business = context.read<BusinessProvider>().myBusiness;
                        if (business != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: business)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró información del negocio')));
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],

                // ── Soporte ────────────────────────────────────────
                _sectionTitle('SOPORTE'),
                _card([
                  _tile(context, 'Centro de Ayuda', Icons.help_outline, cs, onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  )),
                  _divider(),
                  _tile(context, 'Política de Privacidad', Icons.privacy_tip_outlined, cs, onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  )),
                ]),
                const SizedBox(height: 32),

                // ── Logout ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('Bookio v1.0.0', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.25))),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),

        // ── Logout overlay animation ────────────────────────────
        if (_isLoggingOut)
          FadeTransition(
            opacity: _logoutFade,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 56, color: cs.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('Cerrando sesión...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Idioma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('🇲🇽', style: TextStyle(fontSize: 24)),
              title: const Text('Español', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.check_circle_rounded, color: cs.secondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: cs.secondaryContainer.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Más idiomas próximamente', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      title,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1.2),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
    ),
    child: Column(children: children),
  );

  Widget _divider() => Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.5), indent: 56);

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    ColorScheme cs, {
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? iconBg,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg ?? cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? cs.onSurface.withValues(alpha: 0.7)),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface)),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: cs.onSurface.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }
}
