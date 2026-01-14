import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/config/dio_client.dart';
import '../../data/models/cart_model.dart';
import '../../data/services/cart_service.dart';

class CartState {
  final CartModel cart;
  final bool loading;
  final String? error;
  final CheckoutResult? lastOrder;

  const CartState({
    required this.cart,
    this.loading = false,
    this.error,
    this.lastOrder,
  });

  CartState copyWith({
    CartModel? cart,
    bool? loading,
    String? error,
    CheckoutResult? lastOrder,
  }) =>
      CartState(
        cart: cart ?? this.cart,
        loading: loading ?? this.loading,
        error: error,
        lastOrder: lastOrder ?? this.lastOrder,
      );
}

final cartServiceProvider = Provider<CartService>((ref) => CartService(ref.watch(dioProvider)));

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final service = ref.watch(cartServiceProvider);
  return CartNotifier(service);
});

class CartNotifier extends StateNotifier<CartState> {
  final CartService _service;
  CartNotifier(this._service) : super(CartState(cart: CartModel.empty()));

  Future<void> fetchCart() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cart = await _service.fetchCart();
      state = state.copyWith(cart: cart, loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }

  Future<Failure?> addToCart(int coffeeId, {int quantity = 1}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cart = await _service.addItem(coffeeId: coffeeId, quantity: quantity);
      state = state.copyWith(cart: cart, loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }

  Future<Failure?> updateItem(int itemId, int quantity) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cart = await _service.updateItem(itemId: itemId, quantity: quantity);
      state = state.copyWith(cart: cart, loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }

  Future<Failure?> removeItem(int itemId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cart = await _service.removeItem(itemId);
      state = state.copyWith(cart: cart, loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }

  Future<void> clear() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.clearCart();
      state = state.copyWith(cart: CartModel.empty(), loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }

  Future<Failure?> checkout() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await _service.checkout();
      state = state.copyWith(cart: CartModel.empty(), lastOrder: result, loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }
}
