import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/category.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';

import '../../../../model/product.dart';
import '../../../../view_model/cubit/product_cubit/product_cubit.dart';

import '../../../services/translation/locale_keys.g.dart';
import '../../../utils/app_color.dart';
import '../../components/live_status_text.dart';
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
    if (!_loadedOnce) {
      _loadedOnce = true;
      // استدعاء الدالة لجلب المنتجات
      ProductCubit.get(context).getProductsByCategoryId(categoryId: widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ProductCubit.get(context),
      // ✅ 1. إضافة RefreshIndicator هنا
      child: RefreshIndicator(
        color: AppColors.yellow,
        onRefresh: () async {
          // استدعاء الدالة عند السحب لأسفل
          await ProductCubit.get(context).getProductsByCategoryId(categoryId: widget.categoryId);
        },
        child: ListView(
          // ✅ 2. إضافة AlwaysScrollable عشان يشتغل الريفريش لو مفيش منتجات
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              child: const LiveStatusText(),
            ),
            SizedBox(height: 12.h),

            // ✅ 3. إزالة buildWhen عشان يتفاعل مع كل الحالات بشكل سليم
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                final cubit = ProductCubit.get(context);
                final productsList = cubit.categories[widget.index].products;

                // هنعرض الشيمر فقط لو بيحمل واللستة فاضية بالفعل
                final isLoading = state is GetProductsLoadingState ;

                return Visibility(
                  visible: !isLoading, // ✅ 4. تعديل شرط الظهور
                  replacement: ShimmerWidget(
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index2) => ProductWidget(
                        product: Product(),
                        category: Category(),
                        tabIndex: widget.index,
                      ),
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemCount: 5,
                    ),
                  ),
                  child: productsList.isEmpty && state is GetProductsSuccessState
                      ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.3.sh),
                      child: Text(LocaleKeys.noProductsFound.tr()),
                    ),
                  )
                      : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productsList.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index2) => ProductWidget(
                      product: productsList[index2],
                      category: cubit.categories[widget.index],
                      tabIndex: widget.index,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}