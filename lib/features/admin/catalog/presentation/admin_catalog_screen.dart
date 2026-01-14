import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../coffees/presentation/providers/coffee_provider.dart';

class AdminCatalogScreen extends ConsumerStatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  ConsumerState<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends ConsumerState<AdminCatalogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(coffeesProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coffeesProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Catálogo (solo lectura)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(coffeesProvider.notifier).fetch(),
            ),
          ],
        ),
        if (state.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(),
            ),
          )
        else if (state.coffees.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'Sin cafés',
              message: state.error ?? 'No hay productos disponibles.',
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
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: img != null
                          ? Image.network(img, width: 80, height: 80, fit: BoxFit.cover)
                          : Container(
                              width: 80,
                              height: 80,
                              color: AppColors.color5,
                              child: const Icon(Icons.local_cafe),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coffee.brand, style: const TextStyle(color: AppColors.color4)),
                          Text(
                            coffee.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(coffee.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(formatCurrency(coffee.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: state.coffees.length,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
