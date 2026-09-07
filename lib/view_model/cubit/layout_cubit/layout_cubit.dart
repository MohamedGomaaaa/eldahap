import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view/screen/home/home/home_screen.dart';

import '../../../view/screen/chart_screen/product_chart_screen.dart';
import '../../../view/screen/portfolio/portfolio_all_trades_orders_screen.dart';
import '../../../view/screen/products/products_screen.dart';
import '../../../view/screen/profile/wallet/wallet_screen.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(context) => BlocProvider.of<LayoutCubit>(context);

  int index = 0;

  List<Widget> screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const PortfolioScreen(),
    // WalletScreen(comingFromNavBar:true,userMode: "",),

    const TradingViewPage(type: 1), // 1 = Gold, 2 = Silver, 3 = Bitcoin

    const WalletScreen(comingFromNavBar: false)

    // const TawkChatPage()
    // ProfileScreen(),
    //PayUsdtScreen(),
  ];

  void changeCurrentIndex(int index) {
    this.index = index;
    emit(ChangeCurrentIndexState());
  }
}
