import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../view_model/utils/colors.dart';
import 'svg_widget.dart';

class ProfileTileWidget extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String? assetName;
  final Widget? action;
  final EdgeInsets? padding;
  final Widget? iconWidget;
  final Color ?titleColor;
  const ProfileTileWidget({
    required this.title,
    this.assetName,
    this.onTap,
    this.action,
    this.padding,
    this.iconWidget,
    super.key, this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsetsDirectional.only(bottom: 8.h),
      child: Material(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.yellow,
                width: 0.5.w,
              ),
            ),
            child: Row(
              children: [
                if(assetName == null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: iconWidget ?? const SizedBox.shrink(),
                  ),
                if(assetName != null)
                SvgWidget(
                  assetName: assetName!,
                  color: AppColors.textYellow,
                  height: 25.w,
                ),
                if(assetName != null)
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: titleColor??AppColors.yellow,
                        ),
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                if(action != null) action!,
                if(action == null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textYellow,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
