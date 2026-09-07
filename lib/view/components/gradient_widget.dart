import 'package:flutter/material.dart';

import '../../utils/app_color.dart';

class GradientWidget extends StatelessWidget {
  final Widget child;
  const GradientWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topCenter,
          end: AlignmentDirectional.bottomCenter,
          stops: [0.7, 1],
          colors: [
            AppColors.background,
            AppColors.darkGreen,
          ],
        ),
      ),
      child: child,
    );
  }
}
