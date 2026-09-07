import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_color.dart';

class SvgWidget extends StatelessWidget {
  final String assetName;
  final Color? color;
  final double? width;
  final double? height;

  const SvgWidget({
    required this.assetName,
    this.color,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      height: height,
      width: width,
      colorFilter: ColorFilter.mode(
        color ?? AppColors.yellow,
        BlendMode.srcIn,
      ),
    );
  }
}
