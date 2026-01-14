import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_view.dart';
import '../providers/admin_orders_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminOrdersProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersProvider);

    if (state.loading && state.orders.isEmpty) {
      return const LoadingView(fullscreen: true, message: 'Cargando ordenes...');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: state.orders.isEmpty
                ? Center(
                    child: EmptyState(
                      title: 'Sin ordenes',
                      message: state.error ?? 'Aun no hay ordenes registradas.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return InkWell(
                        onTap: () {
                          ref.read(adminOrdersProvider.notifier).fetchById(order.id);
                          if (MediaQuery.of(context).size.width < 800) {
                            context.push('/admin/orders/${order.id}');
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: state.current?.id == order.id ? AppColors.color1 : AppColors.color5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Orden #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    order.user?.name ?? 'Cliente',
                                    style: const TextStyle(color: AppColors.color4),
                                  ),
                                  Text(formatDate(order.createdAt), style: const TextStyle(color: AppColors.color4)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatCurrency(order.total),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: state.orders.length,
                  ),
          ),
          if (MediaQuery.of(context).size.width >= 800)
            Expanded(
              flex: 5,
              child: state.current == null
                  ? const Center(
                      child: Text('Selecciona una orden'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Orden #${state.current!.id}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(state.current!.user?.name ?? 'Cliente',
                              style: const TextStyle(color: AppColors.color4)),
                          const SizedBox(height: 10),
                          Text('Total: ${formatCurrency(state.current!.total)}'),
                          Text('Fecha: ${formatDate(state.current!.createdAt)}'),
                          const SizedBox(height: 12),
                          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                final item = state.current!.items[index];
                                return ListTile(
                                  title: Text(item.coffee?.name ?? 'Producto'),
                                  subtitle: Text('Cantidad: ${item.quantity}'),
                                  trailing: Text(formatCurrency(item.subtotal)),
                                );
                              },
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemCount: state.current!.items.length,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
