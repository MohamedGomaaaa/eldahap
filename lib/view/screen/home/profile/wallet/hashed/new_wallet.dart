// import 'package:flutter/material.dart';
//
// import '../../../../../view_model/utils/colors.dart';
//
// class WalletPage extends StatelessWidget {
//   const WalletPage({super.key});
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
//           onPressed: () {},
//         ),
//         title: const Text(
//           "Wallet",
//           style: TextStyle(
//             color: AppColors.textYellow,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Total Portfolio
//             Center(
//               child: Column(
//                 children: [
//                   const Text(
//                     "TOTAL PORTFOLIO VALUE",
//                     style: TextStyle(color: AppColors.greyText, fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "150,691",
//                     style: TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textYellow,
//                     ),
//                   ),
//                   const Text(
//                     "EGP",
//                     style: TextStyle(color: AppColors.greyText, fontSize: 14),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "+ 20.4% (24h change)",
//                     style: TextStyle(
//                       color: AppColors.green,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Gold + Wallet Balances
//             Row(
//               children: [
//                 Expanded(
//                   child: _balanceCard(
//                     icon: Icons.account_balance,
//                     title: "Gold Balance",
//                     value: "6 Grams",
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _balanceCard(
//                     icon: Icons.account_balance_wallet_outlined,
//                     title: "Wallet Balance",
//                     value: "112,671 EGP",
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Invest Your Money
//             const Text(
//               "Invest Your Money",
//               style: TextStyle(
//                 color: AppColors.greyText,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 _actionButton(Icons.add_circle_outline, "Recharge"),
//                 const SizedBox(width: 12),
//                 _actionButton(Icons.download_rounded, "Withdraw"),
//               ],
//             ),
//
//             const SizedBox(height: 25),
//
//             // Recent Transactions
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text(
//                   "Recent Transactions",
//                   style: TextStyle(
//                       color: AppColors.greyText, fontWeight: FontWeight.w500),
//                 ),
//                 Text(
//                   "See All",
//                   style: TextStyle(color: AppColors.yellow, fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             _transactionItem(
//               title: "Recharge",
//               subtitle: "via InstaPay",
//               amount: "+ 20,000 EGP",
//               amountColor: AppColors.green,
//               status: "Pending",
//               statusColor: AppColors.yellow,
//               icon: Icons.upload_rounded,
//               dateTime: "Jan 2, 9:12 AM",
//               isPositive: true,
//             ),
//             _transactionItem(
//               title: "Withdraw",
//               subtitle: "via InstaPay",
//               amount: "- 20,000 EGP",
//               amountColor: AppColors.red,
//               status: "Pending",
//               statusColor: AppColors.yellow,
//               icon: Icons.download_rounded,
//               dateTime: "Jan 2, 9:12 AM",
//               isPositive: false,
//             ),
//             _transactionItem(
//               title: "Recharge",
//               subtitle: "via InstaPay",
//               amount: "+ 20,000 EGP",
//               amountColor: AppColors.green,
//               status: "Approve",
//               statusColor: AppColors.green,
//               icon: Icons.upload_rounded,
//               dateTime: "Jan 2, 9:12 AM",
//               isPositive: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Balance Card Widget
//   static Widget _balanceCard(
//       {required IconData icon, required String title, required String value}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundGrey,
//         border: Border.all(color: AppColors.yellowBorder),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: AppColors.yellow, size: 28),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Action Button Widget
//   static Widget _actionButton(IconData icon, String text) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: AppColors.backgroundGrey,
//           border: Border.all(color: AppColors.yellowBorder),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: AppColors.yellow, size: 26),
//             const SizedBox(height: 8),
//             Text(
//               text,
//               style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//             ),
//           ],
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
//       margin: const EdgeInsets.only(bottom: 14),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.yellow.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: AppColors.yellow, size: 26),
//           ),
//           const SizedBox(width: 12),
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
//                 const SizedBox(height: 4),
//                 // Second row: status + subtitle
//                 Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             status,
//                             style: TextStyle(
//                                 color: statusColor,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(subtitle,
//                             style: const TextStyle(
//                                 color: AppColors.greyText, fontSize: 12)),
//
//
//                       ],
//                     ),
//                     Text(
//                       dateTime,
//                       style: TextStyle(
//                         color: AppColors.greyText,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 // Third row: date and time (green or red depending on positive/negative)
//
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
