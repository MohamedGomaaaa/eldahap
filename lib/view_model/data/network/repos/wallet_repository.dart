import 'package:official_gold/model/report.dart';
import 'package:official_gold/view_model/data/network/data_providers/wallet_providers.dart';

import '../../../models/wallet_models/transaction_model.dart';

class WalletRepository {

  late final WalletProvider walletProvider;

  WalletRepository() {
    walletProvider = WalletProvider();
  }

  Future<num> wallet() async {
    try {
      final walletResponse = await walletProvider.wallet();
      return double.parse(walletResponse?.data?['result'] ?? '0') ;
    } catch (e) {
      print("Error in wallet repository: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> currencies() async {
    try {
      final currenciesResponse = await walletProvider.currencies();
      return currenciesResponse?.data?['result'];
    } catch (e) {
      rethrow;
    }
  }


  Future<String> payUsdt({required String currency, required num amount, String? message}) async {
    try {
      final payUsdtResponse = await walletProvider.payUsdt(currency: currency, amount: amount, message: message);
      return payUsdtResponse?.data?['result'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Report>> depositReports() async {
    try {
      final depositReportsResponse = await walletProvider.depositReports();
      return depositReportsResponse?.data?['result'].map<Report>((e) => Report.fromJson(e)).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Report>> withdrawReports() async {
    try {
      final withdrawReportsResponse = await walletProvider.withdrawReports();
      return withdrawReportsResponse?.data?['result'].map<Report>((e) => Report.fromJson(e)).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> withdraw({required num amount,}) async {
    try {
      final withdrawResponse = await walletProvider.withdraw(amount: amount,);
      return withdrawResponse?.data?['result'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deposit({required num amount,}) async {
    try {
      final depositResponse = await walletProvider.deposit(amount: amount,);
      return depositResponse?.data?['result'];
    } catch (e) {
      rethrow;
    }
  }


  Future<TransactionModel> transactions({int page = 1, int perPage = 10}) async {
    try {
      final transactionsResponse = await walletProvider.transactions(page: page, perPage: perPage);
      TransactionModel transactionModel = TransactionModel.fromJson(transactionsResponse?.data);
      return transactionModel;
    } catch (e) {
      rethrow;
    }
  }
}
