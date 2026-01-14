import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/coffee_model.dart';
import '../../data/services/coffee_service.dart';
import '../../../../core/config/dio_client.dart';

class CoffeesState {
  final List<CoffeeModel> coffees;
  final bool loading;
  final String? error;

  const CoffeesState({
    this.coffees = const [],
    this.loading = false,
    this.error,
  });

  CoffeesState copyWith({
    List<CoffeeModel>? coffees,
    bool? loading,
    String? error,
  }) =>
      CoffeesState(
        coffees: coffees ?? this.coffees,
        loading: loading ?? this.loading,
        error: error,
      );
}

final coffeeServiceProvider = Provider<CoffeeService>((ref) => CoffeeService(ref.watch(dioProvider)));

final coffeesProvider = StateNotifierProvider<CoffeesNotifier, CoffeesState>((ref) {
  final service = ref.watch(coffeeServiceProvider);
  return CoffeesNotifier(service);
});

class CoffeesNotifier extends StateNotifier<CoffeesState> {
  final CoffeeService _service;
  CoffeesNotifier(this._service) : super(const CoffeesState());

  Future<void> fetch({String? brand, String? priceOrder}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _service.fetchCoffees(brand: brand, priceOrder: priceOrder);
      state = state.copyWith(coffees: list, loading: false);
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
    }
  }

  Future<CoffeeModel?> fetchById(int id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final coffee = await _service.fetchCoffee(id);
      final newList = [...state.coffees];
      final idx = newList.indexWhere((c) => c.id == coffee.id);
      if (idx >= 0) {
        newList[idx] = coffee;
      } else {
        newList.add(coffee);
      }
      state = state.copyWith(coffees: newList, loading: false);
      return coffee;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return null;
    }
  }

  Future<Failure?> create(dynamic payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      if (payload is Map<String, dynamic>) {
        payload = Map<String, dynamic>.from(payload)
          ..update('is_active', (value) => value is bool ? (value ? 1 : 0) : value ?? 0, ifAbsent: () => 1);
      }
      final created = await _service.createCoffee(payload);
      state = state.copyWith(coffees: [created, ...state.coffees], loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }

  Future<Failure?> update(int id, dynamic payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final updated = await _service.updateCoffee(id, payload);
      final newList = state.coffees.map((c) => c.id == id ? updated : c).toList();
      state = state.copyWith(coffees: newList, loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }

  Future<Failure?> delete(int id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.deleteCoffee(id);
      final newList = state.coffees
          .map((c) => c.id == id ? CoffeeModel.fromJson({...c.toJson(), 'is_active': false}) : c)
          .toList();
      state = state.copyWith(coffees: newList, loading: false);
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(error: failure.message, loading: false);
      return failure;
    }
  }
}
