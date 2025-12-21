import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view/screen/home/home/home_screen.dart';
import 'package:official_gold/view/screen/home/portfolio/portfolio_screen.dart';
import 'package:official_gold/view/screen/home/products/products_screen.dart';

import '../../../view/screen/home/profile/tawk_chat/tawk_chat_screen.dart';
import '../../../view/screen/home/profile/wallet/wallet_screen.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(context) => BlocProvider.of<LayoutCubit>(context);

  int index = 0;

  List<Widget> screens =  [
    HomeScreen(),
    ProductsScreen(),
    PortfolioScreen(),
    WalletScreen(),
    //Charts(),
    TawkChatPage()
    // ProfileScreen(),
    //PayUsdtScreen(),
  ];

  void changeCurrentIndex (int index){
    this.index = index;
    emit(ChangeCurrentIndexState());
  }
}
