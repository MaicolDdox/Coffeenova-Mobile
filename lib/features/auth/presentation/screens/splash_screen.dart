import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 300), () {
      ref.read(authNotifierProvider.notifier).restoreSession();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.color2.withValues(alpha: 0.5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.color1.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.coffee, size: 56, color: AppColors.color3),
                ),
                const SizedBox(height: 18),
                Text(
                  'Store Coffee',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.color3,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cargando tu experiencia cafetera...',
                  style: TextStyle(color: AppColors.color4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
