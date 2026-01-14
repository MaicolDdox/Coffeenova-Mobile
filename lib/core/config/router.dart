import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/coffees/presentation/screens/admin_coffees_screen.dart';
import '../../features/admin/coffees/presentation/screens/admin_create_coffee_screen.dart';
import '../../features/admin/orders/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/catalog/presentation/admin_catalog_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/coffees/presentation/screens/client_shell.dart';
import '../../features/coffees/presentation/screens/coffee_detail_screen.dart';
import '../../features/coffees/presentation/screens/coffee_list_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAdmin = authState.isAdmin;
      final loggingIn = state.matchedLocation.startsWith('/auth');
      final checking = authState.phase == AuthPhase.checking;

      if (checking) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      if (!isAuth && !loggingIn) {
        return '/auth/login';
      }

      if (isAuth && (state.matchedLocation == '/splash' || state.matchedLocation == '/' || loggingIn)) {
        return isAdmin ? '/admin/home' : '/client/home';
      }

      if (!isAdmin && state.matchedLocation.startsWith('/admin')) {
        return '/client/home';
      }

      if (isAdmin && state.matchedLocation.startsWith('/client')) {
        return '/admin/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ClientShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/client/home',
            builder: (context, state) => const CoffeeListScreen(),
          ),
          GoRoute(
            path: '/client/coffees/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return CoffeeDetailScreen(id: id);
            },
          ),
          GoRoute(
            path: '/client/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/client/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/client/orders/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return OrderDetailScreen(id: id);
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/admin/home',
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: '/admin/catalog',
            builder: (context, state) => const AdminCatalogScreen(),
          ),
          GoRoute(
            path: '/admin/coffees',
            builder: (context, state) => const AdminCoffeesScreen(),
          ),
          GoRoute(
            path: '/admin/coffees/new',
            builder: (context, state) => const AdminCreateCoffeeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/orders/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailScreen(id: id, isAdmin: true);
        },
      ),
    ],
  );
});

/// Listener para refrescar GoRouter cuando cambia el estado de auth.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
