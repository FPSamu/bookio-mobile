import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/business_service.dart';
import '../../models/business_model.dart';
import '../business/add_service_screen.dart';

class BusinessRegisterScreen extends StatefulWidget {
  final bool isGoogle;
  const BusinessRegisterScreen({super.key, this.isGoogle = false});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _loading = false;
  String? _apiError;

  // --- Step 1: Account ---
  final _formKeyStep1 = GlobalKey<FormState>();
  final _contactNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;

  // --- Step 2: Business Info ---
  final _formKeyStep2 = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  String _businessType = 'restaurant';
  File? _logoFile;
  final List<File?> _photoFiles = List.filled(4, null);

  // --- Step 3: Location & Schedule ---
  final _formKeyStep3 = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  double _latitude = 20.6668;
  double _longitude = -103.3918;
  final MapController _mapController = MapController();
  Map<int, Map<String, dynamic>> _schedules = {};

  // --- Step 4: Services ---
  List<ServiceModel> _tempServices = [];

  @override
  void dispose() {
    _pageController.dispose();
    _contactNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _businessNameCtrl.dispose();
    _addressCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // --- Stepper Logic ---
  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // --- Account Creation ---
  Future<void> _createAccount() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    setState(() { _loading = true; _apiError = null; });

    try {
      if (widget.isGoogle) {
        await context.read<AppAuthProvider>().completeGoogleSignUp(
          role: 'BUSINESS_OWNER',
          name: _contactNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
      } else {
        await context.read<AppAuthProvider>().registerBusinessOwner(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          name: _contactNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
      }
      _nextPage();
    } on FirebaseAuthException catch (e) {
      setState(() => _apiError = _resolveFirebaseError(e.code));
    } catch (e) {
      setState(() => _apiError = 'Error al crear cuenta.');
    } finally {
      setState(() => _loading = false);
    }
  }

  // --- Business Finalization ---
  Future<void> _finalizeRegistration() async {
    setState(() => _loading = true);
    try {
      // 1. Register Business
      await BusinessService.instance.registerBusiness(
        name: _businessNameCtrl.text.trim(),
        type: _businessType,
        address: _addressCtrl.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      // 2. Upload Logo/Photos
      if (_logoFile != null) await context.read<BusinessProvider>().uploadLogo(_logoFile!);
      final validPhotos = _photoFiles.where((f) => f != null).cast<File>().toList();
      if (validPhotos.isNotEmpty) await context.read<BusinessProvider>().uploadPhotos(validPhotos);

      // 3. Upload Schedules
      for (var day in _schedules.keys) {
        await BusinessService.instance.upsertSchedule(
          dayOfWeek: day,
          startTime: _schedules[day]!['start'],
          endTime: _schedules[day]!['end'],
        );
      }

      // 4. Create Services
      for (var s in _tempServices) {
        await context.read<BusinessProvider>().createService(
          name: s.name,
          durationMinutes: s.durationMinutes,
          price: s.price,
        );
      }

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _apiError = 'Error al configurar negocio: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _resolveFirebaseError(String code) {
    const map = {
      'email-already-in-use': 'Este correo ya está registrado.',
      'invalid-email': 'El correo no es válido.',
      'weak-password': 'La contraseña es muy débil.',
    };
    return map[code] ?? 'Ocurrió un error inesperado.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Paso ${_currentStep + 1} de 4', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: _currentStep > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevPage) : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentStep + 1) / 4, color: Colors.teal, backgroundColor: Colors.teal.withValues(alpha: 0.1)),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (v) => setState(() => _currentStep = v),
                children: [
                  _stepAccount(),
                  _stepBusinessInfo(),
                  _stepLocationSchedule(),
                  _stepServices(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: ACCOUNT ---
  Widget _stepAccount() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Crea tu cuenta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Comencemos con tus datos personales.', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 32),
            if (_apiError != null) _errorBanner(_apiError!),
            _buildField(controller: _contactNameCtrl, label: 'Nombre Completo', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 20),
            if (!widget.isGoogle) ...[
              _buildField(controller: _emailCtrl, label: 'Correo', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 20),
              _buildPasswordField(controller: _passwordCtrl, label: 'Contraseña', obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), validator: (v) => v!.length < 8 ? 'Mínimo 8 caracteres' : null),
              const SizedBox(height: 20),
            ],
            _buildField(controller: _phoneCtrl, label: 'Teléfono', icon: Icons.phone_outlined, keyboard: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loading ? null : _createAccount,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Siguiente: Datos del Negocio', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: BUSINESS INFO ---
  Widget _stepBusinessInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tu Negocio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildField(controller: _businessNameCtrl, label: 'Nombre del Negocio', icon: Icons.storefront, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 32),
            const Text('Logo del Negocio', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: _logoFile != null ? FileImage(_logoFile!) : null,
                  child: _logoFile == null ? const Icon(Icons.add_a_photo, color: Colors.teal) : null,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Galería de Fotos (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5),
              itemCount: 4,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _pickPhoto(i),
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), image: _photoFiles[i] != null ? DecorationImage(image: FileImage(_photoFiles[i]!), fit: BoxFit.cover) : null),
                  child: _photoFiles[i] == null ? const Icon(Icons.add, color: Colors.grey) : null,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Siguiente: Ubicación y Horarios', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 3: LOCATION & SCHEDULE ---
  Widget _stepLocationSchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ubicación y Horarios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildField(
            controller: _addressCtrl,
            label: 'Dirección',
            icon: Icons.location_on_outlined,
            validator: (v) => v!.isEmpty ? 'Requerido' : null,
            onChanged: (v) {
              // Simple geocode logic could go here
            }
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: LatLng(_latitude, _longitude), initialZoom: 15, onTap: (_, latLng) => setState(() { _latitude = latLng.latitude; _longitude = latLng.longitude; })),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bookio.app',
                ),
                MarkerLayer(markers: [Marker(point: LatLng(_latitude, _longitude), child: const Icon(Icons.location_pin, color: Colors.red, size: 40))]),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Horarios de Atención', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildScheduleList(),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Siguiente: Servicios', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: SERVICES ---
  Widget _stepServices() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tus Servicios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Añade los servicios que ofrecerás.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          if (_tempServices.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  const Icon(Icons.spa_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aún no has añadido servicios', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _addTempService,
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir mi primer servicio'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ..._tempServices.map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.spa, color: Colors.white, size: 18)),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${s.durationMinutes} min • \$${s.price}'),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => setState(() => _tempServices.remove(s))),
                  ),
                )),
                const SizedBox(height: 12),
                TextButton.icon(onPressed: _addTempService, icon: const Icon(Icons.add), label: const Text('Añadir otro servicio')),
              ],
            ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: (_tempServices.isEmpty || _loading) ? null : _finalizeRegistration,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Finalizar Registro', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          if (_tempServices.isEmpty)
            Center(child: Text('Debes añadir al menos un servicio para continuar', style: TextStyle(color: Colors.red.shade400, fontSize: 12))),
        ],
      ),
    );
  }

  // --- Helper Methods ---
  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _logoFile = File(picked.path));
  }

  Future<void> _pickPhoto(int i) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photoFiles[i] = File(picked.path));
  }

  void _addTempService() async {
    // Show a dialog to add service info temporarily
    final nameCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '30');
    final priceCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: durCtrl, decoration: const InputDecoration(labelText: 'Duración (min)'), keyboardType: TextInputType.number),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
              setState(() {
                _tempServices.add(ServiceModel(
                  id: '', // Temporary
                  name: nameCtrl.text,
                  durationMinutes: int.parse(durCtrl.text),
                  price: double.parse(priceCtrl.text),
                ));
              });
              Navigator.pop(ctx);
            }
          }, child: const Text('Añadir')),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return Column(
      children: List.generate(7, (i) {
        final isOpen = _schedules.containsKey(i);
        return Row(
          children: [
            SizedBox(width: 50, child: Text(days[i])),
            const Spacer(),
            if (isOpen)
              Text('${_schedules[i]!['start']} - ${_schedules[i]!['end']}')
            else
              const Text('Cerrado', style: TextStyle(color: Colors.grey)),
            Switch(
              value: isOpen,
              onChanged: (val) {
                if (val) {
                  setState(() => _schedules[i] = {'start': '09:00', 'end': '18:00'});
                } else {
                  setState(() => _schedules.remove(i));
                }
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, required IconData icon, required String? Function(String?) validator, TextInputType keyboard = TextInputType.text, Function(String)? onChanged}) {
    return TextFormField(controller: controller, keyboardType: keyboard, validator: validator, onChanged: onChanged, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true, fillColor: Colors.grey.shade50));
  }

  Widget _buildPasswordField({required TextEditingController controller, required String label, required bool obscure, required VoidCallback onToggle, required String? Function(String?) validator}) {
    return TextFormField(controller: controller, obscureText: obscure, validator: validator, decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock_outline, size: 20), suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggle), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true, fillColor: Colors.grey.shade50));
  }

  Widget _buildTypeSelector() {
    final types = [
      {'val': 'restaurant', 'lab': 'Restaurante', 'ico': Icons.restaurant},
      {'val': 'spa', 'lab': 'Spa', 'ico': Icons.spa},
      {'val': 'medical', 'lab': 'Médico', 'ico': Icons.medical_services},
      {'val': 'salon', 'lab': 'Salón', 'ico': Icons.content_cut},
    ];
    return Wrap(
      spacing: 8,
      children: types.map((t) {
        final active = _businessType == t['val'];
        return ChoiceChip(
          label: Text(t['lab'] as String),
          selected: active,
          onSelected: (v) {
            if (v) setState(() => _businessType = t['val'] as String);
          },
          selectedColor: Colors.teal,
          labelStyle: TextStyle(color: active ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }

  Widget _errorBanner(String msg) => Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)), child: Text(msg, style: TextStyle(color: Colors.red.shade700, fontSize: 13)));
}
