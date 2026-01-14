import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/shimmer_list.dart';
import '../../../../coffees/data/models/coffee_model.dart';
import '../../../../coffees/presentation/providers/coffee_provider.dart';

class AdminCoffeesScreen extends ConsumerStatefulWidget {
  const AdminCoffeesScreen({super.key});

  @override
  ConsumerState<AdminCoffeesScreen> createState() => _AdminCoffeesScreenState();
}

class _AdminCoffeesScreenState extends ConsumerState<AdminCoffeesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _description = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _active = true;
  CoffeeModel? _editing;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(coffeesProvider.notifier).fetch());
  }

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

  void _fillForm(CoffeeModel coffee) {
    setState(() {
      _editing = coffee;
      _name.text = coffee.name;
      _brand.text = coffee.brand;
      _price.text = coffee.price.toString();
      _stock.text = coffee.stock.toString();
      _description.text = coffee.description ?? '';
      _imageUrl.text = coffee.imageUrl ?? coffee.imageFullUrl ?? '';
      _active = coffee.isActive;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name': _name.text.trim(),
      'brand': _brand.text.trim(),
      'description': _description.text.trim(),
      'price': _price.text.trim(),
      'stock': _stock.text.trim(),
      'image_url': _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      'is_active': _active ? 1 : 0,
    };

    final notifier = ref.read(coffeesProvider.notifier);
    if (_editing != null) {
      final failure = await notifier.update(_editing!.id, payload);
      if (failure == null) _reset();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure == null ? 'Actualizado' : failure.message)));
    } else {
      final failure = await notifier.create(payload);
      if (failure == null) _reset();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure == null ? 'Creado' : failure.message)));
    }
  }

  void _reset() {
    setState(() {
      _editing = null;
      _name.clear();
      _brand.clear();
      _price.clear();
      _stock.clear();
      _description.clear();
      _imageUrl.clear();
      _active = true;
    });
  }

  Widget _inventoryPanel(bool isWide, CoffeesState state) {
    final content = state.loading
        ? const ShimmerList()
        : state.coffees.isEmpty
            ? EmptyState(
                title: 'No hay cafés',
                message: state.error ?? 'Crea un producto para comenzar.',
              )
            : Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/admin/coffees/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo café'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 720),
                      child: DataTable(
                        headingTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.color4),
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Marca')),
                          DataColumn(label: Text('Precio')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('')),
                        ],
                        rows: state.coffees
                            .map(
                              (c) => DataRow(
                                selected: _editing?.id == c.id,
                                cells: [
                                  DataCell(Text(c.name)),
                                  DataCell(Text(c.brand)),
                                  DataCell(Text(formatCurrency(c.price))),
                                  DataCell(Text('${c.stock}')),
                                  DataCell(
                                    Chip(
                                      label: Text(c.isActive ? 'Activo' : 'Inactivo'),
                                      backgroundColor: c.isActive ? Colors.green[50] : Colors.red[50],
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => _fillForm(c),
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () => ref.read(coffeesProvider.notifier).delete(c.id),
                                          icon: const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inventario actual', style: TextStyle(color: AppColors.color4)),
                    Text('Cafés activos: ${state.coffees.where((c) => c.isActive).length}',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                IconButton(
                  onPressed: () => ref.read(coffeesProvider.notifier).fetch(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _formPanel(bool isWide, CoffeesState state) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editing != null ? 'Editar café' : 'Nuevo café',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                  controller: _imageUrl,
                  decoration: const InputDecoration(labelText: 'Imagen (URL opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  title: const Text('Activo'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: _editing != null ? 'Guardar cambios' : 'Crear café',
                  onPressed: state.loading ? null : _submit,
                  loading: state.loading,
                ),
                if (_editing != null)
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Cancelar edición'),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coffeesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final inventory = _inventoryPanel(isWide, state);
        final form = _formPanel(isWide, state);

        if (!isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            child: Column(
              children: [
                inventory,
                const SizedBox(height: 16),
                form,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: inventory),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: form),
            ],
          ),
        );
      },
    );
  }
}
