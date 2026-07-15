import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/ticket.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/common_method.dart';

class TicketWidget extends StatelessWidget {
  final Ticket ticket;
  final void Function()? onTap;
  const TicketWidget({required this.ticket, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.greyText,
              width: 0.5.w,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 12.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.message ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textYellow,
                      ),
                    ),
                  const  SizedBox(height: 4,),
                    Text(
                   Methods.formatCreatedAt(   ticket.sendAt??DateTime.now().toString()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 12.w,
              ),
              Text(
                ticket.status ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
