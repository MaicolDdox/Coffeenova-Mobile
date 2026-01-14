import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/config/dio_client.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class OrdersState {
  final List<OrderModel> orders;
  final OrderModel? current;
  final bool loading;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.current,
    this.loading = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    OrderModel? current,
    bool? loading,
    String? error,
  }) =>
      OrdersState(
        orders: orders ?? this.orders,
        current: current ?? this.current,
        loading: loading ?? this.loading,
        error: error,
      );
}

final orderServiceProvider = Provider<OrderService>((ref) => OrderService(ref.watch(dioProvider)));

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final service = ref.watch(orderServiceProvider);
  return OrdersNotifier(service);
});

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderService _service;
  OrdersNotifier(this._service) : super(const OrdersState());

  Future<void> fetchMyOrders() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _service.fetchMyOrders();
      state = state.copyWith(orders: list, loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }

  Future<void> fetchMyOrder(int id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final order = await _service.fetchMyOrder(id);
      state = state.copyWith(current: order, loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }
}
