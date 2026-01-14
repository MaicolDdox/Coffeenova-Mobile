import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/coffee_provider.dart';

class CoffeeListScreen extends ConsumerStatefulWidget {
  const CoffeeListScreen({super.key});

  @override
  ConsumerState<CoffeeListScreen> createState() => _CoffeeListScreenState();
}

class _CoffeeListScreenState extends ConsumerState<CoffeeListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(coffeesProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coffeesProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(coffeesProvider.notifier).fetch(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Catálogo de cafés'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(coffeesProvider.notifier).fetch(),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/auth/login');
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Explora nuestra selección',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.color4),
              ),
            ),
          ),
          if (state.loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerList(),
              ),
            )
          else if (state.coffees.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Sin cafés',
                message: state.error ?? 'Aún no hay productos disponibles.',
              ),
            )
          else
            SliverList.separated(
              itemBuilder: (context, index) {
                final coffee = state.coffees[index];
                final img = coffee.imageFullUrl ?? coffee.imageUrl;
                return AppCard(
                  onTap: () => context.push('/client/coffees/${coffee.id}'),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'coffee-${coffee.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: img != null
                              ? Image.network(img, width: 88, height: 88, fit: BoxFit.cover)
                              : Container(
                                  width: 88,
                                  height: 88,
                                  color: AppColors.color5,
                                  child: const Icon(Icons.local_cafe, color: AppColors.color3),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coffee.brand, style: const TextStyle(color: AppColors.color4, fontSize: 12)),
                            Text(
                              coffee.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              coffee.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.color4),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatCurrency(coffee.price),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700)),
                                FilledButton(
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final failure =
                                        await ref.read(cartProvider.notifier).addToCart(coffee.id, quantity: 1);
                                    final text = failure == null ? 'Producto agregado' : failure.message;
                                    messenger.showSnackBar(SnackBar(content: Text(text)));
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.color1,
                                    foregroundColor: AppColors.color3,
                                  ),
                                  child: const Text('Agregar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: state.coffees.length,
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
