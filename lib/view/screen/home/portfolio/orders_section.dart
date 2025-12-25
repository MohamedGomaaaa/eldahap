import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/order_widget.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';

import '../../../../view_model/utils/colors.dart';

class OrdersSection extends StatelessWidget {
  const OrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: TradesCubit.get(context)..getOrderss(), // ✅ هنا
      child: RefreshIndicator(
        onRefresh: () async {
          await TradesCubit.get(context).getOrderss(); // ✅ هنا
        },
        backgroundColor: AppColors.yellow2,
        color: AppColors.black,
        child: BlocBuilder<TradesCubit, TradesState>(
          buildWhen: (previous, current) {
            return current is GetOrdersLoadingState ||
                   current is GetOrdersSuccessState ||
                   current is GetOrdersErrorState;
          },
          builder: (context, state) {
            if (state is GetTradesLoadingState) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: 12.sp,
                  horizontal: 0.sp,
                ),
                itemBuilder: (context, index) {
                  return ShimmerWidget(
                    child: Container(
                      padding: EdgeInsets.all(12.sp),
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        color: AppColors.yellow2,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemCount: 6,
              );
            }

            final cubit = TradesCubit.get(context);

            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: 12.sp,
                horizontal: 0.sp,
              ),
              itemCount: cubit.wholeOrders.length, // ✅ groups
              itemBuilder: (context, index) {
                final g = cubit.wholeOrders[index];
                final key = (g.metal ?? ''); // groupKey
                return OrderWidget(
                  wholeOrderName: g.title ?? '',
                  groupKey: key,
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 12.sp),
            );
          },
        ),
      ),
    );
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// old
// class OrdersSection extends StatelessWidget {
//   const OrdersSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: TradesCubit.get(context),
//       child: RefreshIndicator(
//         onRefresh: () async {},
//         backgroundColor: AppColors.yellow2,
//         color: AppColors.black,
//         child: BlocBuilder<TradesCubit, TradesState>(
//           buildWhen: (previous, current) {
//             return current is GetTradesLoadingState ||
//                 current is GetTradesSuccessState ||
//                 current is GetTradesErrorState;
//           },
//           builder: (context, state) {
//             if (state is GetTradesLoadingState) {
//               return ListView.separated(
//                 padding: EdgeInsets.symmetric(
//                   vertical: 12.sp,
//                   horizontal: 0.sp,
//                 ),
//                 itemBuilder: (context, index) {
//                   return ShimmerWidget(
//                     child: Container(
//                       padding: EdgeInsets.all(12.sp),
//                       width: double.infinity,
//                       height: 150.h,
//                       decoration: BoxDecoration(
//                         color: AppColors.yellow2,
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) => SizedBox(
//                   height: 12.h,
//                 ),
//                 itemCount: 6,
//               );
//             }
//             return ListView.separated(
//               padding: EdgeInsets.symmetric(
//                 vertical: 12.sp,
//                 horizontal: 0.sp,
//               ),
//               itemCount: TradesCubit.get(context).trades.length,
//               itemBuilder: (context, index) {
//                 return const OrderWidget(
//                     // product: TradesCubit.get(context).trades[index],
//                     );
//               },
//               separatorBuilder: (context, index) {
//                 return SizedBox(
//                   height: 12.sp,
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
