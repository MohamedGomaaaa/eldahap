import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';

import '../../../../view_model/utils/colors.dart';

class PayUsdtScreen extends StatelessWidget {
  const PayUsdtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: WalletCubit.get(context)..clearControllers()..getCurrencies(),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Text(
                LocaleKeys.liveChat.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textYellow,
                    ),
              ),
              SizedBox(
                height: 6.h,
              ),
              const Divider(
                color: AppColors.textYellow,
              ),
              SizedBox(
                height: 12.h,
              ),
              Expanded(
                child: Form(
                  key: WalletCubit.get(context).formKey,
                  child: ListView(
                    children: [
                      BlocBuilder<WalletCubit, WalletState>(
                        builder: (context, state) {
                          WalletCubit cubit = WalletCubit.get(context);
                          return DropdownButtonFormField(
                            value: cubit.currentCurrency.isEmpty ? null : cubit.currentCurrency,
                            items: List.generate(
                              cubit.currencies.length,
                              (index) => DropdownMenuItem(
                                value: cubit.currencies.keys.toList()[index],
                                child: Text(
                                  cubit.currencies.values.toList()[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(),
                                ),
                              ),
                            ),
                            menuMaxHeight: 200.h,
                            dropdownColor: AppColors.background,
                            onChanged: (value) {
                              cubit.changeCurrentCurrency(value ?? '');
                            },
                            validator: (value) {
                              if(value == null || value.isEmpty) {
                                return LocaleKeys.chooseThePaymentCurrency.tr();
                              }
                              return null;
                            },
                            hint: Text(
                              LocaleKeys.chooseThePaymentCurrency.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      TextFormField(
                        controller: WalletCubit.get(context).quantityController,
                        decoration: InputDecoration(
                          hintText: LocaleKeys.quantity.tr(),
                          hintStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(),
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty) {
                            return LocaleKeys.quantityError.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      TextFormField(
                        controller: WalletCubit.get(context).messageController,
                        decoration: InputDecoration(
                          hintText: LocaleKeys.sendingAMessage.tr(),
                          hintStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(),
                        ),
                        // validator: (value) {
                        //   if(value == null || value.isEmpty) {
                        //     return LocaleKeys.messageError.tr();
                        //   }
                        //   return null;
                        // },
                        maxLines: 6,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12.h,
              ),
              BlocBuilder<WalletCubit, WalletState>(
                buildWhen: (previous, current) {
                  return current is PayUsdtLoadingState ||
                      current is PayUsdtSuccessState ||
                      current is PayUsdtErrorState;
                },
                builder: (context, state) {
                  return Visibility(
                    visible: state is PayUsdtLoadingState,
                    child: const LinearProgressIndicator(
                      backgroundColor: AppColors.grey,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 12.h,
              ),
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () {
                    if(WalletCubit.get(context).formKey.currentState!.validate()){
                      WalletCubit.get(context).payUsdt();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.save.tr(),
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
