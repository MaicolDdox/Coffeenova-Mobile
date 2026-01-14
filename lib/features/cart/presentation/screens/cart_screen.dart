import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_view.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Future<void> _showCheckoutDialog(BuildContext context) async {
    // Dialog de confirmación con cierre automático y botón de cierre.
    final nav = Navigator.of(context);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'checkout',
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
        return FadeTransition(
          opacity: fade,
          child: Stack(
            children: [
              Container(color: Colors.black.withValues(alpha: 0.25)),
              Center(
                child: ScaleTransition(
                  scale: scale,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.color1.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const Icon(Icons.verified, size: 56, color: AppColors.color1),
                        const SizedBox(height: 12),
                        const Text('Pago simulado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Tu pedido está en camino ☕', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Cierre automático tras 2.2s si sigue abierto.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (nav.canPop()) {
        nav.pop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).fetchCart());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartProvider);

    if (state.loading && state.cart.items.isEmpty) {
      return const LoadingView(fullscreen: true, message: 'Cargando carrito...');
    }

    if (state.cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carrito'),
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
            title: 'Tu carrito está vacío',
            message: state.error ?? 'Agrega cafés para continuar',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = state.cart.items[index];
                final img = item.coffee.imageFullUrl ?? item.coffee.imageUrl;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.color5),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: img != null
                            ? Image.network(img, width: 64, height: 64, fit: BoxFit.cover)
                            : Container(
                                width: 64,
                                height: 64,
                                color: AppColors.color5,
                                child: const Icon(Icons.coffee_outlined),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.coffee.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(item.coffee.brand, style: const TextStyle(color: AppColors.color4)),
                            const SizedBox(height: 6),
                            Text(formatCurrency(item.totalPrice)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: item.quantity > 1
                                    ? () => ref.read(cartProvider.notifier).updateItem(item.id, item.quantity - 1)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => ref.read(cartProvider.notifier).updateItem(item.id, item.quantity + 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: state.cart.items.length,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.color5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(formatCurrency(state.cart.totalCart), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                  AppButton(
                    label: 'Realizar pedido',
                    loading: state.loading,
                    onPressed: state.loading
                        ? null
                        : () async {
                          final failure = await ref.read(cartProvider.notifier).checkout();
                          if (!context.mounted) return;
                          final messenger = ScaffoldMessenger.of(context);
                          final text = failure == null ? 'Orden creada con éxito' : failure.message;
                          messenger.showSnackBar(SnackBar(content: Text(text)));
                          if (failure == null && context.mounted) {
                            await _showCheckoutDialog(context);
                          }
                        },
                  ),
                TextButton(
                  onPressed: () => ref.read(cartProvider.notifier).clear(),
                  child: const Text('Vaciar carrito'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
