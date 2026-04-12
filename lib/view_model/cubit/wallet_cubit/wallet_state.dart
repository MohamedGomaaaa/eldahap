part of 'wallet_cubit.dart';

@immutable
abstract class WalletState {}

class WalletInitial extends WalletState {}

// Wallet Balance States
class GetWalletLoadingState extends WalletState {}



/////////////////////////////////////////////////////// old wallet gomaa
// class GetWalletSuccessState extends WalletState {
//   final num wallet;
//   GetWalletSuccessState(this.wallet);
// }
///////////////////////////////////////////////////////
class GetWalletSuccessState extends WalletState  {
  final num walletDollar;
  final num walletEgp;

  GetWalletSuccessState(this.walletDollar, this.walletEgp);
}




class ConvertCurrencyLoadingState extends WalletState{}

class ConvertCurrencySuccessState extends WalletState{
  final num convertedAmount;
  final num walletDollar;
  final num walletEgp;

  ConvertCurrencySuccessState(
      this.convertedAmount,
      this.walletDollar,
      this.walletEgp,
      );
}

class ConvertCurrencyErrorState extends WalletState{
  final String msg;

  ConvertCurrencyErrorState({required this.msg});
}


























class GetWalletErrorState extends WalletState {
  final String? msg;
  GetWalletErrorState({this.msg});
}

// Transaction States
class GetTransactionLoadingState extends WalletState {}

class GetTransactionSuccessState extends WalletState {
  final TransactionModel? transactionModel;
  GetTransactionSuccessState(this.transactionModel);
}

class GetTransactionErrorState extends WalletState {
  final String? msg;
  GetTransactionErrorState({this.msg});
}

// Pagination States
class LoadMoreTransactionsState extends WalletState {}

class LoadMoreTransactionsSuccessState extends WalletState {
  final List<TransactionData> allTransactions;
  LoadMoreTransactionsSuccessState(this.allTransactions);
}

class LoadMoreTransactionsErrorState extends WalletState {
  final String? msg;
  LoadMoreTransactionsErrorState({this.msg});
}

// Currency States
class GetCurrenciesLoadingState extends WalletState {}

class GetCurrenciesSuccessState extends WalletState {
  final Map<String, dynamic> currencies;
  GetCurrenciesSuccessState(this.currencies);
}

class GetCurrenciesErrorState extends WalletState {
  final String? msg;
  GetCurrenciesErrorState({this.msg});
}

class ChangeCurrentCurrencyState extends WalletState {}

// Payment States
class PayUsdtLoadingState extends WalletState {}

class PayUsdtSuccessState extends WalletState {
  final String msg;
  PayUsdtSuccessState(this.msg);
}

class PayUsdtErrorState extends WalletState {
  final String? msg;
  PayUsdtErrorState({this.msg});
}

// Reports States
class GetDepositReportsLoadingState extends WalletState {}


class GetDepositReportsErrorState extends WalletState {
  final String? msg;
  GetDepositReportsErrorState({this.msg});
}

class GetWithdrawReportsLoadingState extends WalletState {}


// class GetDepositReportsSuccessState extends WalletState {
//   final List<Report> reports;
//   GetDepositReportsSuccessState(this.reports);
// }

// class GetWithdrawReportsSuccessState extends WalletState {
//   final List<Report> reports;
//   GetWithdrawReportsSuccessState(this.reports);
// }


class GetWithdrawReportsErrorState extends WalletState {
  final String? msg;
  GetWithdrawReportsErrorState({this.msg});
}

// Withdraw States
class WithdrawLoadingState extends WalletState {}

class WithdrawSuccessState extends WalletState {
  final String msg;
  WithdrawSuccessState(this.msg);
}

class WithdrawErrorState extends WalletState {
  final String? msg;
  WithdrawErrorState({this.msg});
}

// Deposit States
class DepositLoadingState extends WalletState {}

class DepositSuccessState extends WalletState {
  final String msg;
  DepositSuccessState(this.msg);
}

class DepositErrorState extends WalletState {
  final String? msg;
  DepositErrorState({this.msg});
}










class GetExchangeRateLoadingState extends WalletState {}

class GetExchangeRateSuccessState extends WalletState {

  final num exchangeDollarRate;


  GetExchangeRateSuccessState(
      this.exchangeDollarRate,

      );
}

class GetExchangeRateErrorState extends WalletState {
  final String msg;

  GetExchangeRateErrorState({required this.msg});
}








class CalculateDepositAmountState extends WalletState {
  final num depositUsdAmount;
  final num depositEgpAmount;

  CalculateDepositAmountState({
    required this.depositUsdAmount,
    required this.depositEgpAmount,
  });
}
















class GetReportsLoadingState extends WalletState {}

class GetReportsSuccessState extends WalletState {
  final List<ReportResult2> reports;

  GetReportsSuccessState(this.reports);
}

class GetReportsErrorState extends WalletState {
  final String msg;

  GetReportsErrorState({required this.msg});
}









class GetOrderReportsLoadingState extends WalletState {}

class GetOrderReportsSuccessState extends WalletState {
  final List<TradeOrOrder> reports;

  GetOrderReportsSuccessState(this.reports);
}

class GetOrderReportsErrorState extends WalletState {
  final String msg;

  GetOrderReportsErrorState({required this.msg});
}










