import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:official_gold/view/screen/home/products/product_of_category_screen.dart';
import 'package:official_gold/view_model/cubit/product_cubit/product_cubit.dart';
import 'package:official_gold/view_model/utils/colors.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ProductCubit.get(context)..getCategories(),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.sp),
          child: BlocBuilder<ProductCubit, ProductState>(
            buildWhen: (previous, current) {
              return current is GetCategoriesLoadingState ||
                  current is GetCategoriesSuccessState ||
                  current is GetCategoriesErrorState;
            },
            builder: (context, state) {
              return DefaultTabController(
                initialIndex: 0,
                length: ProductCubit.get(context).categories.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // إزالة أي مسافات من الخارج
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: AppColors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.grey,
                            width: 0.8.sp,
                          ),
                        ),
                      ),
////////////////////////////////////////////////////////////////////////////////////////////    TabBar
                      child: BlocBuilder<ProductCubit, ProductState>(
                        buildWhen: (previous, current) {
                          return current is GetCategoriesLoadingState ||
                              current is GetCategoriesSuccessState ||
                              current is GetCategoriesErrorState;
                        },
                        builder: (context, state) {
                          final productCubit = ProductCubit.get(context);
                          return TabBar(
                            isScrollable: true, // ✅ Now scrollable
                             tabAlignment: TabAlignment.center, // ✅ This removes the automatic padding
                            padding: EdgeInsets.zero, // ⬅️ يزيل padding حول الـ TabBar
                            labelPadding: const EdgeInsets.symmetric(horizontal: 12), // فقط بين التبويبات
                            indicatorPadding: EdgeInsets.zero, // ⬅️ يزيل padding من المؤشر نفسه
                            labelStyle:  TextStyle(
                              fontFamily: GoogleFonts.cairo().fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle:  TextStyle(
                              fontFamily: GoogleFonts.cairo().fontFamily,
                              fontSize: 14,
                            ),
                            tabs: productCubit.categories.map(
                                  (e) => Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    e.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.visible,
                                    ),
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ).toList(),
                            onTap: (index) {

                              productCubit.getProducts(index);
                            },
                          );
                        },
                      ),
                    ),
//////////////////////////////////////////////////////////////////////////////////////////////// product list
                    Expanded(
                      child: BlocBuilder<ProductCubit, ProductState>(
                        buildWhen: (previous, current) =>
                        current is GetCategoriesSuccessState,
                        builder: (context, state) {
                          final cubit = ProductCubit.get(context);
                          return TabBarView(
                            physics: const BouncingScrollPhysics(),
                            children: List.generate(
                              cubit.categories.length,
                                  (index) => ProductsOfCategoryScreen(index: index),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
