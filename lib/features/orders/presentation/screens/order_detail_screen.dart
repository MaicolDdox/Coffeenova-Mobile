import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../admin/orders/presentation/providers/admin_orders_provider.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int id;
  final bool isAdmin;
  const OrderDetailScreen({super.key, required this.id, this.isAdmin = false});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isAdmin) {
        ref.read(adminOrdersProvider.notifier).fetchById(widget.id);
      } else {
        ref.read(ordersProvider.notifier).fetchMyOrder(widget.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminOrdersProvider);
    final userState = ref.watch(ordersProvider);
    final order = widget.isAdmin ? adminState.current : userState.current;
    final loading = widget.isAdmin ? adminState.loading : userState.loading;

    if (loading || order == null) {
      return const LoadingView(fullscreen: true, message: 'Cargando orden...');
    }

    return Scaffold(
      appBar: AppBar(title: Text('Orden #${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.labelLarge),
                    Text(
                      formatCurrency(order.total),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Pago: ${order.paymentMethod}', style: const TextStyle(color: AppColors.color4)),
                  ],
                ),
                Chip(
                  label: Text(order.status),
                  backgroundColor: AppColors.color2,
                  side: const BorderSide(color: AppColors.color1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Fecha: ${formatDate(order.createdAt ?? order.paidAt)}'),
            if (widget.isAdmin && order.user != null) ...[
              const SizedBox(height: 8),
              Text('Cliente: ${order.user!.name} (${order.user!.email})'),
            ],
            const SizedBox(height: 16),
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.color5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.coffee?.name ?? 'Producto', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Cantidad: ${item.quantity}', style: const TextStyle(color: AppColors.color4)),
                          ],
                        ),
                        Text(formatCurrency(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: order.items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
