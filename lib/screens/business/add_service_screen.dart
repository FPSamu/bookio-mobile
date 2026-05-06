import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/business_provider.dart';

import '../../models/business_model.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceModel? service;
  const AddServiceScreen({super.key, this.service});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _duration;
  late double _price;
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.service?.name ?? '';
    _duration = widget.service?.durationMinutes ?? 30;
    _price = widget.service?.price ?? 0.0;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      if (widget.service == null) {
        await provider.createService(
          name: _name,
          durationMinutes: _duration,
          price: _price,
          photo: _image,
        );
      } else {
        await provider.updateService(
          widget.service!.id,
          name: _name,
          durationMinutes: _duration,
          price: _price,
          photo: _image,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.service == null ? 'Servicio creado' : 'Servicio actualizado'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.service == null ? 'Nuevo Servicio' : 'Editar Servicio')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          image: _image != null 
                            ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) 
                            : (widget.service?.photoUrl != null 
                                ? DecorationImage(image: NetworkImage(widget.service!.photoUrl!), fit: BoxFit.cover)
                                : null),
                        ),
                        child: (_image == null && widget.service?.photoUrl == null)
                            ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text('Toca para cambiar foto (Opcional)')),
                  const SizedBox(height: 32),
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Nombre del Servicio', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                    onSaved: (val) => _name = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _duration.toString(),
                    decoration: const InputDecoration(labelText: 'Duración (minutos)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (val) => int.tryParse(val ?? '') == null ? 'Ingresa un número válido' : null,
                    onSaved: (val) => _duration = int.tryParse(val ?? '') ?? 30,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _price.toString(),
                    decoration: const InputDecoration(labelText: 'Precio (\$)', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) => double.tryParse(val ?? '') == null ? 'Ingresa un monto válido' : null,
                    onSaved: (val) => _price = double.tryParse(val ?? '') ?? 0.0,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Guardar Servicio', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }
}
