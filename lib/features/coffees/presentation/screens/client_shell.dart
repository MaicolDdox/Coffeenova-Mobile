import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';

class ClientShell extends StatelessWidget {
  final Widget child;
  final String location;
  const ClientShell({super.key, required this.child, required this.location});

  int _indexFromLocation(String location) {
    if (location.startsWith('/client/cart')) return 1;
    if (location.startsWith('/client/orders')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/client/home');
        break;
      case 1:
        context.go('/client/cart');
        break;
      case 2:
        context.go('/client/orders');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.color2.withValues(alpha: 0.7),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.coffee), label: 'Catálogo'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Carrito'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Órdenes'),
        ],
      ),
    );
  }
}
