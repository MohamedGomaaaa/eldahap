


import '../../../../../../view_model/models/wallet_models/transaction_model.dart';
import '../../../../../../view_model/utils/colors.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
class TransactionDetailsBottomSheet extends StatelessWidget {
  final TransactionData transaction;
  final   String dateTime,title,amount;

  const TransactionDetailsBottomSheet({
    super.key,
    required this.transaction, required this.amount, required this.dateTime, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ///////////////////////////////////////// Title

          Center(
            child: Text(
              "Transaction Details",
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          ///////////////////////////////////////// Details

          _detailItem(
            title: "Transaction ID",
            value: transaction.id.toString(),
          ),


          _detailItem(
            title: "Transaction type",
            value: title,
          ),








          _detailItem(
            title: "Type",
            value: transaction.type ?? "",
          ),









          _detailItem(
            title: "Status",
            value: transaction.isApproval ?? "",
          ),

          _detailItem(
            title: "Amount",
            value: amount,
          ),

          _detailItem(
            title: "Mode",
            value: transaction.amountType ?? "",
          ),

          _detailItem(
            title: "Date",
            value: dateTime,
          ),
    Text(      transaction.note,       style: TextStyle(
              color: AppColors.yellow,
      fontSize: 14.sp,
    ),),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
  Widget _detailItem({
    required String title,
    required String value,
  })
  {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}