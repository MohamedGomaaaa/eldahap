import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/ticket.dart';
import '../../../../../view_model/cubit/ticket_cubit/ticket_cubit.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../components/app_bar_widget.dart';
import 'components/support_replay_widget.dart';
import 'components/you_replay_widget.dart';

class SendTicketScreen extends StatelessWidget {
  final Ticket ticket;

  const SendTicketScreen({required this.ticket, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: TicketCubit.get(context)..getTicketResponse(ticket.id ?? 0)..ticketResponses.clear(),
      child: Scaffold(
        body: GradientWidget(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Column(
                children: [
                  const AppBarCustom(),
                  SizedBox(
                    height: 12.h,
                  ),
                  Text(
                    LocaleKeys.sendTicket.tr(),
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
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.yellowBorder,
                            width: 0.5.w,
                          ),
                          color: AppColors.backgroundGrey,
                        ),
                        child: BlocBuilder<TicketCubit, TicketState>(
                          builder: (context, state) {
                            TicketCubit cubit = TicketCubit.get(context);
                            return RefreshIndicator(
                              onRefresh: () async {
                                cubit.getTicketResponse(ticket.id ?? 0);
                              },
                              backgroundColor: AppColors.yellow2,
                              color: AppColors.black,
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return cubit.ticketResponses[index].user ==
                                          'admin'
                                      ? SupportReplayWidget(
                                          response: cubit.ticketResponses[index],
                                        )
                                      : YouReplayWidget(
                                          response: cubit.ticketResponses[index],
                                        );
                                },
                                separatorBuilder: (context, index) => SizedBox(
                                  height: 12.h,
                                ),
                                itemCount: cubit.ticketResponses.length,
                              ),
                            );
                          },
                        )
                        // ListView(
                        //   children: [
                        //     const SupportReplayWidget(),
                        //     SizedBox(
                        //       height: 12.h,
                        //     ),
                        //     const YouReplayWidget(),
                        //   ],
                        // ),
                        ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  TextFormField(
                    controller: TicketCubit.get(context).responseController,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.writeHereWhatYouWant.tr(),
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  BlocBuilder<TicketCubit, TicketState>(
                    buildWhen: (previous, current) {
                      return current is MakeResponseLoadingState ||
                          current is MakeResponseSuccessState ||
                          current is MakeResponseErrorState;
                    },
                    builder: (context, state) {
                      return Visibility(
                        visible: state is MakeResponseLoadingState,
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
                        TicketCubit.get(context).makeResponse(ticket.id ?? 0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.send.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
