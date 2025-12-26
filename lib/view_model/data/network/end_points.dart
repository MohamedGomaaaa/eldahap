class EndPoints {
  static const String baseUrl = 'https://officialgold.site/api/' ;
      //'https://zaid.ramadona.com/api/';
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyResetOtp = 'auth/verify-reset-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String logout = 'auth/logout';
  static const String profile = 'auth/profile';
  static const String updateProfile = 'auth/update-profile';
  static const String changeMode = 'auth/change-mode';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String sliders = 'sliders';
  static const String pages = 'pages';
  static const String singlePages = 'single-pages';
  static const String news = 'news';
  static const String singleNews = 'single-news';
  static const String faq = 'faq';
  static const String socialMedia = 'socialmedia';
  static const String makeOrder = 'make-order';
  static const String orderStore = 'order/store';

  /// Finance
  static const String wallet = 'wallet';
  static const String transactions = 'finance/transactions';
  static const String currencies = 'currencies';
  static const String reportDeposit = 'report-deposit';
  static const String reportWithdraw = 'report-withdraw';
  static const String makeDeposit = 'make-deposit';
  static const String makeWithdraw = 'make-withdraw';
  static const String payUsdt = 'pay-usdt';

  /// Tickets
  static const String makeTickets = 'make-tickets';
  static const String tickets = 'tickets';
  static const String ticketResponses = 'ticket-responses';
  static const String makeResponse = 'make-response';
  // static const String trades = 'trades';
   static const String allTrades = 'order/allTrades';

  static const String tradess = 'tradess';
  static const String orderss = 'orderss';


  static const String orders = 'orders';
  static const String updateTrade = 'update-trades';
  static const String deleteTrade = 'delete-trade';

  static const String closeTrade = 'trade/close';
  static const String closeOrder = 'order/cancel';

  static const String sellTrade = 'sell-trade';
}