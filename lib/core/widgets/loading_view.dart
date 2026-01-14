import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final bool fullscreen;

  const LoadingView({super.key, this.message, this.fullscreen = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, textAlign: TextAlign.center),
        ],
      ],
    );

    if (fullscreen) {
      return Scaffold(body: Center(child: content));
    }
    return Center(child: content);
  }
}
