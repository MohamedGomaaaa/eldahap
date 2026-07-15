import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import '../../../../../view_model/cubit/ticket_cubit/ticket_cubit.dart';
import '../../../../../view_model/utils/colors.dart';

class MakeTicketSheet extends StatelessWidget {
  const MakeTicketSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Form(
          key: TicketCubit.get(context).formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 12.sp),
            children: [
              Text(
                LocaleKeys.makeTicket.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
              ),
              SizedBox(
                height: 20.h,
              ),
              TextFormField(
                controller: TicketCubit.get(context).ticketController,
                decoration: InputDecoration(
                  hintText: LocaleKeys.yourMessage.tr(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return LocaleKeys.messageError.tr();
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 12.h,
              ),
              BlocBuilder<TicketCubit, TicketState>(
                buildWhen: (previous, current) {
                  return current is MakeTicketLoadingState ||
                      current is MakeTicketSuccessState ||
                      current is MakeTicketErrorState;
                },
                builder: (context, state) {
                  return Visibility(
                    visible: state is MakeTicketLoadingState,
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
                    TicketCubit.get(context).makeTicket().then((value) => Navigator.pop(context));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.send.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                ),
              ),


              SizedBox(
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
