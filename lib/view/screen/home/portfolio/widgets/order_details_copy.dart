// class OrderDetailsScreen extends StatelessWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//
//   const OrderDetailsScreen({
//     super.key,
//     required this.order,
//     required this.productTitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<OrderCubit>(
//       // ✅ لازم توفر OrderCubit فوق أي BlocBuilder/Listener بيستخدمه
//       create: (_) {
//         final cubit = OrderCubit();
//
//         // ✅ اختار طريقة واحدة حسب Cubit بتاعك:
//         // 1) لو عندك init/load:
//         // cubit.loadOrder(order);
//
//         // 2) لو OrderCubit بيحتاج order في constructor، ساعتها بدّل السطر ده:
//         // final cubit = OrderCubit(order: order);
//
//         return cubit;
//       },
//       child: OrderDetailsView(order: order, productTitle: productTitle),
//     );
//   }
// }
//
// class OrderDetailsView extends StatefulWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//
//   const OrderDetailsView({
//     super.key,
//     required this.order,
//     required this.productTitle,
//   });
//
//   @override
//   State<OrderDetailsView> createState() => _OrderDetailsViewState();
// }
//
// class _OrderDetailsViewState extends State<OrderDetailsView> {
//   // ✅ Form Key ثابت (Stateful)
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     final productTitle = widget.productTitle;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             SizedBox(width: 12.w),
//             Text(
//               "$productTitle ${order.unitGramWeight!} gm",
//               style: TextStyle(
//                 color: AppColors.yellow,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: BlocBuilder<LivePriceCubit, LivePriceState>(
//         builder: (context, liveState) {
//           // ✅ العملة حسب category index (0 => USD, 1 => EGP)
//           final String currencyKey = order.currency ?? "USD";
//           MetalPrices? mp;
//           if (liveState is LivePriceLive) {
//             mp = liveState.metals[currencyKey];
//           }
//           final double livePrice =
//               (mp?.buy ?? 0).toDouble() * (order.unitGramWeight ?? 1);
//           final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
//           return BlocProvider(
//             create: (_) => TradesCubit(),
//             child: Stack(
//               children: [
//                 SingleChildScrollView(
//                   padding: EdgeInsets.all(16.sp),
//                   child: Form(
//                     key: _formKey,
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ///////////////////////////////////////////////////////////////////////////////////////////////////////// live socket status
//                         Center(
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 10),
//                             child: const LiveStatusText(),
//                           ),
//                         ),
//                         /////////////////////////////////////////////////////////////////////////////////////////// live price
//                         LivePriceText(
//                           padding: const EdgeInsets.all(10),
//                           price: livePrice,
//                           decimals: 2,
//                           fakeMinDelta: 0.01,
//                           fakeMaxDelta: 0.05,
//                           fakeTickEvery: const Duration(milliseconds: 900),
//                         ),
//                         SizedBox(height: 24.h),
//                         Column(
//                           children: [
//                             //////////////////////////////////////////////////////////////////////////////////////////////////////// 'Amount to buy',
//                             _buildInfoRow(
//                               label: 'Amount to buy',
//                               value: '+${order.quantity ?? 0.5}',
//                               valueColor: AppColors.blueColor,
//                               isAmount: true,
//                             ),
//                             SizedBox(height: 16.h),
//                             //////////////////////////////////////////////////////////////////////////////////////////////////////// type,
//                             _buildInfoRow(
//                               label: 'Type',
//                               value: order.openPrice! < livePrice
//                                   ? ' Buy Limit'
//                                   : "Buy Stop",
//                             ),
//                             SizedBox(height: 10.h),
//                             //////////////////////////////////////////////////////////////////////////////////////////////////////// date,
//                             _buildInfoRow(
//                               label: 'Created',
//                               value: Methods.formatCreatedAt(
//                                   order.createdAt!.toString())
//                                   .toString(),
//                             ),
//                             ///////////////////////////////////////////////////////////////////////////////////////////////////////// take size
//                             SizedBox(height: 10.h),
//                             _buildInfoRow(
//                               label: "take size",
//                               value: Methods.removeTrailingZeros(
//                                 (order.quantity ?? 0) * livePrice,
//                               ),
//                             ),
//                             SizedBox(height: 10.h),
//                             ///////////////////////////////////////////////////////////////////////////////////////////////////////// take profit
//                             order.takeProfit == null || order.takeProfit == 0
//                                 ? const SizedBox()
//                                 : _buildInfoRow(
//                               label: "take profit",
//                               value: Methods.removeTrailingZeros(
//                                   order.takeProfit!),
//                             ),
//                             ///////////////////////////////////////////////////////////////////////////////////////////////////////// stop lose
//                             SizedBox(height: 10.h),
//                             order.stopLoss == null || order.stopLoss == 0
//                                 ? const SizedBox()
//                                 : _buildInfoRow(
//                               label: "stop lose",
//                               value: Methods.removeTrailingZeros(
//                                   order.stopLoss!),
//                             ),
//                             /////////////////////////////////////////////////////////////////////////////////////////////////////////  buy when == open price
//                             SizedBox(height: 10.h),
//                             order.sellWhenPrice == null ||
//                                 order.sellWhenPrice == 0
//                                 ? const SizedBox()
//                                 : _buildInfoRow(
//                               label: "buy when price is ",
//                               value: Methods.removeTrailingZeros(
//                                   order.sellWhenPrice!),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 16.h),
//                         /////////////////////////////////////////////////////////////////////////////////////////////////////////////  delete
//                         BlocConsumer<TradesCubit, TradesState>(
//                           listener: (context, state) {
//                             if (state is CloseTradeLoadingState) {
//                               print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//                             }
//
//                             if (state is CloseTradeLoadingState) {
//                               FocusManager.instance.primaryFocus?.unfocus();
//
//                               Toast.showMsg(msg: "order is successfully Deleted");
//
//                               // ✅ نروح Layout بعد الفريم عشان مانكسرش الشجرة
//                               WidgetsBinding.instance.addPostFrameCallback((_) {
//                                 if (!context.mounted) return;
//
//                                 Navigation.pushAndRemoveUntil(
//                                   context,
//                                   const LayoutScreen(),
//                                 );
//                               });
//                             }
//
//                             if (state is CloseTradeLoadingState) {
//                               Toast.showMsg(msg: "failed to delete order");
//                             }
//                           },
//                           builder: (context, state) {
//                             final isLoading = state is CloseTradeLoadingState;
//
//                             return InkWell(
//                               splashColor: Colors.transparent,
//                               highlightColor: Colors.transparent,
//                               hoverColor: Colors.transparent,
//                               focusColor: Colors.transparent,
//                               onTap: isLoading
//                                   ? null
//                                   : () {
//                                 confirmBottomSheet(
//                                   context: context,
//                                   title: 'Delete order',
//                                   onPressed: () {
//                                     Navigator.pop(context); // اقفل البوتوم شيت
//
//                                     if (widget.order.status == "pending" &&
//                                         widget.order.type == "order") {
//                                       context
//                                           .read<TradesCubit>()
//                                           .closeOrder(orderId: widget.order.id);
//                                     } else {
//                                       Toast.showMsg(msg: "this order is not pending");
//                                     }
//                                   },
//                                 );
//                               },
//                               child: Container(
//                                 width: double.infinity,
//                                 padding: EdgeInsets.symmetric(vertical: 16.h),
//                                 decoration: BoxDecoration(
//                                   color: isLoading ? AppColors.grey.withOpacity(0.5) : AppColors.grey,
//                                   borderRadius: BorderRadius.circular(12.r),
//                                 ),
//                                 child: Center(
//                                   child: isLoading
//                                       ? SizedBox(
//                                     height: 20.sp,
//                                     width: 20.sp,
//                                     child: const CircularProgressIndicator(strokeWidth: 2),
//                                   )
//                                       : Text(
//                                     'Delete order',
//                                     style: TextStyle(
//                                       color: AppColors.yellow,
//                                       fontSize: 16.sp,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                         ,
//
//                         SizedBox(height: 24.h),
//                         /////////////////////////////////////////////////////////////////////////////////////////////////////////////  stop lose section
//                         _buildStopLossSection(livePrice),
//
//                         SizedBox(height: 16.h),
//                         /////////////////////////////////////////////////////////////////////////////////////////////////////////////  take profit  section
//                         _buildTakeProfitSection(livePrice),
//
//                         SizedBox(height: 32.h),
//                         /////////////////////////////////////////////////////////////////////////////////////////////////////////////  save button
//                         _buildSaveButton(context),
//                         SizedBox(height: 20.h),
//                       ],
//                     ),
//                   ),
//                 ),
//                 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ Overlay باهت لما مفيش Live
//                 if (!hasLive)
//                   Positioned.fill(
//                     child: IgnorePointer(
//                       ignoring: true, // مجرد لون فقط
//                       child: Container(
//                         color: Colors.grey.withOpacity(0.35), // غير النسبة براحتك
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow({
//     required String label,
//     required String value,
//     Color? valueColor,
//     bool? isAmount,
//   })
//   {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: AppColors.yellow,
//             fontSize: 16.sp,
//           ),
//         ),
//         isAmount == true
//             ? Material(
//           color: AppColors.transparent,
//           borderRadius: BorderRadius.circular(8.sp),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: 14.sp,
//               vertical: 5.h,
//             ),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.sp),
//               border: Border.all(
//                 color: AppColors.blueColor,
//                 width: 1.sp,
//               ),
//             ),
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//         )
//             : Text(
//           value,
//           style: TextStyle(
//             color: valueColor ?? AppColors.white,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildStopLossSection(double livePrice) {
//     return BlocBuilder<OrderCubit, OrderState>(
//       buildWhen: (previous, current) =>
//       current is StopLossToggled ||
//           current is StopLossAmountChanged ||
//           current is OrderLoaded,
//       builder: (context, state) {
//         final cubit = context.read<OrderCubit>();
//         return Container(
//           padding: EdgeInsets.all(12.sp),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 1.w,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Stop loss',
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Switch.adaptive(
//                     value: cubit.stopLossEnabled,
//                     onChanged: (value) => cubit.toggleStopLoss(value),
//                     activeColor: AppColors.yellow,
//                     inactiveThumbColor: AppColors.yellow,
//                     inactiveTrackColor: AppColors.grey.withOpacity(0.8),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: cubit.stopLossEnabled,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 12.h),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(8.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 1.w,
//                         ),
//                       ),
//                       child: Text(
//                         'Price',
//                         style: TextStyle(
//                           color: AppColors.yellow,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//
//                     TextFormField(
//                       validator: (value) =>
//                           Validator.validateStopLoss(
//                             value: value,
//                             livePrice: livePrice,
//                           ),
//                       controller: cubit.stopLossController,
//                       textInputAction: TextInputAction.done,
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineMedium
//                           ?.copyWith(color: AppColors.red),
//                       keyboardType:
//                       const TextInputType.numberWithOptions(
//                           decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(
//                           RegExp(r'^\d+\.?\d{0,2}'),
//                         ),
//                       ],
//                       onTapOutside: (_) {
//                         FocusScope.of(context).unfocus();
//                       },
//                       decoration: InputDecoration(
//                         isDense: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 12.sp,
//                         ),
//                         isCollapsed: true,
//                         alignLabelWithHint: true,
//                       ),
//                     )
//
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTakeProfitSection(double livePrice) {
//     return BlocBuilder<OrderCubit, OrderState>(
//       buildWhen: (previous, current) =>
//       current is TakeProfitToggled ||
//           current is TakeProfitAmountChanged ||
//           current is OrderLoaded,
//       builder: (context, state) {
//         final cubit = context.read<OrderCubit>();
//         return Container(
//           padding: EdgeInsets.all(12.sp),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 1.w,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Take profit',
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Switch.adaptive(
//                     value: cubit.takeProfitEnabled,
//                     onChanged: (value) => cubit.toggleTakeProfit(value),
//                     activeColor: AppColors.yellow,
//                     inactiveThumbColor: AppColors.yellow,
//                     inactiveTrackColor: AppColors.grey.withOpacity(0.8),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: cubit.takeProfitEnabled,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 12.h),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(8.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 1.w,
//                         ),
//                       ),
//                       child: Text(
//                         'Price',
//                         style: TextStyle(
//                           color: AppColors.yellow,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     TextFormField(
//                       validator: (value) =>
//                           Validator.validateTakeProfit(
//                             value: value,
//                             livePrice: livePrice,
//                             requiredField: cubit.takeProfitEnabled,
//                           ),
//                       controller: cubit.takeProfitController,
//                       textInputAction: TextInputAction.done,
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineMedium
//                           ?.copyWith(color: AppColors.green),
//                       keyboardType:
//                       const TextInputType.numberWithOptions(
//                           decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(
//                           RegExp(r'^\d+\.?\d{0,2}'),
//                         ),
//                       ],
//                       onTapOutside: (_) {
//                         FocusScope.of(context).unfocus();
//                       },
//                       decoration: InputDecoration(
//                         isDense: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 12.sp,
//                         ),
//                         isCollapsed: true,
//                         alignLabelWithHint: true,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////// save order
//   Widget _buildSaveButton(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//
//         final ok = _formKey.currentState?.validate() ?? false;
//         if (!ok) return;
//
//         // context.read<OrderCubit>().saveOrder();
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 16.h),
//         decoration: BoxDecoration(
//           color: AppColors.yellow,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Center(
//           child: Text(
//             'Save Changes',
//             style: TextStyle(
//               color: AppColors.black,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// void confirmBottomSheet({
//   required BuildContext context,
//   required String title,
//   required void Function()? onPressed,
// })
// {
//   showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (sheetContext) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // ✅ اقفل الشيت الأول
//                   Navigator.pop(sheetContext);
//
//                   // ✅ وبعدها نفّذ الأكشن
//                   onPressed?.call();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(sheetContext, false);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       );
//     },
//   );
// }
