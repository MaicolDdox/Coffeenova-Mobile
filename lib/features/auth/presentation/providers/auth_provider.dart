import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/dio_client.dart';
import '../../../../core/config/token_provider.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/auth_storage.dart';

enum AuthPhase { checking, authenticated, unauthenticated }

class AuthState {
  final UserModel? user;
  final String? token;
  final bool loading;
  final String? error;
  final AuthPhase phase;

  const AuthState({
    this.user,
    this.token,
    this.loading = false,
    this.error,
    this.phase = AuthPhase.checking,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? loading,
    String? error,
    AuthPhase? phase,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      loading: loading ?? this.loading,
      error: error,
      phase: phase ?? this.phase,
    );
  }

  bool get isAuthenticated => phase == AuthPhase.authenticated && token != null && user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isClient => user?.isClient ?? false;
}

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(dioProvider)));

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  final storage = ref.watch(authStorageProvider);
  return AuthNotifier(ref, service, storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  final AuthStorage _storage;
  final Ref _ref;

  AuthNotifier(this._ref, this._service, this._storage) : super(const AuthState()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(loading: true, phase: AuthPhase.checking);
    final session = await _storage.read();
    if (session == null) {
      state = state.copyWith(loading: false, phase: AuthPhase.unauthenticated, user: null, token: null);
      _ref.read(authTokenProvider.notifier).state = null;
      return;
    }

    _ref.read(authTokenProvider.notifier).state = session.token;
    try {
      final me = await _service.me();
      state = state.copyWith(
        user: me,
        token: session.token,
        loading: false,
        phase: AuthPhase.authenticated,
      );
      await _storage.persist(session.token, me);
    } catch (_) {
      await logout(clearRemote: false);
    }
  }

  Future<Failure?> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final (token, user) = await _service.login(email: email, password: password);
      _ref.read(authTokenProvider.notifier).state = token;
      await _storage.persist(token, user);
      state = state.copyWith(
        user: user,
        token: token,
        loading: false,
        phase: AuthPhase.authenticated,
        error: null,
      );
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(loading: false, error: failure.message, phase: AuthPhase.unauthenticated);
      return failure;
    }
  }

  Future<Failure?> register(String name, String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final (token, user) = await _service.register(name: name, email: email, password: password);
      _ref.read(authTokenProvider.notifier).state = token;
      await _storage.persist(token, user);
      state = state.copyWith(
        user: user,
        token: token,
        loading: false,
        phase: AuthPhase.authenticated,
        error: null,
      );
      return null;
    } catch (e) {
      final failure = e is Failure ? e : Failure(message: e.toString());
      state = state.copyWith(loading: false, error: failure.message, phase: AuthPhase.unauthenticated);
      return failure;
    }
  }

  Future<void> refreshProfile() async {
    if (state.token == null) return;
    try {
      final me = await _service.me();
      state = state.copyWith(user: me, phase: AuthPhase.authenticated);
      await _storage.persist(state.token!, me);
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout({bool clearRemote = true}) async {
    final token = state.token;
    state = state.copyWith(loading: true);
    try {
      if (clearRemote && token != null) {
        await _service.logout();
      }
    } catch (_) {
      // ignoramos errores del backend al cerrar sesión
    } finally {
      _ref.read(authTokenProvider.notifier).state = null;
      await _storage.clear();
      state = state.copyWith(
        user: null,
        token: null,
        loading: false,
        phase: AuthPhase.unauthenticated,
        error: null,
      );
    }
  }
}
