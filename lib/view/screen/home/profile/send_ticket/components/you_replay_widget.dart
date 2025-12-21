import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../model/response.dart';
import '../../../../../../view_model/utils/colors.dart';

class YouReplayWidget extends StatelessWidget {
  final Response response;
  const YouReplayWidget({required this.response, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.yellowBorder,
          width: 0.5.w,
        ),
        color: AppColors.yellow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              LocaleKeys.you.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.yellowBorder,
                color: AppColors.yellowBorder,
              ),
            ),
          ),
          SizedBox(
            height: 6.h,
          ),
          Text(
            response.response ?? '',
            // LocaleKeys.writingWithTeachSupport.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
