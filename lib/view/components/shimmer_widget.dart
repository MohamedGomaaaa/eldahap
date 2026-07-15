import 'package:flutter/material.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final Color? baseColor;
  final Color? highlightColor;
  final Widget child;
  const ShimmerWidget({required this.child, this.baseColor = AppColors.grey, this.highlightColor = AppColors.yellow2, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor!,
      highlightColor: highlightColor!,
      child: child,
    );
  }
}
