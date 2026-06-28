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
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../../view_model/models/wallet_models/transaction_model.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../../view_model/utils/validator.dart';
import '../../../../components/live_status_text.dart';
import '../../../../components/live_text.dart';



class WalletScreen extends StatefulWidget {
  final bool comingFromNavBar;
  final String userMode;
  const WalletScreen(
      {super.key, required this.comingFromNavBar, required this.userMode});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _modalScrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ جلب البيانات وطلبات الـ trades عند فتح الصفحة لأول مرة في الخلفية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalletCubit.get(context).initializeWalletData();
      WalletCubit.get(context).getTradess();
    });

    _modalScrollController.addListener(_onModalScroll);
  }

  @override
  void dispose() {
    // ✅ إيقاف التايمر عند الخروج لمنع أي تسريب في الذاكرة (Memory Leak)
    WalletCubit.get(context).totalsTimer?.cancel();
    _scrollController.dispose();
    _modalScrollController.removeListener(_onModalScroll);
    _modalScrollController.dispose();
    super.dispose();
  }

  void _onModalScroll() {
    if (_modalScrollController.position.pixels >=
        _modalScrollController.position.maxScrollExtent - 200) {
      WalletCubit.get(context).loadMoreTransactions();      // تحميل المزيد عند الاقتراب من القاع
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.comingFromNavBar == true
          ? null
          : AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LocaleKeys.wallet.tr(),
          style: const TextStyle(
            color: AppColors.textYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocListener<LivePriceCubit, LivePriceState>(
        listener: (context, state) {
          // ✅ عند وصول تحديث أسعار حي من السوكت، يتم إرسال الأسعار فوراً للتايمر
          if (state is LivePriceLive) {
            final usdPrice = state.metals['USD']?.buy ?? 0;
            final egpPrice = state.metals['EGP']?.buy ?? 0;

            // استدعاء الميثود لتشغيل الحسبة دورياً كل 5 ثوانٍ تلقائياً
            WalletCubit.get(context).startTotalsTimer(
              currentUsdPrice: usdPrice,
              currentEgpPrice: egpPrice,
            );
          }
        },
        child: BlocBuilder<LivePriceCubit, LivePriceState>(
          builder: (context, state) {
            // ✅ التحقق ما إذا كان البث المباشر يعمل والأسعار متوفرة بنجاح
            final bool hasLive = state is LivePriceLive;

            return AbsorbPointer(
              absorbing: !hasLive,
              child: RefreshIndicator(
                onRefresh: () async {
                  await WalletCubit.get(context).initializeWalletData();
                  await WalletCubit.get(context).getTradess();
                },
                backgroundColor: AppColors.yellow2,
                color: AppColors.black,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
////////////////////////////////////////////////////////////////////////////////////////// has live
                      // يعرض الـ LiveStatusText فقط إذا كان هناك اتصال حي
                      if (hasLive)
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: const LiveStatusText(),
                          ),
                        ),
//////////////////////////////////////////////////////////////////////////////////// Total Portfolio
                      // _buildPortfolioSection(),
                      // SizedBox(height: 20.h),
///////////////////////////////////////////////////////////////////////////////////// Balance Cards
                      _buildBalanceCards(),
                      SizedBox(height: 20.h),
 //////////////////////////////////////////////////////////////////////////////////// Action Buttons
                      widget.userMode == "demo"
                          ? const SizedBox()
                          : _buildActionButtons(),
                      SizedBox(height: 25.h),
 /////////////////////////////////////////////////////////////////// // Recent Transactions Header
                      _buildTransactionsHeader(),
                      SizedBox(height: 15.h),
///////////////////////////////////////////////////////////////////////////////////// Transaction List
                      _buildTransactionsList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
  // Balance Card Widget
  Widget _balanceCard(
      {required IconData icon, required String title, required Widget value})
  {
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
          value,
          SizedBox(height: 6.h),

        ],
      ),
    );
  }

  // Balance Cards Section
  Widget _buildBalanceCards() {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final cubit = WalletCubit.get(context);
        final isLoading = cubit.isWalletLoading || state is ConvertCurrencyLoadingState;

        // ✅ استخدام القيمة الإجمالية التراكمية إذا كانت أكبر من صفر، وإلا استخدام قيمة المحفظة العادية
        final displayUsd =
             cubit.totalPortfolioUsd+cubit.walletDollar;


        final displayEgp = cubit.totalPortfolioEgp +
            cubit.walletEgp;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
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
                icon: const Icon(Icons.currency_exchange, color: AppColors.white),
                label: const Text(
                  "Convert to pounds",
                  style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _balanceCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: LocaleKeys.dollarBalance.tr(),
                    value: LivePriceText(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      fontSize: 14,
                      price: displayUsd, // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالدولار
                      decimals: 2,
                      fakeMinDelta: 0.01,
                      fakeMaxDelta: 0.05,
                      fakeTickEvery: const Duration(milliseconds: 900),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _balanceCard(
                    icon: Icons.account_balance,
                    title: LocaleKeys.egyBalance.tr(),
                    value: LivePriceText(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      fontSize: 14,
                      price: displayEgp, // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالجنيه
                      decimals: 2,
                      fakeMinDelta: 0.01,
                      fakeMaxDelta: 0.05,
                      fakeTickEvery: const Duration(milliseconds: 900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manage Your Money",
          style: TextStyle(
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
                      builder: (context) => const RechargeAmountScreen()),
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
  }

  Widget _actionButton(IconData icon, String label, {required VoidCallback onTap}) {
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
          : (transaction.note.isNotEmpty ? transaction.note : "System Transaction"),
      amount: "${isCredit ? '+' : '-'} ${Methods.removeTrailingZeros(amount)} ${transaction.currency.toString()}",
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
  }) {
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

      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
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
                        decoration: BoxDecoration(color: AppColors.greyText, borderRadius: BorderRadius.circular(2.r)),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("All Transactions", style: TextStyle(color: AppColors.textYellow, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: AppColors.greyText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    final summary = WalletCubit.get(context).transactionModel?.result.summary;
                    if (summary != null) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                                const Text("Total Credit", style: TextStyle(color: AppColors.greyText, fontSize: 12)),
                                Text("${Methods.removeTrailingZeros(summary.totalCredit)} \$", style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("Total Debit", style: TextStyle(color: AppColors.greyText, fontSize: 12)),
                                Text("${Methods.removeTrailingZeros(summary.totalDebit)} \$", style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("Last Balance", style: TextStyle(color: AppColors.greyText, fontSize: 12)),
                                Text("${Methods.removeTrailingZeros(num.parse(summary.lastBalance))} \$", style: const TextStyle(color: AppColors.textYellow, fontWeight: FontWeight.w600)),
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
                                child: const Center(child: CircularProgressIndicator(color: AppColors.yellow)),
                              );
                            } else if (cubit.hasMoreTransactions) {
                              return Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () => cubit.loadMoreTransactions(),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow, foregroundColor: AppColors.black),
                                    child: const Text("Load More"),
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: const Center(child: Text("No more transactions", style: TextStyle(color: AppColors.greyText))),
                              );
                            }
                          }

                          return _buildTransactionItem(cubit.allTransactions[index]);
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
}






















































































































//////////////////////////////////////////////////////////////////////////////////before wallet


// class WalletScreen extends StatefulWidget {
//   final bool comingFromNavBar;
//   final String userMode;
//   const WalletScreen(
//       {super.key, required this.comingFromNavBar, required this.userMode});
//
//   @override
//   State<WalletScreen> createState() => _WalletScreenState();
// }
//
// class _WalletScreenState extends State<WalletScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _modalScrollController = ScrollController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     super.initState();
//     // Initialize wallet data when screen starts
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       WalletCubit.get(context).initializeWalletData();
//       WalletCubit.get(context).getTradess();
//     });
//
//     // Add scroll listener for pagination in modal
//     _modalScrollController.addListener(_onModalScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _modalScrollController.removeListener(_onModalScroll);
//     _modalScrollController.dispose();
//     super.dispose();
//   }
//
//   void _onModalScroll() {
//     if (_modalScrollController.position.pixels >=
//         _modalScrollController.position.maxScrollExtent - 200) {
//       WalletCubit.get(context).loadMoreTransactions();      // Load more when near bottom
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: widget.comingFromNavBar == true
//             ? null
//             : AppBar(
//           backgroundColor: AppColors.background,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Text(
//             LocaleKeys.wallet.tr(),
//             style: const TextStyle(
//               color: AppColors.textYellow,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           centerTitle: false,
//         ),
//         body:
//         BlocBuilder<LivePriceCubit, LivePriceState>(
//           builder: (context, state) {
//             // ✅ لو index==0 اعرض الدولار / لو 1 اعرض المصري
//
//
//             // ✅ هل في لايف فعلاً؟
//             final bool hasLive = state is LivePriceLive ;
//
//             // ✅ هات الأسعار من الستيت
//             final metals = (state is LivePriceLive)
//                 ? state.metals
//                 : const <String, MetalPrices>{};
//
//             final MetalPrices p = metals[currencyKey] ??
//                 MetalPrices(
//                   market: 0,
//                   buy: 0,
//                   sell: 0,
//                   currency: currencyKey,
//                   timestamp: '',
//                 );
//
//             // ✅ سعر الجرام لايف
//             final double gramBuy = p.buy;
//             final double gramSell = p.sell;
//
//             // ✅ اضرب في وزن المنتج بالجرام
//             final double weight = (product.gramWeight ?? 0).toDouble();
//
//             final double liveBuyTotal = gramBuy * weight;
//             return      RefreshIndicator(
//               onRefresh: () async {
//                 await WalletCubit.get(context).initializeWalletData();
//               },
//               backgroundColor: AppColors.yellow2,
//               color: AppColors.black,
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: EdgeInsets.all(16.sp),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
// ///////////////////////////////////////////////////////////////////////////////////// Total Portfolio
//                     _buildPortfolioSection(),
//                     SizedBox(height: 20.h),
// ///////////////////////////////////////////////////////////////////////////////////// Balance Cards
//                     _buildBalanceCards(),
//                     SizedBox(height: 20.h),
// //////////////////////////////////////////////////////////////////////////////////// Action Buttons
//                     widget.userMode == "demo"
//                         ? const SizedBox()
//                         : _buildActionButtons(),
//                     SizedBox(height: 25.h),
// /////////////////////////////////////////////////////////////////////////////////// // Recent Transactions Header
//                     _buildTransactionsHeader(),
//                     SizedBox(height: 15.h),
// ///////////////////////////////////////////////////////////////////////////////////// Transaction List
//                     _buildTransactionsList(),
//                   ],
//                 ),
//               ),
//             );
//           },
//         )
//
//
//     );
//   }
//
//   // Portfolio Section
//   Widget _buildPortfolioSection() {
//     return Center(
//       child: Column(
//         children: [
//           Text(
//             LocaleKeys.currentBalance.tr().toUpperCase(),
//             style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//           ),
//           SizedBox(height: 8.h),
//           BlocBuilder<WalletCubit, WalletState>(
//             buildWhen: (previous, current) {
//               return current is GetWalletSuccessState ||
//                   current is GetWalletLoadingState ||
//                   current is GetWalletErrorState;
//             },
//             builder: (context, state) {
//               if (state is GetWalletLoadingState) {
//                 return const CircularProgressIndicator(
//                   color: AppColors.yellow,
//                 );
//               }
//               if (state is GetWalletErrorState) {
//                 return const Text(
//                   'Error loading balance',
//                   style: TextStyle(color: AppColors.red),
//                 );
//               }
//               return Text(
//                 '\$ ${WalletCubit.get(context).walletDollar.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 34,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textYellow,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Balance Cards Section
//   Widget _buildBalanceCards() {
//     return BlocBuilder<WalletCubit, WalletState>(
//       builder: (context, state) {
//         final isLoading = WalletCubit.get(context).isWalletLoading ||
//             state is ConvertCurrencyLoadingState;
//
//         return
//           Column(
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(bottom: 20),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: AppColors.yellow)
//                     : ElevatedButton.icon(
//                   onPressed: () async {
//                     final amount = await showModalBottomSheet<num>(
//                       backgroundColor: AppColors.background,
//                       context: context,
//                       isScrollControlled: true,
//                       builder: (context) => convertAmountSheet(
//                         context,
//                         WalletCubit.get(context).walletDollar,
//                       ),
//                     );
//
//                     if (amount != null) {
//                       WalletCubit.get(context).convertCurrency(
//                         amount: amount,
//                       );
//                     }
//                   },
//                   icon: const Icon(Icons.currency_exchange,
//                       color: AppColors.white),
//                   label: const Text(
//                     "Convert to pounds",
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//               // الباقي زي ما هو
//               Row(
//                 children: [
//                   Expanded(
//                     child: _balanceCard(
//                       icon: Icons.account_balance_wallet_outlined,
//                       title: LocaleKeys.dollarBalance.tr(),
//                       value:
//
//
//
//                       LivePriceText(
//                         padding :const  EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//                         fontSize: 14,
//                         price:  double.parse(WalletCubit.get(context).walletDollar.toString()),
//                         decimals: 2,
//                         fakeMinDelta: 0.01,
//                         fakeMaxDelta: 0.05,
//                         fakeTickEvery:
//                         const Duration(milliseconds: 900),
//                       ),
//                       // Text(
//                       //   Methods.removeTrailingZeros(
//                       //       WalletCubit.get(context).walletDollar),
//                       //   style: const TextStyle(
//                       //     color: AppColors.yellow,
//                       //     fontWeight: FontWeight.w600,
//                       //     fontSize: 16,
//                       //   ),
//                       // ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: _balanceCard(
//                       icon: Icons.account_balance,
//                       title: LocaleKeys.egyBalance.tr(),
//                       value:
//                       LivePriceText(
//                         padding :const  EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//                         fontSize: 14,
//                         price:  double.parse(WalletCubit.get(context).walletEgp.toString()),
//                         decimals: 2,
//                         fakeMinDelta: 0.01,
//                         fakeMaxDelta: 0.05,
//                         fakeTickEvery:
//                         const Duration(milliseconds: 900),
//                       ),
//                       // Text(
//                       //   Methods.removeTrailingZeros(
//                       //       WalletCubit.get(context).walletEgp),
//                       //   style: const TextStyle(
//                       //     color: AppColors.yellow,
//                       //     fontWeight: FontWeight.w600,
//                       //     fontSize: 16,
//                       //   ),
//                       // ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//       },
//     );
//   }
//
//   // convert Amount Sheet
//   Widget convertAmountSheet(BuildContext context, num walletDollar) {
//     final TextEditingController controller = TextEditingController();
//
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16,
//         right: 16,
//         top: 20,
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 return Validator.validateAmount(
//                     value: value, walletDollar: walletDollar);
//               },
//               decoration: InputDecoration(
//                 hintText: "enter amount",
//                 suffixText: "USD",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//               ],
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     final amount = num.parse(controller.text.trim());
//
//                     // context.read<WalletCubit>().convertCurrency(
//                     //   amount: amount,
//                     // );
//
//                     Navigator.pop(context, amount); // 🔥 يقفل الشيت
//                   }
//                 },
//                 child: const Text(
//                   "convert",
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Balance Card Widget
//   Widget _balanceCard(
//       {required IconData icon, required String title, required Widget value}) {
//     return Container(
//       padding: EdgeInsets.all(16.sp),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundGrey,
//         border: Border.all(color: AppColors.yellowBorder),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(icon, color: AppColors.yellow, size: 28.sp),
//           SizedBox(height: 8.h),
//           Text(
//             title,
//             style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//           ),
//           SizedBox(height: 6.h),
//           value,
//         ],
//       ),
//     );
//   }
//
//   // Action Buttons Section
//   Widget _buildActionButtons() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Manage Your Money",
//           style: TextStyle(
//             color: AppColors.greyText,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 10.h),
//         Row(
//           children: [
//             _actionButton(
//               Icons.add_circle_outline,
//               LocaleKeys.deposit.tr(),
//               onTap: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const RechargeAmountScreen()),
//                 );
//                 final cubit = WalletCubit.get(context);
//                 cubit.getTransactions(refresh: true);
//               },
//             ),
//             SizedBox(width: 12.w),
//             _actionButton(
//               Icons.download_rounded,
//               LocaleKeys.withdraw.tr(),
//               onTap: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => WithdrawalAmountPage()),
//                 );
//                 final cubit = WalletCubit.get(context);
//                 cubit.getTransactions(refresh: true);
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Transactions Header Section
//   Widget _buildTransactionsHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text(
//           "Recent Transactions",
//           style:
//           TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w500),
//         ),
//         BlocBuilder<WalletCubit, WalletState>(
//           builder: (context, state) {
//             final hasTransactions =
//                 WalletCubit.get(context).allTransactions.isNotEmpty;
//             if (!hasTransactions) return const SizedBox.shrink();
//
//             return GestureDetector(
//               onTap: () => _showAllTransactionsModal(),
//               child: const Text(
//                 "See All",
//                 style: TextStyle(color: AppColors.yellow, fontSize: 14),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   // Transactions List Section
//   Widget _buildTransactionsList() {
//     return BlocBuilder<WalletCubit, WalletState>(
//       buildWhen: (previous, current) {
//         return current is GetTransactionLoadingState ||
//             current is GetTransactionSuccessState ||
//             current is GetTransactionErrorState ||
//             current is LoadMoreTransactionsSuccessState;
//       },
//       builder: (context, state) {
//         final cubit = WalletCubit.get(context);
//
//         if (state is GetTransactionLoadingState &&
//             cubit.allTransactions.isEmpty) {
//           return SizedBox(
//             height: 200.h,
//             child: const Center(
//               child: CircularProgressIndicator(color: AppColors.yellow),
//             ),
//           );
//         }
//
//         if (state is GetTransactionErrorState &&
//             cubit.allTransactions.isEmpty) {
//           return SizedBox(
//             height: 200.h,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     color: AppColors.red,
//                     size: 48,
//                   ),
//                   SizedBox(height: 16.h),
//                   const Text(
//                     "Error loading transactions",
//                     style: const TextStyle(color: AppColors.greyText),
//                   ),
//                   SizedBox(height: 8.h),
//                   ElevatedButton(
//                     onPressed: () => cubit.getTransactions(refresh: true),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.yellow,
//                       foregroundColor: AppColors.black,
//                     ),
//                     child: const Text("Retry"),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//
//         if (cubit.allTransactions.isEmpty) {
//           return SizedBox(
//             height: 200.h,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.receipt_long_outlined,
//                     color: AppColors.greyText,
//                     size: 48,
//                   ),
//                   SizedBox(height: 16.h),
//                   const Text(
//                     "No transactions yet",
//                     style: TextStyle(color: AppColors.greyText, fontSize: 16),
//                   ),
//                   SizedBox(height: 8.h),
//                   const Text(
//                     "Your transaction history will appear here",
//                     style: TextStyle(color: AppColors.greyText, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//
//         // Show only first 5 transactions on main screen
//         final displayTransactions = cubit.allTransactions.take(5).toList();
//
//         return Column(
//           children: displayTransactions
//               .map((transaction) => _buildTransactionItem(transaction))
//               .toList(),
//         );
//       },
//     );
//   }
//
//   // Build individual transaction item from TransactionData
//   Widget _buildTransactionItem(TransactionData transaction) {
//     final isCredit = transaction.credit > 0;
//     final amount = isCredit ? transaction.credit : transaction.debit;
//     final formattedDate = _formatDate(transaction.createdAt);
//
//     // Determine transaction type and icon
//     IconData icon;
//     String title;
//     Color iconBgColor;
//
//     if (transaction.type.toLowerCase().contains('deposit') ||
//         transaction.amountType.toLowerCase().contains('deposit') ||
//         isCredit) {
//       icon = Icons.upload_rounded;
//       title = LocaleKeys.deposit.tr();
//       iconBgColor = AppColors.green.withOpacity(0.15);
//     } else if (transaction.type.toLowerCase().contains('withdraw') ||
//         transaction.amountType.toLowerCase().contains('withdraw') ||
//         !isCredit) {
//       icon = Icons.download_rounded;
//       title = LocaleKeys.withdraw.tr();
//       iconBgColor = AppColors.red.withOpacity(0.15);
//     } else {
//       icon = Icons.swap_horiz;
//       title = transaction.type.isNotEmpty ? transaction.type : "Transaction";
//       iconBgColor = AppColors.yellow.withOpacity(0.15);
//     }
//     print("transaction.isApproval. ${transaction.isApproval}");
//     // Status color based on approval
//     Color statusColor;
//     String status;
//     if (transaction.isApproval == '1' ||
//         transaction.isApproval.toLowerCase() == 'approved' ||
//         transaction.isApproval.toLowerCase() == 'yes') {
//       statusColor = AppColors.green;
//       status = "Approved";
//     } else if (transaction.isApproval == '0' ||
//         transaction.isApproval.toLowerCase() == 'Not Approved'.toLowerCase() ||
//         transaction.isApproval.toLowerCase() == 'no') {
//       statusColor = AppColors.yellow;
//       status = "Pending";
//     } else {
//       statusColor = AppColors.red;
//       status = "Rejected";
//     }
// // amount.toStringAsFixed(2)
//     return _transactionItem(
//       transaction: transaction,
//       type: transaction.type,
//       title: title,
//       mode: transaction.amountType.isNotEmpty
//           ? transaction.amountType
//           : (transaction.note.isNotEmpty
//           ? transaction.note
//           : "System Transaction"),
//       amount:
//       "${isCredit ? '+' : '-'} ${Methods.removeTrailingZeros(amount)} ${transaction.currency.toString()}",
//       amountColor: isCredit ? AppColors.green : AppColors.red,
//       status: status,
//       statusColor: statusColor,
//       icon: icon,
//       iconBgColor: iconBgColor,
//       dateTime: formattedDate,
//       isPositive: isCredit,
//     );
//   }
//
//   // Format date string
//   String _formatDate(String dateStr) {
//     try {
//       if (dateStr.isEmpty) return 'Unknown';
//
//       final date = DateTime.parse(dateStr);
//       final now = DateTime.now();
//
//       // نقارن بالسنة والشهر واليوم مش بالساعات
//       final isToday = date.year == now.year &&
//           date.month == now.month &&
//           date.day == now.day;
//
//       if (isToday) {
//         return 'Today';
//       } else {
//         return DateFormat('d MMM yyyy').format(date);
//       }
//     } catch (e) {
//       return 'Unknown';
//     }
//   }
//
//   // Show all transactions in a modal
//   void _showAllTransactionsModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         maxChildSize: 0.95,
//         minChildSize: 0.5,
//         builder: (context, scrollController) {
//           // Use the modal scroll controller for pagination
//           //_modalScrollController.dispose();
//           return Container(
//             decoration: BoxDecoration(
//               color: AppColors.background,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//             ),
//             child: Column(
//               children: [
//                 // Handle bar and header
//                 Container(
//                   padding: EdgeInsets.all(16.sp),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 40.w,
//                         height: 4.h,
//                         decoration: BoxDecoration(
//                           color: AppColors.greyText,
//                           borderRadius: BorderRadius.circular(2.r),
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "All Transactions",
//                             style: TextStyle(
//                               color: AppColors.textYellow,
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () => Navigator.pop(context),
//                             icon: const Icon(
//                               Icons.close,
//                               color: AppColors.greyText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Transaction summary
//                 BlocBuilder<WalletCubit, WalletState>(
//                   builder: (context, state) {
//                     final summary = WalletCubit.get(context)
//                         .transactionModel
//                         ?.result
//                         .summary;
//                     if (summary != null) {
//                       return Container(
//                         margin: EdgeInsets.symmetric(
//                             horizontal: 16.w, vertical: 8.h),
//                         padding: EdgeInsets.all(16.sp),
//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundGrey,
//                           border: Border.all(color: AppColors.yellowBorder),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Column(
//                               children: [
//                                 const Text(
//                                   "Total Credit",
//                                   style: const TextStyle(
//                                       color: AppColors.greyText, fontSize: 12),
//                                 ),
//                                 Text(
//                                   // "\$${summary.totalCredit.toStringAsFixed(2)}",
//                                   "${Methods.removeTrailingZeros(summary.totalCredit)} \$",
//                                   style: const TextStyle(
//                                       color: AppColors.green,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 const Text(
//                                   "Total Debit",
//                                   style: const TextStyle(
//                                       color: AppColors.greyText, fontSize: 12),
//                                 ),
//                                 Text(
//                                   // "\$${summary.totalDebit.toStringAsFixed(2)}",
//                                   "${Methods.removeTrailingZeros(summary.totalDebit)} \$",
//                                   style: const TextStyle(
//                                       color: AppColors.red,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 const Text(
//                                   "Last Balance",
//                                   style: TextStyle(
//                                       color: AppColors.greyText, fontSize: 12),
//                                 ),
//                                 Text(
//                                   // Methods.
//                                   // "\$${summary.lastBalance}",
//                                   "${Methods.removeTrailingZeros(num.parse(summary.lastBalance))} \$",
//                                   style: const TextStyle(
//                                       color: AppColors.textYellow,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//
//                 // Transactions list
//                 Expanded(
//                   child: BlocBuilder<WalletCubit, WalletState>(
//                     builder: (context, state) {
//                       final cubit = WalletCubit.get(context);
//
//                       return ListView.builder(
//                         controller: scrollController,
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         itemCount: cubit.allTransactions.length + 1,
//                         itemBuilder: (context, index) {
//                           if (index == cubit.allTransactions.length) {
//                             // Show load more indicator or end message
//                             if (cubit.isLoadingMoreTransactions) {
//                               return Padding(
//                                 padding: EdgeInsets.all(16.sp),
//                                 child: const Center(
//                                   child: CircularProgressIndicator(
//                                     color: AppColors.yellow,
//                                   ),
//                                 ),
//                               );
//                             } else if (cubit.hasMoreTransactions) {
//                               return Padding(
//                                 padding: EdgeInsets.all(16.sp),
//                                 child: Center(
//                                   child: ElevatedButton(
//                                     onPressed: () =>
//                                         cubit.loadMoreTransactions(),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.yellow,
//                                       foregroundColor: AppColors.black,
//                                     ),
//                                     child: const Text("Load More"),
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               return Padding(
//                                 padding: EdgeInsets.all(16.sp),
//                                 child: const Center(
//                                   child: Text(
//                                     "No more transactions",
//                                     style: TextStyle(color: AppColors.greyText),
//                                   ),
//                                 ),
//                               );
//                             }
//                           }
//
//                           return _buildTransactionItem(
//                               cubit.allTransactions[index]);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Transaction Item Widget
//   Widget _transactionItem({
//     required TransactionData transaction,
//     required String title,
//     required String type,
//     required String mode,
//     required String amount,
//     required Color amountColor,
//     required String status,
//     required Color statusColor,
//     required IconData icon,
//     required Color iconBgColor,
//     required String dateTime,
//     required bool isPositive,
//   }) {
//     return InkWell(
//       highlightColor: Colors.transparent,
//       hoverColor: Colors.transparent,
//       focusColor: Colors.transparent,
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           backgroundColor: Colors.transparent,
//           isScrollControlled: true,
//           builder: (_) => TransactionDetailsBottomSheet(
//             transaction: transaction,
//             dateTime: dateTime,
//             title: title,
//             amount: amount,
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 14.h),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12.sp),
//               decoration: BoxDecoration(
//                 color: iconBgColor,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Icon(icon, color: amountColor, size: 26.sp),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // First row: title + amount
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           color: amountColor,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Flexible(
//                         child: Text(
//                           amount,
//                           style: TextStyle(
//                               color: amountColor,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13,
//                               overflow: TextOverflow.ellipsis),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 2.h),
//                   SizedBox(height: 3.h),
//                   /////////////////////////////////////////  Second row: status + mode + date
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Row(
//                           children: [
// ///////////////////////////////////////// _transaction Type
//                             Flexible(
//                               child: Container(
//                                 child: Text(
//                                   "( $type )",
//                                   style: TextStyle(
//                                       color: amountColor,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                       overflow: TextOverflow.ellipsis),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
// ///////////////////////////////////////// status is Approved
//                             Container(
//
//                               child: Text(
//                                 status,
//                                 style: TextStyle(
//                                     color: statusColor,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//
//                             ///////////////////////////////////////// mode
//
//                             // SizedBox(width: 8.w),
//                             // Container(
//                             //   color: Colors.green,
//                             //   child: Text(
//                             //     mode,
//                             //     style: const TextStyle(
//                             //         color: AppColors.yellow, fontSize: 12),
//                             //     overflow: TextOverflow.ellipsis,
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                       ///////////////////////////////////////// date
//                       Text(
//                         dateTime,
//                         style: TextStyle(
//                           color: amountColor,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Action Button Widget
//   Widget _actionButton(IconData icon, String text,
//       {required VoidCallback onTap}) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 18.h),
//           decoration: BoxDecoration(
//             color: AppColors.backgroundGrey,
//             border: Border.all(color: AppColors.yellowBorder),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: AppColors.yellow, size: 26.sp),
//               SizedBox(height: 8.h),
//               Text(
//                 text,
//                 style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//













////////////////////////////////////////////////////////////////////////////////////////////////////
// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:official_gold/l10n/locale_keys.g.dart';
// // import 'package:official_gold/view/components/gradient_widget.dart';
// // import 'package:official_gold/view/screen/home/app_bar/app_bar_widget.dart';
// // import 'package:official_gold/view/screen/home/profile/components/profile_tile_widget.dart';
// // import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
// // import '../../../../../view_model/utils/colors.dart';
// // import '../../../../../view_model/utils/navigation.dart';
// // import 'deposit_screen.dart';
// // import 'withdraw_screen.dart';
// //
// // class WalletScreen extends StatelessWidget {
// //   const WalletScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: GradientWidget(
// //         child: SafeArea(
// //           child: RefreshIndicator(
// //             onRefresh: () async {
// //               await WalletCubit.get(context).getWallet();
// //             },
// //             backgroundColor: AppColors.yellow2,
// //             color: AppColors.black,
// //             child: ListView(
// //               padding: EdgeInsets.all(12.sp),
// //               children: [
// //                 const AppBarCustom(),
// //                 SizedBox(
// //                   height: 12.h,
// //                 ),
// //                 Text(
// //                   LocaleKeys.wallet.tr(),
// //                   textAlign: TextAlign.center,
// //                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
// //                       // color: AppColors.textYellow,
// //                       ),
// //                 ),
// //                 SizedBox(
// //                   height: 6.h,
// //                 ),
// //                 const Divider(
// //                   color: AppColors.textYellow,
// //                 ),
// //                 SizedBox(
// //                   height: 6.h,
// //                 ),
// //                 Container(
// //                   padding: EdgeInsets.all(12.sp),
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(12.r),
// //                     border: Border.all(
// //                       color: AppColors.yellowBorder,
// //                       width: 0.5.w,
// //                     ),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       BlocBuilder<WalletCubit, WalletState>(
// //                         buildWhen: (previous, current) {
// //                           return current is GetWalletSuccessState || current is GetWalletLoadingState || current is GetWalletErrorState;
// //                         },
// //                         builder: (context, state) {
// //                           return Text(
// //                             '\$ ${WalletCubit.get(context).wallet}',
// //                             style: Theme.of(context)
// //                                 .textTheme
// //                                 .headlineLarge
// //                                 ?.copyWith(
// //                                   color: AppColors.textYellow,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                           );
// //                         },
// //                       ),
// //                       SizedBox(
// //                         height: 6.h,
// //                       ),
// //                       Text(
// //                         LocaleKeys.currentBalance.tr(),
// //                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                               color: AppColors.textYellow,
// //                             ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(
// //                   height: 12.h,
// //                 ),
// //                 ProfileTileWidget(
// //                   title: LocaleKeys.deposit.tr(),
// //                   onTap: () {
// //                     Navigation.push(
// //                       context,
// //                       const DepositScreen(),
// //                     );
// //                   },
// //                 ),
// //                 ProfileTileWidget(
// //                   title: LocaleKeys.withdraw.tr(),
// //                   onTap: () {
// //                     Navigation.push(
// //                       context,
// //                       const WithdrawScreen(),
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:official_gold/l10n/locale_keys.g.dart';
// import 'package:official_gold/view/screen/home/profile/wallet/recharge/recharge_amount_screen.dart';
// import 'package:official_gold/view/screen/home/profile/wallet/withdraw/withdraw_alAmount_page.dart';
// import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
//
// import '../../../../../view_model/utils/colors.dart';
// import '../../../../../view_model/utils/navigation.dart';
//
// class WalletScreen extends StatelessWidget {
//   const WalletScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           LocaleKeys.wallet.tr(),
//           style: const TextStyle(
//             color: AppColors.textYellow,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await WalletCubit.get(context).getWallet();
//         },
//         backgroundColor: AppColors.yellow2,
//         color: AppColors.black,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16.sp),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Total Portfolio
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       LocaleKeys.currentBalance.tr().toUpperCase(),
//                       style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//                     ),
//                     SizedBox(height: 8.h),
//                     BlocBuilder<WalletCubit, WalletState>(
//                       buildWhen: (previous, current) {
//                         return current is GetWalletSuccessState ||
//                             current is GetWalletLoadingState ||
//                             current is GetWalletErrorState;
//                       },
//                       builder: (context, state) {
//                         if (state is GetWalletLoadingState) {
//                           return const CircularProgressIndicator(
//                             color: AppColors.yellow,
//                           );
//                         }
//                         return Text(
//                           '\$ ${WalletCubit.get(context).wallet}',
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textYellow,
//                           ),
//                         );
//                       },
//                     ),
//                     const Text(
//                       "USD",
//                       style: TextStyle(color: AppColors.greyText, fontSize: 14),
//                     ),
//                     SizedBox(height: 4.h),
//                     // You can add portfolio change percentage here if available from cubit
//                     // Text(
//                     //   "+ 20.4% (24h change)",
//                     //   style: TextStyle(
//                     //     color: AppColors.green,
//                     //     fontSize: 14,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 20.h),
//
//               // Balance Cards (can be expanded to show gold balance if available)
//               Row(
//                 children: [
//                   Expanded(
//                     child: _balanceCard(
//                       icon: Icons.account_balance_wallet_outlined,
//                       title: LocaleKeys.currentBalance.tr(),
//                       value: BlocBuilder<WalletCubit, WalletState>(
//                         builder: (context, state) {
//                           return Text(
//                             '\$ ${WalletCubit.get(context).wallet}',
//                             style: const TextStyle(
//                               color: AppColors.white,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: _balanceCard(
//                       icon: Icons.account_balance,
//                       title: "Gold Balance", // You can localize this if needed
//                       value: const Text(
//                         "0 Grams", // Replace with actual gold balance from cubit if available
//                         style: TextStyle(
//                           color: AppColors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 20.h),
//
//               // Invest Your Money
//               Text(
//                 "Invest Your Money", // You can localize this if needed
//                 style: const TextStyle(
//                   color: AppColors.greyText,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               SizedBox(height: 10.h),
//               Row(
//                 children: [
//                   _actionButton(
//                     Icons.add_circle_outline,
//                     LocaleKeys.deposit.tr(),
//                     onTap: () {
//                       Navigation.push(
//                         context,
//                         const RechargeAmountScreen(),
//                       );
//                       // Navigation.push(
//                       //   context,
//                       //   const DepositScreen(),
//                       // );
//                     },
//                   ),
//                   SizedBox(width: 12.w),
//                   _actionButton(
//                     Icons.download_rounded,
//                     LocaleKeys.withdraw.tr(),
//                     onTap: () {
//                       Navigation.push(
//                         context,
//                         const WithdrawalAmountPage(),
//                       );
//                       // Navigation.push(
//                       //   context,
//                       //   const WithdrawScreen(),
//                       // );
//                     },
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 25.h),
//
//               // Recent Transactions
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Recent Transactions", // You can localize this if needed
//                     style: TextStyle(
//                         color: AppColors.greyText, fontWeight: FontWeight.w500),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to full transactions list
//                     },
//                     child: const Text(
//                       "See All", // You can localize this if needed
//                       style: TextStyle(color: AppColors.yellow, fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15.h),
//
//               // Transaction items - you can replace this with actual transaction data from cubit
//               _transactionItem(
//                 title: LocaleKeys.deposit.tr(),
//                 subtitle: "via InstaPay",
//                 amount: "+ 20,000 USD",
//                 amountColor: AppColors.green,
//                 status: "Pending",
//                 statusColor: AppColors.yellow,
//                 icon: Icons.upload_rounded,
//                 dateTime: "Jan 2, 9:12 AM",
//                 isPositive: true,
//               ),
//               _transactionItem(
//                 title: LocaleKeys.withdraw.tr(),
//                 subtitle: "via InstaPay",
//                 amount: "- 20,000 USD",
//                 amountColor: AppColors.red,
//                 status: "Pending",
//                 statusColor: AppColors.yellow,
//                 icon: Icons.download_rounded,
//                 dateTime: "Jan 2, 9:12 AM",
//                 isPositive: false,
//               ),
//               _transactionItem(
//                 title: LocaleKeys.deposit.tr(),
//                 subtitle: "via InstaPay",
//                 amount: "+ 20,000 USD",
//                 amountColor: AppColors.green,
//                 status: "Approved",
//                 statusColor: AppColors.green,
//                 icon: Icons.upload_rounded,
//                 dateTime: "Jan 2, 9:12 AM",
//                 isPositive: true,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Balance Card Widget
//   static Widget _balanceCard({
//     required IconData icon,
//     required String title,
//     required Widget value
//   }) {
//     return Container(
//       padding: EdgeInsets.all(16.sp),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundGrey,
//         border: Border.all(color: AppColors.yellowBorder),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: AppColors.yellow, size: 28.sp),
//           SizedBox(height: 8.h),
//           Text(
//             title,
//             style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//           ),
//           SizedBox(height: 6.h),
//           value,
//         ],
//       ),
//     );
//   }
//
//   // Action Button Widget
//   static Widget _actionButton(IconData icon, String text, {required VoidCallback onTap}) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 18.h),
//           decoration: BoxDecoration(
//             color: AppColors.backgroundGrey,
//             border: Border.all(color: AppColors.yellowBorder),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: AppColors.yellow, size: 26.sp),
//               SizedBox(height: 8.h),
//               Text(
//                 text,
//                 style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Transaction Item Widget
//   static Widget _transactionItem({
//     required String title,
//     required String subtitle,
//     required String amount,
//     required Color amountColor,
//     required String status,
//     required Color statusColor,
//     required IconData icon,
//     required String dateTime,
//     required bool isPositive,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 14.h),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12.sp),
//             decoration: BoxDecoration(
//               color: AppColors.yellow.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(icon, color: AppColors.yellow, size: 26.sp),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // First row: title + amount
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(title,
//                         style: const TextStyle(
//                             color: AppColors.white,
//                             fontWeight: FontWeight.w600)),
//                     Text(amount,
//                         style: TextStyle(
//                             color: amountColor, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//                 SizedBox(height: 4.h),
//                 // Second row: status + subtitle + date
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 8.w, vertical: 2.h),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: Text(
//                             status,
//                             style: TextStyle(
//                                 color: statusColor,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         SizedBox(width: 8.w),
//                         Text(subtitle,
//                             style: const TextStyle(
//                                 color: AppColors.greyText, fontSize: 12)),
//                       ],
//                     ),
//                     Text(
//                       dateTime,
//                       style: const TextStyle(
//                         color: AppColors.greyText,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
