import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/models/coffee_model.dart';
import '../providers/coffee_provider.dart';

class CoffeeDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const CoffeeDetailScreen({super.key, required this.id});

  @override
  ConsumerState<CoffeeDetailScreen> createState() => _CoffeeDetailScreenState();
}

class _CoffeeDetailScreenState extends ConsumerState<CoffeeDetailScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(coffeesProvider.notifier).fetchById(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coffeesProvider);
    final coffee = _findCoffee(state.coffees);

    if (coffee == null) {
      return const LoadingView(fullscreen: true, message: 'Cargando café...');
    }

    final img = coffee.imageFullUrl ?? coffee.imageUrl;

    return Scaffold(
      appBar: AppBar(title: Text(coffee.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'coffee-${coffee.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: img != null
                    ? Image.network(img, height: 260, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        height: 260,
                        width: double.infinity,
                        color: AppColors.color5,
                        child: const Icon(Icons.coffee_maker_outlined, size: 72, color: AppColors.color3),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Text(coffee.brand, style: const TextStyle(color: AppColors.color4)),
            Text(
              coffee.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(coffee.description ?? '', style: const TextStyle(color: AppColors.color4)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(coffee.price),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('${coffee.stock} en stock'),
                  backgroundColor: AppColors.color2,
                  side: const BorderSide(color: AppColors.color1),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Cantidad'),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.color5),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() {
                                  quantity = quantity - 1;
                                })
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setState(() {
                          quantity = quantity + 1;
                        }),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Agregar al carrito',
              icon: Icons.shopping_cart_outlined,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final failure = await ref.read(cartProvider.notifier).addToCart(coffee.id, quantity: quantity);
                final text = failure == null ? 'Producto agregado al carrito' : failure.message;
                messenger.showSnackBar(SnackBar(content: Text(text)));
              },
            ),
          ],
        ),
      ),
    );
  }

  CoffeeModel? _findCoffee(List<CoffeeModel> coffees) {
    for (final c in coffees) {
      if (c.id == widget.id) return c;
    }
    return null;
  }
}
