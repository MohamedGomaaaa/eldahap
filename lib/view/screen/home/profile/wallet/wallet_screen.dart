// new wallet page

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/screen/home/profile/wallet/recharge/recharge_amount_screen.dart';
import 'package:official_gold/view/screen/home/profile/wallet/widgets/transaction_details_bottom_sheet.dart';
import 'package:official_gold/view/screen/home/profile/wallet/withdraw/withdraw_alAmount_page.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
import 'package:official_gold/view_model/utils/text_style.dart';
import '../../../../../model/user.dart';
import '../../../../../view_model/cubit/home_cubit/home_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../../model/transaction_model.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../../view_model/utils/validator.dart';
import '../../../../components/live_status_text.dart';
import '../../../../components/live_text.dart';




















class WalletScreen extends StatefulWidget {
  final bool comingFromNavBar;

  const WalletScreen({
    super.key,
    required this.comingFromNavBar,

  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _modalScrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 1. تعريف المتغير لحفظ الـ Cubit
  late WalletCubit _walletCubit;

  @override
  void initState() {
    super.initState();
    _walletCubit = WalletCubit.get(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _walletCubit.initializeWalletData();
      await _walletCubit.getTradess2();

      final liveCubit = context.read<LivePriceCubit>();

      _walletCubit.calculateTotals(
        liveUsdPrice: liveCubit.metals['USD']?.buy ?? 0,
        liveEgpPrice: liveCubit.metals['EGP']?.buy ?? 0,
      );
    });

    _modalScrollController.addListener(_onModalScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _modalScrollController.removeListener(_onModalScroll);
    _modalScrollController.dispose();
    super.dispose();
  }

  void _onModalScroll() {
    if (_modalScrollController.position.pixels >=
        _modalScrollController.position.maxScrollExtent - 200) {
      WalletCubit.get(context)
          .loadMoreTransactions(); // تحميل المزيد عند الاقتراب من القاع
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:
      BlocBuilder<LivePriceCubit, LivePriceState>(
        builder: (context, state) {
          final bool hasLive = state is LivePriceLive;
          final double liveUsd = hasLive ? (state.metals['USD']?.buy ?? 0).toDouble() : 0.0;
          final double liveEgp = hasLive ? (state.metals['EGP']?.buy ?? 0).toDouble() : 0.0;
          final cubit = WalletCubit.get(context);
          cubit.calculateTotals(
            liveUsdPrice: liveUsd,
            liveEgpPrice: liveEgp,
          );
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),

            child:
 ////////////////////////////////////////////////////////////////////////////////////////// has live
              // يعرض الـ LiveStatusText فقط إذا كان هناك اتصال حي
              Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: const LiveStatusText(),
                    ),
                  ),
                  Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: !hasLive,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await WalletCubit.get(context).initializeWalletData();
                            await WalletCubit.get(context).getTradess2();
                          },
                          backgroundColor: AppColors.yellow2,
                          color: AppColors.white,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            // controller: _scrollController,
                            // physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

 //////////////////////////////////////////////////////////////////////////////////// Total Portfolio
                                // _buildPortfolioSection(),
                                // SizedBox(height: 20.h),
///////////////////////////////////////////////////////////////////////////////////// Balance Cards
                                _buildBalanceCards(hasLive),
//////////////////////////////////////////////////////////////////////////////////// Action Buttons
                                _buildActionButtons(),
                                SizedBox(height: 25.h),
////////////////////////////////////////////////////////////////// // Recent Transactions Header
                                _buildTransactionsHeader(),
                                SizedBox(height: 15.h),
 ///////////////////////////////////////////////////////////////////////////////////// Transaction List
                                _buildTransactionsList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!hasLive)
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true, // مجرد لون فقط
                            child: Container(
                              color:
                              Colors.grey.withOpacity(0.3), // غير النسبة براحتك
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

          );
        },
      ),
    );
  }


  // Balance Card Widget
  Widget _balanceCard(
      {required IconData icon,
      required String title,
      required Widget livePnlWalletBalance,
      required Widget testWidget}) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        border: Border.all(color: AppColors.yellowBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.yellow, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: const TextStyle(color: AppColors.greyText, fontSize: 14),
          ),
          SizedBox(height: 6.h),
           livePnlWalletBalance,
          SizedBox(height: 6.h),
          testWidget,
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  // Balance Cards Section
  Widget _buildBalanceCards(bool hasLive) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final cubit = WalletCubit.get(context);
        final isLoading =
            cubit.isWalletLoading || state is ConvertCurrencyLoadingState;

        // ✅ استخدام القيمة الإجمالية التراكمية إذا كانت أكبر من صفر، وإلا استخدام قيمة المحفظة العادية

        final displayUsd = cubit.cachedUsdTotal + cubit.walletDollar;
        final displayEgp = cubit.cachedEgpTotal + cubit.walletEgp;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _balanceCard(

                    icon: Icons.account_balance_wallet_outlined,
                    title: LocaleKeys.dollarBalance.tr(),
                    livePnlWalletBalance: !hasLive?const SizedBox():
                    // cubit.usdTradesPrices.isEmpty
                    //     ? Text(
                    //         Methods.removeTrailingZeros(displayUsd),
                    //         style: WhiteTitle.display5(context),
                    //       )
                    //     :
                    LivePriceText(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 10),
                            fontSize: 14,
                            price: !hasLive
                                ? 0
                                : double.parse(displayUsd
                                    .toString()), // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالدولار
                            decimals: 2,
                            fakeMinDelta: 0.01,
                            fakeMaxDelta: 0.05,
                            fakeTickEvery: const Duration(milliseconds: 900),
                          ),
                    testWidget:!hasLive?const SizedBox(): testWidget(
                        totalPnl: cubit.cachedUsdTotal,
                        walletBalance: cubit.walletDollar),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _balanceCard(
                    testWidget: !hasLive?const SizedBox():testWidget(
                        totalPnl: cubit.cachedEgpTotal,
                        walletBalance: cubit.walletEgp),
                    icon: Icons.account_balance,
                    title: LocaleKeys.egyBalance.tr(),
                    livePnlWalletBalance: !hasLive?const SizedBox():
                    // cubit.egpTradesPrices.isEmpty
                    //     ? Text(
                    //         Methods.removeTrailingZeros(displayEgp),
                    //         style: WhiteTitle.display5(context),
                    //       )
                    //     :
                    LivePriceText(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 10),
                            fontSize: 14,
                            price: !hasLive
                                ? 0
                                : double.parse(displayEgp.toString()),
                            // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالجنيه
                            decimals: 2,
                            fakeMinDelta: 0.01,
                            fakeMaxDelta: 0.05,
                            fakeTickEvery: const Duration(milliseconds: 900),
                          ),
                  ),
                ),
              ],
            ),
//////////////////////////////////////////////////////////////////////////////////////// convert button
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: isLoading
                  ? const CircularProgressIndicator(color: AppColors.yellow)
                  : ElevatedButton.icon(
                      onPressed: () async {
                        final amount = await showModalBottomSheet<num>(
                          backgroundColor: AppColors.background,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => convertAmountSheet(
                            context,
                            cubit.walletDollar,
                          ),
                        );

                        if (amount != null) {
                          cubit.convertCurrency(amount: amount);
                        }
                      },
                      icon: const Icon(Icons.currency_exchange,
                          color: AppColors.white),
                      label: const Text(
                        "Convert to pounds",
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget testWidget({required num totalPnl, required num walletBalance}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 3,
        ),
        Text(
          "total pnl : ${Methods.removeTrailingZeros(totalPnl)}",
          style: MainTitle.display5(context).copyWith(
              color: totalPnl > 0 ? AppColors.blueColor : AppColors.redColor),
        ),
        // const    SizedBox(height: 3,),
        //    Text("wallet : ${Methods.removeTrailingZeros(walletBalance)}",style: MainTitle.display5(context),),
      ],
    );
  }

  // convert Amount Sheet
  Widget convertAmountSheet(BuildContext context, num walletDollar) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              validator: (value) {
                return Validator.validateAmount(
                    value: value, walletDollar: walletDollar);
              },
              decoration: InputDecoration(
                hintText: "enter amount",
                suffixText: "USD",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final amount = num.parse(controller.text.trim());
                    Navigator.pop(context, amount);
                  }
                },
                child: const Text(
                  "convert",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Action Buttons Section
  Widget _buildActionButtons() {
    return ValueListenableBuilder<User>(
      valueListenable: HomeCubit.get(context).user,
      builder: (context, user, _) {
        return user.mode?.toLowerCase() == "demo"
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manage Your Money\n${user.mode} mode",
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _actionButton(
                        Icons.add_circle_outline,
                        LocaleKeys.deposit.tr(),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RechargeAmountScreen()),
                          );
                          final cubit = WalletCubit.get(context);
                          cubit.getTransactions(refresh: true);
                        },
                      ),
                      SizedBox(width: 12.w),
                      _actionButton(
                        Icons.download_rounded,
                        LocaleKeys.withdraw.tr(),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WithdrawalAmountPage()),
                          );
                          final cubit = WalletCubit.get(context);
                          cubit.getTransactions(refresh: true);
                        },
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }

  Widget _actionButton(IconData icon, String label,
      {required VoidCallback onTap})
  {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            border: Border.all(color: AppColors.yellowBorder),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.yellow, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Transactions Header Section
  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Transactions",
          style:
              TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w500),
        ),
        BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final hasTransactions =
                WalletCubit.get(context).allTransactions.isNotEmpty;
            if (!hasTransactions) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () => _showAllTransactionsModal(),
              child: const Text(
                "See All",
                style: TextStyle(color: AppColors.yellow, fontSize: 14),
              ),
            );
          },
        ),
      ],
    );
  }

  // Transactions List Section
  Widget _buildTransactionsList() {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (previous, current) {
        return current is GetTransactionLoadingState ||
            current is GetTransactionSuccessState ||
            current is GetTransactionErrorState ||
            current is LoadMoreTransactionsSuccessState;
      },
      builder: (context, state) {
        final cubit = WalletCubit.get(context);

        if (state is GetTransactionLoadingState &&
            cubit.allTransactions.isEmpty) {
          return SizedBox(
            height: 200.h,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
            ),
          );
        }

        if (state is GetTransactionErrorState &&
            cubit.allTransactions.isEmpty) {
          return SizedBox(
            height: 200.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16.h),
                  const Text(
                    "Error loading transactions",
                    style: TextStyle(color: AppColors.greyText),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () => cubit.getTransactions(refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.black,
                    ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        if (cubit.allTransactions.isEmpty) {
          return SizedBox(
            height: 200.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.greyText,
                    size: 48,
                  ),
                  SizedBox(height: 16.h),
                  const Text(
                    "No transactions yet",
                    style: TextStyle(color: AppColors.greyText, fontSize: 16),
                  ),
                  SizedBox(height: 8.h),
                  const Text(
                    "Your transaction history will appear here",
                    style: TextStyle(color: AppColors.greyText, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final displayTransactions = cubit.allTransactions.take(5).toList();

        return Column(
          children: displayTransactions
              .map((transaction) => _buildTransactionItem(transaction))
              .toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem(TransactionData transaction) {
    final isCredit = transaction.credit > 0;
    final amount = isCredit ? transaction.credit : transaction.debit;
    final formattedDate = _formatDate(transaction.createdAt);

    IconData icon;
    String title;
    Color iconBgColor;

    if (transaction.type.toLowerCase().contains('deposit') ||
        transaction.amountType.toLowerCase().contains('deposit') ||
        isCredit) {
      icon = Icons.upload_rounded;
      title = LocaleKeys.deposit.tr();
      iconBgColor = AppColors.green.withOpacity(0.15);
    } else if (transaction.type.toLowerCase().contains('withdraw') ||
        transaction.amountType.toLowerCase().contains('withdraw') ||
        !isCredit) {
      icon = Icons.download_rounded;
      title = LocaleKeys.withdraw.tr();
      iconBgColor = AppColors.red.withOpacity(0.15);
    } else {
      icon = Icons.swap_horiz;
      title = transaction.type.isNotEmpty ? transaction.type : "Transaction";
      iconBgColor = AppColors.yellow.withOpacity(0.15);
    }

    Color statusColor;
    String status;
    if (transaction.isApproval == '1' ||
        transaction.isApproval.toLowerCase() == 'approved' ||
        transaction.isApproval.toLowerCase() == 'yes') {
      statusColor = AppColors.green;
      status = "Approved";
    } else if (transaction.isApproval == '0' ||
        transaction.isApproval.toLowerCase() == 'not approved' ||
        transaction.isApproval.toLowerCase() == 'no') {
      statusColor = AppColors.yellow;
      status = "Pending";
    } else {
      statusColor = AppColors.red;
      status = "Rejected";
    }

    return _transactionItem(
      transaction: transaction,
      type: transaction.type,
      title: title,
      mode: transaction.amountType.isNotEmpty
          ? transaction.amountType
          : (transaction.note.isNotEmpty
              ? transaction.note
              : "System Transaction"),
      amount:
          "${isCredit ? '+' : '-'} ${Methods.removeTrailingZeros(amount)} ${transaction.currency.toString()}",
      amountColor: isCredit ? AppColors.green : AppColors.red,
      status: status,
      statusColor: statusColor,
      icon: icon,
      iconBgColor: iconBgColor,
      dateTime: formattedDate,
      isPositive: isCredit,
    );
  }

  // Transaction Item Widget
  Widget _transactionItem({
    required TransactionData transaction,
    required String title,
    required String type,
    required String mode,
    required String amount,
    required Color amountColor,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color iconBgColor,
    required String dateTime,
    required bool isPositive,
  })
  {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => TransactionDetailsBottomSheet(
            transaction: transaction,
            dateTime: dateTime,
            title: title,
            amount: amount,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: amountColor, size: 26.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: title + amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Flexible(
                        child: Text(
                          amount,
                          style: TextStyle(
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(height: 3.h),
                  /////////////////////////////////////////  Second row: status + mode + date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
///////////////////////////////////////// _transaction Type
                            Flexible(
                              child: Container(
                                child: Text(
                                  "( $type )",
                                  style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
///////////////////////////////////////// status is Approved
                            Container(
                              child: Text(
                                status,
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),

///////////////////////////////////////// mode

                            // SizedBox(width: 8.w),
                            // Container(
                            //   color: Colors.green,
                            //   child: Text(
                            //     mode,
                            //     style: const TextStyle(
                            //         color: AppColors.yellow, fontSize: 12),
                            //     overflow: TextOverflow.ellipsis,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
 ///////////////////////////////////////// date
                      Text(
                        dateTime,
                        style: TextStyle(
                          color: amountColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Unknown';
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();

      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      if (isToday) {
        return 'Today';
      } else {
        return DateFormat('d MMM yyyy').format(date);
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showAllTransactionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                            color: AppColors.greyText,
                            borderRadius: BorderRadius.circular(2.r)),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("All Transactions",
                              style: TextStyle(
                                  color: AppColors.textYellow,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600)),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                color: AppColors.greyText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    final summary = WalletCubit.get(context)
                        .transactionModel
                        ?.result
                        .summary;
                    if (summary != null) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        padding: EdgeInsets.all(16.sp),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          border: Border.all(color: AppColors.yellowBorder),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text("Total Credit",
                                    style: TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 12)),
                                Text(
                                    "${Methods.removeTrailingZeros(summary.totalCredit)} \$",
                                    style: const TextStyle(
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("Total Debit",
                                    style: TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 12)),
                                Text(
                                    "${Methods.removeTrailingZeros(summary.totalDebit)} \$",
                                    style: const TextStyle(
                                        color: AppColors.red,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("Last Balance",
                                    style: TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 12)),
                                Text(
                                    "${Methods.removeTrailingZeros(num.parse(summary.lastBalance))} \$",
                                    style: const TextStyle(
                                        color: AppColors.textYellow,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: BlocBuilder<WalletCubit, WalletState>(
                    builder: (context, state) {
                      final cubit = WalletCubit.get(context);

                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: cubit.allTransactions.length + 1,
                        itemBuilder: (context, index) {
                          if (index == cubit.allTransactions.length) {
                            if (cubit.isLoadingMoreTransactions) {
                              return Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.yellow)),
                              );
                            } else if (cubit.hasMoreTransactions) {
                              return Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        cubit.loadMoreTransactions(),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.yellow,
                                        foregroundColor: AppColors.black),
                                    child:  Text("Load More",style: WhiteTitle.display5(context),),
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: const Center(
                                    child: Text("No more transactions",
                                        style: TextStyle(
                                            color: AppColors.greyText))),
                              );
                            }
                          }

                          return _buildTransactionItem(
                              cubit.allTransactions[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Portfolio Section
  Widget _buildPortfolioSection() {
    return Center(
      child: Column(
        children: [
          Text(
            LocaleKeys.currentBalance.tr().toUpperCase(),
            style: const TextStyle(color: AppColors.greyText, fontSize: 14),
          ),
          SizedBox(height: 8.h),
          BlocBuilder<WalletCubit, WalletState>(
            buildWhen: (previous, current) {
              return current is GetWalletSuccessState ||
                  current is GetWalletLoadingState ||
                  current is GetWalletErrorState;
            },
            builder: (context, state) {
              if (state is GetWalletLoadingState) {
                return const CircularProgressIndicator(
                  color: AppColors.yellow,
                );
              }
              if (state is GetWalletErrorState) {
                return const Text(
                  'Error loading balance',
                  style: TextStyle(color: AppColors.red),
                );
              }
              return Text(
                '\$ ${WalletCubit.get(context).walletDollar.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textYellow,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
