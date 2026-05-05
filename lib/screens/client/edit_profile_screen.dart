import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppAuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final source = await _showSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
    if (image == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await AuthService.instance.uploadAvatar(File(image.path));
      if (mounted) {
        context.read<AppAuthProvider>().setUser(updated);
        messenger.showSnackBar(SnackBar(
          content: const Text('Foto actualizada'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Error al subir la foto: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<ImageSource?> _showSourceSheet() {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.photo_library_outlined, color: cs.onSecondaryContainer),
                ),
                title: const Text('Galería', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Elige una foto existente'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.camera_alt_outlined, color: cs.onSecondaryContainer),
                ),
                title: const Text('Cámara', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Toma una nueva foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final updated = await AuthService.instance.updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      if (mounted) {
        context.read<AppAuthProvider>().setUser(updated);
        navigator.pop();
        messenger.showSnackBar(SnackBar(
          content: const Text('Perfil actualizado'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : TextButton(
                    onPressed: _save,
                    child: Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, color: cs.secondary)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar with upload button
              Consumer<AppAuthProvider>(
                builder: (_, auth, _) => Center(
                  child: GestureDetector(
                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: cs.secondaryContainer,
                          backgroundImage: auth.user?.avatarUrl != null ? NetworkImage(auth.user!.avatarUrl!) : null,
                          child: auth.user?.avatarUrl == null
                              ? Icon(Icons.person, size: 52, color: cs.onSecondaryContainer)
                              : null,
                        ),
                        // Loading overlay
                        if (_isUploadingAvatar)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                              child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                            ),
                          ),
                        // Camera icon
                        if (!_isUploadingAvatar)
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, size: 16, color: cs.onPrimary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para cambiar foto',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)', prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // Non-editable email
              Consumer<AppAuthProvider>(
                builder: (_, auth, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Correo electrónico', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                            Text(auth.user?.email ?? '', style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface)),
                          ],
                        ),
                      ),
                      Text('No editable', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.35))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
