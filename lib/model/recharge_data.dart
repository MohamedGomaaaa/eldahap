import 'dart:io';

import 'package:official_gold/model/payment_data.dart';

class RechargeData {
  final String name;
  final String phone;
  final File image;
  final PaymentData paymentData;
  final double amount;

  RechargeData({
    required this.name,
    required this.phone,
    required this.image,
    required this.paymentData,
    required this.amount,
  });
}