class OrderModel {
  final String productName;
  final String productIcon;
  final double currentPrice;
  final double amountToBuy;
  final String orderType;
  final DateTime createdAt;
  final double buyAtPrice;
  final double tradeSize;
  final String leverage;
  final double margin;
  final double overnightFunding;

  OrderModel({
    required this.productName,
    required this.productIcon,
    required this.currentPrice,
    required this.amountToBuy,
    required this.orderType,
    required this.createdAt,
    required this.buyAtPrice,
    required this.tradeSize,
    required this.leverage,
    required this.margin,
    required this.overnightFunding,
  });
}
