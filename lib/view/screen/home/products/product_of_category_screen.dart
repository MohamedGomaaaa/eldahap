import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/category.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import '../../../../l10n/locale_keys.g.dart';
import '../../../../model/product.dart';
import '../../../../view_model/cubit/product_cubit/product_cubit.dart';
import '../../../components/live_status_text.dart';
import 'components/product_widget.dart';

class ProductsOfCategoryScreen extends StatefulWidget {
  final int index;
  final int categoryId;

  const ProductsOfCategoryScreen({
    required this.index,
    required this.categoryId,
    super.key,
  });

  @override
  State<ProductsOfCategoryScreen> createState() =>
      _ProductsOfCategoryScreenState();
}

class _ProductsOfCategoryScreenState extends State<ProductsOfCategoryScreen> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ تتنادي مرة واحدة بس
    if (!_loadedOnce) {
      _loadedOnce = true;
      ProductCubit.get(context).getProductsByCategoryId(categoryId:widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ProductCubit.get(context),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            child: const LiveStatusText(),
          ),
          SizedBox(height: 12.h),

          BlocBuilder<ProductCubit, ProductState>(
            buildWhen: (previous, current) =>
            current is GetProductsSuccessState ||
                current is GetProductsLoadingState,
            builder: (context, state) {
              final cubit = ProductCubit.get(context);

              return Visibility(
                visible: state is GetProductsSuccessState,
                replacement: ShimmerWidget(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index2) => ProductWidget(
                      product: Product(),
                      category: Category(),
                      tabIndex: widget.index, // ✅ USD لو 0, EGP لو 1
                    ),
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemCount: 5,
                  ),
                ),
                child: cubit.categories[widget.index].products.isEmpty
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 0.3.sh),
                    child: Text(LocaleKeys.noProductsFound.tr()),
                  ),
                )
                    : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cubit.categories[widget.index].products.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 12.h),
                  itemBuilder: (context, index2) => ProductWidget(
                    product: cubit.categories[widget.index].products[index2],
                    category: cubit.categories[widget.index],
                    tabIndex: widget.index, // ✅ USD لو 0, EGP لو 1
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// class ProductsOfCategoryScreen extends StatefulWidget {
//   final int index;
//   const ProductsOfCategoryScreen({required this.index, super.key});
//
//   @override
//   State<ProductsOfCategoryScreen> createState() =>
//       _ProductsOfCategoryScreenState();
// }
//
// class _ProductsOfCategoryScreenState extends State<ProductsOfCategoryScreen> {
//   bool _loadedOnce = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // ✅ تتنادي مرة واحدة بس
//     if (!_loadedOnce) {
//       _loadedOnce = true;
//       ProductCubit.get(context).getProducts(widget.index);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: ProductCubit.get(context),
//       child: ListView(
//         padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
//         children: [
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 8.w),
//             child: const LiveStatusText(),
//           ),
//           SizedBox(height: 12.h),
//
//           BlocBuilder<ProductCubit, ProductState>(
//             buildWhen: (previous, current) =>
//             current is GetProductsSuccessState ||
//                 current is GetProductsLoadingState,
//             builder: (context, state) {
//               final cubit = ProductCubit.get(context);
//
//               return Visibility(
//                 visible: state is GetProductsSuccessState,
//                 replacement: ShimmerWidget(
//                   child: ListView.separated(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (context, index2) => ProductWidget(
//                       product: Product(),
//                       category: Category(),
//                       tabIndex: widget.index, // ✅ USD لو 0, EGP لو 1
//                     ),
//                     separatorBuilder: (context, index) => SizedBox(height: 12.h),
//                     itemCount: 5,
//                   ),
//                 ),
//                 child: cubit.categories[widget.index].products.isEmpty
//                     ? Center(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 0.3.sh),
//                     child: Text(LocaleKeys.noProductsFound.tr()),
//                   ),
//                 )
//                     : ListView.separated(
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount:
//                   cubit.categories[widget.index].products.length,
//                   shrinkWrap: true,
//                   separatorBuilder: (context, index) =>
//                       SizedBox(height: 12.h),
//                   itemBuilder: (context, index2) => ProductWidget(
//                     product:
//                     cubit.categories[widget.index].products[index2],
//                     category: cubit.categories[widget.index],
//                     tabIndex: widget.index, // ✅ USD لو 0, EGP لو 1
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }