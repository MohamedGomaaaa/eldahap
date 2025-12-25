import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../../../components/gradient_widget.dart';
import '../../../../components/app_bar_widget.dart';
import 'completed_deposit_screen.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(12.sp),
                  children: [
                    const AppBarCustom(),
                    SizedBox(
                      height: 12.h,
                    ),
                    Text(
                      LocaleKeys.deposit.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          // color: AppColors.textYellow,
                          ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    const Divider(
                      color: AppColors.textYellow,
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    DropdownButtonFormField(
                      items: const [],
                      onChanged: (value) {},
                      alignment: Alignment.center,
                      hint: Text(
                        LocaleKeys.addMoney.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    TextFormField(
                      controller: WalletCubit.get(context).quantityController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      decoration: InputDecoration(
                        hintText: LocaleKeys.quantity.tr(),
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Text(
                      LocaleKeys.verifyTheRequiredInformation.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 12.h,
              ),
              Container(
                width: double.infinity,
                height: 40.h,
                margin: EdgeInsets.symmetric(horizontal: 12.sp),
                child: ElevatedButton(
                  onPressed: () {
                    if(WalletCubit.get(context).quantityController.text.isEmpty) {
                      return;
                    }
                    WalletCubit.get(context).deposit().then((value) {
                      Navigation.push(context, const CompletedDepositScreen());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.add.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
