import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/svg_widget.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import '../../../../../model/news_model.dart';
import '../../../../components/app_bar_widget.dart';

class NewsScreen extends StatelessWidget {
  final News newModel;
  const NewsScreen({required this.newModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(),
      body: ListView(
        padding: EdgeInsets.all(12.sp),
        children: [
          Row(
            children: [
              SvgWidget(
                assetName: AppAssets.news,
                height: 20.h,
              ),
              SizedBox(
                width: 12.w,
              ),
              Text(
                newModel.name ?? '',
                // LocaleKeys.articleTitle.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.yellow,
                    ),
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              clipBehavior: Clip.none,
            ),
            items: List.generate(
              1,
                  (index) => Container(
                width: double.infinity,
                height: 150.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.yellowBorder,
                    width: 0.5.sp,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    newModel.image ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Image.asset(
                          AppAssets.logoPng,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            newModel.content ?? '',
            // 'Article content Similar to most of the written literary forms, articles contain an introduction, a body, and a conclusion. Again, we write an article for the target audience. Of course, if our article fails to appeal to the target audience, it would be of no use. \n\nSimilar to most of the written literary forms, articles contain an introduction, a body, and a conclusion. Again, we write an article for the target audience. Of course, if our article fails to appeal to the target audience, it would be of no use. \n\nSimilar to most of the written literary forms, articles contain an introduction, a body, and a conclusion. Again, we write an article for the target audience. Of course, if our article fails to appeal to the target audience, it would be of no use.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
