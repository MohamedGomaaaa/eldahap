import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/response.dart';
import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/utils/colors.dart';

class SupportReplayWidget extends StatelessWidget {
  final Response response;
  const SupportReplayWidget({required this.response, super.key});

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.supportTeam.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textYellow,
            ),
          ),
          SizedBox(
            height: 6.h,
          ),
          Text(
            // LocaleKeys.writingWithTeachSupport.tr(),
            response.response ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
