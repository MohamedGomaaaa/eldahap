import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/category.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';

import '../../../../l10n/locale_keys.g.dart';
import '../../../../model/product.dart';
import '../../../../view_model/cubit/product_cubit/product_cubit.dart';
import 'components/product_widget.dart';

class ProductsOfCategoryScreen extends StatelessWidget {
  final int index;
  const ProductsOfCategoryScreen({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ProductCubit.get(context)
        ..getProducts(index),
      child: ListView(
        padding: EdgeInsets.symmetric(
          vertical: 12.sp,
          horizontal: 12.sp,
        ),
        children: [
          Text(
            LocaleKeys.latestProducts.tr(),
          ),
          SizedBox(
            height: 12.h,
          ),
          BlocBuilder<ProductCubit, ProductState>(
            buildWhen: (previous, current) {

              return current is GetProductsSuccessState || current is GetProductsLoadingState;
            },
            builder: (context, state) {
              ProductCubit cubit = ProductCubit.get(context);
              print("cubit.state.current: ${state}");

              return Visibility(
                visible: state is GetProductsSuccessState,
                replacement: ShimmerWidget(
                  child: ListView.separated(
                    physics:
                    const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index2) =>
                        ProductWidget(
                          product: Product(),
                          category: Category(),
                          tabIndex: index + 1,
                        ),
                    separatorBuilder: (context, index) =>
                        SizedBox(
                          height: 12.h,
                        ),
                    itemCount: 5,
                  ),
                ),
                child:

                cubit
                    .categories[index].products.isEmpty?
                  Center(
                    child: Padding(
                      padding:  EdgeInsets.only(top: 0.3.sh),
                      child: Text( LocaleKeys.noProductsFound.tr(),),
                    ),

              ):
                ListView.separated(
                  physics:
                  const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index2) =>
                      ProductWidget(
                        product: cubit.categories[index]
                            .products[index2],
                        category: cubit.categories[index],
                        tabIndex: index + 1,
                      ),
                  separatorBuilder: (context, index) =>
                      SizedBox(
                        height: 12.h,
                      ),
                  itemCount: cubit
                      .categories[index].products.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
