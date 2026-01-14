import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_colors.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../coffees/presentation/providers/coffee_provider.dart';
import '../orders/presentation/providers/admin_orders_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  final String location;
  const AdminShell({super.key, required this.child, required this.location});

  int _indexFromLocation(String location) {
    if (location.startsWith('/admin/catalog')) return 1;
    if (location.startsWith('/admin/coffees')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin/home');
        break;
      case 1:
        context.go('/admin/catalog');
        break;
      case 2:
        context.go('/admin/coffees');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _indexFromLocation(location);
    final isOrders = location.startsWith('/admin/home') || location.startsWith('/admin/orders');
    final isCoffees = location.startsWith('/admin/coffees');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCoffees
              ? 'Gestión de cafés'
              : location.startsWith('/admin/catalog')
                  ? 'Catálogo (admin)'
                  : 'Panel de órdenes',
        ),
        actions: [
          if (isOrders)
            IconButton(
              tooltip: 'Refrescar',
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(adminOrdersProvider.notifier).fetch(),
            ),
          if (isCoffees)
            IconButton(
              tooltip: 'Refrescar',
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
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.color2.withValues(alpha: 0.7),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Órdenes'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Catálogo'),
          NavigationDestination(icon: Icon(Icons.coffee), label: 'Gestión'),
        ],
      ),
    );
  }
}
