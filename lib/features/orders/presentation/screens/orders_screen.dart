import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).fetchMyOrders());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);

    if (state.loading && state.orders.isEmpty) {
      return const LoadingView(fullscreen: true, message: 'Cargando órdenes...');
    }

    if (state.orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis órdenes'),
          actions: [
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
        body: Center(
          child: EmptyState(
            title: 'Sin órdenes',
            message: state.error ?? 'Aún no has comprado. ¡Agrega cafés al carrito!',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis órdenes'),
        actions: [
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(ordersProvider.notifier).fetchMyOrders(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final order = state.orders[index];
            return InkWell(
              onTap: () => context.push('/client/orders/${order.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.color5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Orden #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(formatDate(order.createdAt), style: const TextStyle(color: AppColors.color4)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatCurrency(order.total),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(order.status),
                          backgroundColor: AppColors.color2,
                          side: const BorderSide(color: AppColors.color1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: state.orders.length,
        ),
      ),
    );
  }
}
