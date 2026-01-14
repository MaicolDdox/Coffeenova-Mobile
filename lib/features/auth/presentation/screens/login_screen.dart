import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    final failure = await notifier.login(_emailController.text.trim(), _passwordController.text);
    final state = ref.read(authNotifierProvider);
    if (failure != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }
      return;
    }
    if (!mounted) return;
    final target = state.isAdmin ? '/admin/home' : '/client/home';
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Bienvenido', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Inicia sesión para continuar', style: TextStyle(color: AppColors.color4)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _emailController,
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu correo';
                        if (!v.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Entrar',
                      loading: auth.loading,
                      onPressed: auth.loading ? null : _submit,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/auth/register'),
                      child: const Text('Crear cuenta'),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 8),
                      Text(auth.error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
