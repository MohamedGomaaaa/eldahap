import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/trade_details_screen.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/trade_widget.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';
import 'package:official_gold/view_model/utils/navigation.dart';

import '../../../../view_model/utils/colors.dart';

class TradesSection extends StatelessWidget {
  const TradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: TradesCubit.get(context)..getTrades(),
      child: RefreshIndicator(
        onRefresh: () async {
          await TradesCubit.get(context).getTrades();
        },
        backgroundColor: AppColors.yellow2,
        color: AppColors.black,
        child: BlocBuilder<TradesCubit, TradesState>(
          buildWhen: (previous, current) {
            return current is GetTradesLoadingState ||
                current is GetTradesSuccessState ||
                current is GetTradesErrorState;
          },
          builder: (context, state) {
            if (state is GetTradesLoadingState) {
/////////////////////////////////////////////////////////////////////////////// shimmer
              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: 12.sp,
                  horizontal: 12.sp,
                ),
                itemBuilder: (context, index) {
                  return ShimmerWidget(
                    child: Container(
                      padding: EdgeInsets.all(12.sp),
                      width: double.infinity,
                      height: 130.h,
                      decoration: BoxDecoration(
                        color: AppColors.yellow2,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                  height: 12.h,
                ),
                itemCount: 6,
              );
            }
/////////////////////////////////////////////////////////////////////////////// list
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: 12.sp,
                horizontal: 0.sp,
              ),
              itemCount: TradesCubit.get(context).trades.length,
              itemBuilder: (context, index) {
                return TradeWidget(
                  tradesCubit:  TradesCubit.get(context),
                  product: TradesCubit.get(context).trades[index],
                  onTap: (){
                    Navigation.push(context,TradeDetailsScreen(TradesCubit.get(context).trades[index]));
                  },
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 12.sp,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
