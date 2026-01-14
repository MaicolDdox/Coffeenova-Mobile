import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../orders/data/models/order_model.dart';
import '../../../../orders/data/services/order_service.dart';
import '../../../../orders/presentation/providers/order_provider.dart';
import '../../../../../core/errors/failure.dart';

class AdminOrdersState {
  final List<OrderModel> orders;
  final OrderModel? current;
  final bool loading;
  final String? error;

  const AdminOrdersState({
    this.orders = const [],
    this.current,
    this.loading = false,
    this.error,
  });

  AdminOrdersState copyWith({
    List<OrderModel>? orders,
    OrderModel? current,
    bool? loading,
    String? error,
  }) =>
      AdminOrdersState(
        orders: orders ?? this.orders,
        current: current ?? this.current,
        loading: loading ?? this.loading,
        error: error,
      );
}

final adminOrdersProvider = StateNotifierProvider<AdminOrdersNotifier, AdminOrdersState>((ref) {
  final service = ref.watch(orderServiceProvider);
  return AdminOrdersNotifier(service);
});

class AdminOrdersNotifier extends StateNotifier<AdminOrdersState> {
  final OrderService _service;
  AdminOrdersNotifier(this._service) : super(const AdminOrdersState());

  Future<void> fetch({String? status, int? userId}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _service.fetchAdminOrders(status: status, userId: userId);
      state = state.copyWith(orders: list, loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }

  Future<void> fetchById(int id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final order = await _service.fetchAdminOrder(id);
      state = state.copyWith(current: order, loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }
}
