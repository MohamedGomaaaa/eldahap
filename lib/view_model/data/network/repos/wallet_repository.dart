import 'package:official_gold/model/report_1.dart';
import 'package:official_gold/view_model/data/network/data_providers/wallet_providers.dart';

import '../../../../model/convert_currency.dart';
import '../../../../model/report_2.dart';
import '../../../../model/response.dart';
import '../../../../model/setting.dart';
import '../../../../model/trade_model.dart';
import '../../../../model/wallet.dart';
import '../../../models/wallet_models/transaction_model.dart';
import '../dio_helper.dart';

class WalletRepository {

  late final WalletProvider walletProvider;

  WalletRepository() {
    walletProvider = WalletProvider();
  }





  Future<WalletResult> wallet() async {
    try {
      final  walletResponse = await walletProvider.wallet();

      final wallet = Wallet.fromJson(walletResponse?.data);

      return wallet.result ?? WalletResult();
    } catch (e) {
      print("Error in wallet repository: $e");
      rethrow;
    }
  }



  Future<ConvertCurrencyResult> convertCurrency({
    required num amount,

  }) async {
    try {
      final response = await walletProvider.convertCurrency(
        amount: amount,

      );

      final data = response?.data;

      if (data['success'] == true) {
        return ConvertCurrencyResult.fromJson(data['result']);
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print("Error in convert currency: $e");
      rethrow;
    }
  }





  Future<SettingResult> getExchangeRate() async {
    try {
      final response = await walletProvider.getExchangeRate();

      final setting = Setting.fromJson(response?.data);

      return setting.result ?? SettingResult();
    } catch (e) {
      print("Error in settings repository: $e");
      rethrow;
    }
  }



/////////////////////////////////////////  old wallet gomaa
//   Future<double> wallet() async {
//     try {
//       final walletResponse = await walletProvider.wallet();
//
//       final balance = walletResponse?.data?['result']?['balance'];
//
//       return (balance as num?)?.toDouble() ?? 0.0;
//     } catch (e) {
//       print("Error in wallet repository: $e");
//       rethrow;
//     }
//   }
/////////////////////////////////////////////////////////////






  // Future<num> wallet() async {
  //   try {
  //     final walletResponse = await walletProvider.wallet();
  //     return double.parse(walletResponse?.data?['result']["balance"] ?? '0') ;
  //   } catch (e) {
  //     print("Error in wallet repository: $e");
  //     rethrow;
  //   }
  // }

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


  //
  // Future<List<Report>> depositReports() async {
  //   try {
  //     final depositReportsResponse = await walletProvider.depositReports();
  //     return depositReportsResponse?.data?['result'].map<Report>((e) => Report.fromJson(e)).toList() ?? [];
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  //
  // Future<List<Report>> withdrawReports() async {
  //   try {
  //     final withdrawReportsResponse = await walletProvider.withdrawReports();
  //     return withdrawReportsResponse?.data?['result'].map<Report>((e) => Report.fromJson(e)).toList() ?? [];
  //   } catch (e) {
  //     rethrow;
  //   }
  // }






  Future<List<ReportResult2>> reports({required String type}) async {
    try {
      final reportsResponse = await walletProvider.reports(type: type);

      return (reportsResponse?.data?['result'] as List? ?? [])
          .map<ReportResult2>((e) => ReportResult2.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }


  Future<List<TradeOrOrder>> getOrderReports({required String type}) async {
    try {
      final response = await walletProvider.orderReports(type: type);

      final report = Report1.fromJson(response?.data ?? {});

      return report.result?.tradeOrOrder ?? [];
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
