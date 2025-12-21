import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/app_bar/app_bar_widget.dart';
import 'package:official_gold/view/screen/home/profile/send_ticket/components/ticket_widget.dart';
import 'package:official_gold/view/screen/home/profile/send_ticket/send_ticket_screen.dart';
import 'package:official_gold/view_model/cubit/ticket_cubit/ticket_cubit.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import 'package:official_gold/view_model/utils/navigation.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../components/gradient_widget.dart';
import 'make_ticket_sheet.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: TicketCubit.get(context)..getTickets(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.backgroundGrey,
              showDragHandle: true,
              builder: (context) {
                return const MakeTicketSheet();
              },
            );
          },
          backgroundColor: AppColors.textYellow,
          child: const Icon(
            Icons.add,
          ),
        ),
        body: GradientWidget(
          child: Column(
            children: [
              const AppBarCustom(),
              Text(
                LocaleKeys.tickets.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(),
              ),
              SizedBox(
                height: 6.h,
              ),
              const Divider(
                color: AppColors.textYellow,
              ),
              SizedBox(
                height: 8.h,
              ),
              Expanded(
                child: BlocBuilder<TicketCubit, TicketState>(
                  buildWhen: (previous, current) {
                    return current is GetTicketsSuccessState ||
                        current is GetTicketsLoadingState ||
                        current is GetTicketsErrorState ||
                        current is MakeTicketSuccessState;
                  },
                  builder: (context, state) {
                    TicketCubit cubit = TicketCubit.get(context);
                    return ListView.separated(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      padding: EdgeInsets.all(12.sp),
                      itemBuilder: (context, index) {
                        return TicketWidget(
                          ticket: cubit.tickets[index],
                          onTap: () {
                            Navigation.push(
                                context,
                                SendTicketScreen(
                                  ticket: cubit.tickets[index],
                                ));
                          },
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(
                        height: 12.h,
                      ),
                      itemCount: cubit.tickets.length,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
