import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../coffees/presentation/providers/coffee_provider.dart';

class AdminCreateCoffeeScreen extends ConsumerStatefulWidget {
  const AdminCreateCoffeeScreen({super.key});

  @override
  ConsumerState<AdminCreateCoffeeScreen> createState() => _AdminCreateCoffeeScreenState();
}

class _AdminCreateCoffeeScreenState extends ConsumerState<AdminCreateCoffeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _description = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _active = true;
  PlatformFile? _pickedFile;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _price.dispose();
    _stock.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _imageUrl.clear();
      });
    }
  }

  Future<FormData> _buildFormData() async {
    final formData = FormData.fromMap({
      'name': _name.text.trim(),
      'brand': _brand.text.trim(),
      'description': _description.text.trim(),
      'price': _price.text.trim(),
      'stock': _stock.text.trim(),
      'is_active': _active ? 1 : 0,
      if (_imageUrl.text.trim().isNotEmpty) 'image_url': _imageUrl.text.trim(),
    });

    if (_pickedFile != null && _pickedFile!.path != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(_pickedFile!.path!, filename: _pickedFile!.name),
        ),
      );
    }

    return formData;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(coffeesProvider.notifier);
    final formData = await _buildFormData();
    final failure = await notifier.create(formData);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(failure == null ? 'Café creado' : failure.message)));
    if (failure == null) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coffeesProvider);
    final imagePreview = _pickedFile?.path != null ? File(_pickedFile!.path!).path : _imageUrl.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear café'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _brand,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stock,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrl,
                  decoration: const InputDecoration(labelText: 'Imagen (URL opcional)'),
                  onChanged: (_) => setState(() {
                    if (_imageUrl.text.isNotEmpty) _pickedFile = null;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload),
                      label: const Text('Subir imagen'),
                    ),
                    const SizedBox(width: 12),
                    if (_pickedFile != null) Text(_pickedFile!.name),
                  ],
                ),
                const SizedBox(height: 12),
                if (imagePreview.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imagePreview.startsWith('http')
                        ? Image.network(imagePreview, height: 160, fit: BoxFit.cover)
                        : Image.file(File(imagePreview), height: 160, fit: BoxFit.cover),
                  ),
                SwitchListTile(
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  title: const Text('Activo'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Crear café',
                  loading: state.loading,
                  onPressed: state.loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
