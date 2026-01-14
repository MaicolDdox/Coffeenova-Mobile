import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../config/app_colors.dart';

class ShimmerList extends StatelessWidget {
  final int items;
  final double height;
  final EdgeInsetsGeometry padding;

  const ShimmerList({
    super.key,
    this.items = 4,
    this.height = 88,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.color5,
      highlightColor: AppColors.color2.withValues(alpha: 0.6),
      child: Column(
        children: List.generate(
          items,
          (index) => Padding(
            padding: padding,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
