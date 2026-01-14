import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_theme.dart';
import 'core/config/router.dart';

void main() {
  runApp(const ProviderScope(child: StoreCoffeeApp()));
}

class StoreCoffeeApp extends ConsumerWidget {
  const StoreCoffeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Store Coffee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
