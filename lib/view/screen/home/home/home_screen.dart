import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/screen/home/home/news/news_screen.dart';
import 'package:official_gold/view/screen/home/home/precious_metals_widget.dart';
import 'package:official_gold/view_model/cubit/home_cubit/home_cubit.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/navigation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/utils/colors.dart';
import '../../../../view_model/utils/common_method.dart';
import '../../../components/shimmer_widget.dart';
import '../../../components/svg_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: HomeCubit.get(context)
        ..getSliders()
        ..getNews()
        ..getProfile(),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait(
              [
                // WalletCubit.get(context).getWallet(),
                HomeCubit.get(context).getSliders(),
                HomeCubit.get(context).getNews(),
                HomeCubit.get(context).getProfile(),
              ],
            );
          },
          backgroundColor: AppColors.yellow2,
          color: AppColors.white,
          child: ListView(
            padding: EdgeInsets.all(12.sp),
            children: [


              // Row(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           SvgWidget(
              //             assetName: AppAssets.wallet,
              //             height: 20.h,
              //           ),
              //           SizedBox(
              //             height: 6.h,
              //           ),
              //           Text(
              //             LocaleKeys.balance.tr(),
              //             style: Theme.of(context)
              //                 .textTheme
              //                 .headlineSmall
              //                 ?.copyWith(
              //                   color: AppColors.yellow2,
              //                 ),
              //           ),
              //           Text(
              //             LocaleKeys.currentBalance.tr(),
              //             style: Theme.of(context)
              //                 .textTheme
              //                 .bodyMedium
              //                 ?.copyWith(
              //                   color: AppColors.textYellow,
              //                 ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     SizedBox(
              //       width: 12.w,
              //     ),
              //     BlocBuilder<WalletCubit, WalletState>(
              //       buildWhen: (previous, current) {
              //         return current is GetWalletSuccessState ||
              //             current is GetWalletErrorState ||
              //             current is GetWalletLoadingState;
              //       },
              //       builder: (context, state) {
              //         return
              //           Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               '${WalletCubit.get(context).walletDollar} \$',
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .headlineSmall
              //                   ?.copyWith(
              //                     color: AppColors.yellow2,
              //                 fontFamily: GoogleFonts.cairo().fontFamily, // Add this line
              //               ),
              //             ),
              //
              //             // WalletCubit.get(context).walletEgp<=0?const SizedBox ():Text(
              //             //   "${ Methods.removeTrailingZeros( WalletCubit.get(context).walletEgp)} LE",
              //             //   style: Theme.of(context).textTheme.headlineSmall,
              //             // ),
              //
              //           ],
              //         );
              //       },
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 18.h,
              // ),

/////////////////////////////////////////////////////////////////////////////////////////////////////////// slider
//                 BlocBuilder<HomeCubit, HomeState>( ///  ده القديمه بشمهندس جمعه عدلها
//                   buildWhen: (previous, current) {
//                     if (current is GetSlidersLoadingState ||
//                         current is GetSlidersSuccessState ||
//                         current is GetSlidersErrorState) {
//                       return true;
//                     } else {
//                       return false;
//                     }
//                   },
//                   builder: (context, state) {
//                     HomeCubit cubit = HomeCubit.get(context);
//                     return CarouselSlider(
//                       options: CarouselOptions(
//                         autoPlay: false,
//                         aspectRatio: 2.0,
//                         viewportFraction: 0.9,
//                         enlargeCenterPage: true,
//                         clipBehavior: Clip.none,
//                       ),
//                       items: List.generate(
//                          cubit.sliders.length,
//                         (index) => Visibility(
//                           visible: cubit.sliders.isNotEmpty &&
//                               state is GetSlidersSuccessState,
//                           replacement: ShimmerWidget(
//                             child: Container(
//                               width: double.infinity,
//                               height: 150.h,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 border: Border.all(
//                                   color: AppColors.yellowBorder,
//                                   width: 0.5.sp,
//                                   strokeAlign: BorderSide.strokeAlignInside,
//                                 ),
//                               ),
//                               clipBehavior: Clip.antiAliasWithSaveLayer,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 child: Image.network(
//                                   cubit.sliders[index].image ?? '',
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Padding(
//                                       padding: EdgeInsets.all(12.sp),
//                                       child: Image.asset(
//                                         AppAssets.logoPng,
//                                         fit: BoxFit.contain,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                           child: Container(
//                             width: double.infinity,
//                             height: 150.h,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12.r),
//                               border: Border.all(
//                                 color: AppColors.yellowBorder,
//                                 width: 1.sp,
//                                 strokeAlign: BorderSide.strokeAlignInside,
//                               ),
//                             ),
//                             clipBehavior: Clip.antiAliasWithSaveLayer,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12.r),
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   Image.network(
//                                     cubit.sliders[index].image ?? '',
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Padding(
//                                         padding: EdgeInsets.all(12.sp),
//                                         child: Image.asset(
//                                           AppAssets.logoPng,
//                                           fit: BoxFit.contain,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   Positioned.fill(
//                                     child: Material(
//                                       color: Colors.transparent,
//                                       child: InkWell(
//                                         onTap: () async {
//                                           Uri url = Uri.parse(
//                                               cubit.sliders[index].link ?? '');
//                                           bool can = await canLaunchUrl(url);
//                                           if (can) {
//                                             await launchUrl(url);
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
              BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) =>
                current is GetSlidersLoadingState ||
                    current is GetSlidersSuccessState ||
                    current is GetSlidersErrorState,
                builder: (context, state) {
                  final cubit = HomeCubit.get(context);

                  // Loading / Empty: show shimmer placeholder (حتى لو list فاضية)
                  if (state is GetSlidersLoadingState || cubit.sliders.isEmpty) {
                    return ShimmerWidget(
                      child: Container(
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
                          child: Image.asset(
                            AppAssets.logoPng,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  }

                  // Error state (اختياري تعرض مكانها Widget مناسب)
                  if (state is GetSlidersErrorState) {
                    return const SizedBox.shrink();
                  }

                  // Success
                  final sliders = cubit.sliders;

                  // ✅ لو عنصر واحد: عرض شاشة بدون سكرول
                  if (sliders.length == 1) {
                    final item = sliders.first;

                    return Container(
                      width: double.infinity,
                      height: 150.h,
                      margin: EdgeInsets.symmetric(horizontal: 12.w), // اختياري
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.yellowBorder,
                          width: 1.sp,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              item.image ?? '',
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
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final link = item.link ?? '';
                                    if (link.isEmpty) return;

                                    final url = Uri.tryParse(link);
                                    if (url == null) return;

                                    final can = await canLaunchUrl(url);
                                    if (can) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

//////////////////////////////////////////////////////////////////// // ✅ لو أكتر من عنصر: Carousel طبيعي
                  return CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: false,
                      aspectRatio: 2.0,
                      viewportFraction: 0.9,
                      enlargeCenterPage: true,
                      clipBehavior: Clip.none,
                    ),
                    items: List.generate(sliders.length, (index) {
                      final item = sliders[index];

                      return Container(
                        width: double.infinity,
                        height: 150.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.yellowBorder,
                            width: 1.sp,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                item.image ?? '',
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
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final link = item.link ?? '';
                                      if (link.isEmpty) return;

                                      final url = Uri.tryParse(link);
                                      if (url == null) return;

                                      final can = await canLaunchUrl(url);
                                      if (can) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              SizedBox(
                height: 12.h,
              ),



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     PreciousMetalsWidget
              const PreciousMetalsWidget(),

              SizedBox(
                height: 12.h,
              ),



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////// newa
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
                    LocaleKeys.news.tr(),
                    style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.yellow2,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              SizedBox(
                height: 100.h,
                child: BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) {
                    if (current is GetNewsLoadingState ||
                        current is GetNewsSuccessState ||
                        current is GetNewsErrorState) {
                      return true;
                    } else {
                      return false;
                    }
                  },
                  builder: (context, state) {
                    HomeCubit cubit = HomeCubit.get(context);
                    if (state is GetNewsLoadingState) {
                      return ListView.separated(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ShimmerWidget(
                            child: Container(
                              width: 120.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.yellowBorder,
                                  width: 1.w,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      AppAssets.newsImage,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigation.push(
                                              context,
                                              NewsScreen(
                                                newModel: cubit.news[index],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(
                          width: 12.w,
                        ),
                        itemCount: 5,
                      );
                    }
                    return ListView.separated(
                      clipBehavior: Clip.none,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.yellowBorder,
                              width: 1.w,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  cubit.news[index].image ?? '',
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
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigation.push(
                                          context,
                                          NewsScreen(
                                            newModel: cubit.news[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(
                        width: 12.w,
                      ),
                      itemCount: cubit.news.length,
                    );
                  },
                ),
              ),



              SizedBox(
                height: 33.h,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
/////////////////////////////////////////////////////////////////////////////////// home before wallet

//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: WalletCubit.get(context)..getWallet(),
//       child:
//       BlocProvider.value(
//         value: HomeCubit.get(context)
//           ..getSliders()
//           ..getNews()
//           ..getProfile(),
//         child: Scaffold(
//           backgroundColor: AppColors.transparent,
//           body: RefreshIndicator(
//             onRefresh: () async {
//               await Future.wait(
//                 [
//                   // WalletCubit.get(context).getWallet(),
//                   HomeCubit.get(context).getSliders(),
//                   HomeCubit.get(context).getNews(),
//                   HomeCubit.get(context).getProfile(),
//                 ],
//               );
//             },
//             backgroundColor: AppColors.yellow2,
//             color: AppColors.black,
//             child: ListView(
//               padding: EdgeInsets.all(12.sp),
//               children: [
//
//
//                 // Row(
//                 //   children: [
//                 //     Expanded(
//                 //       child: Column(
//                 //         crossAxisAlignment: CrossAxisAlignment.start,
//                 //         children: [
//                 //           SvgWidget(
//                 //             assetName: AppAssets.wallet,
//                 //             height: 20.h,
//                 //           ),
//                 //           SizedBox(
//                 //             height: 6.h,
//                 //           ),
//                 //           Text(
//                 //             LocaleKeys.balance.tr(),
//                 //             style: Theme.of(context)
//                 //                 .textTheme
//                 //                 .headlineSmall
//                 //                 ?.copyWith(
//                 //                   color: AppColors.yellow2,
//                 //                 ),
//                 //           ),
//                 //           Text(
//                 //             LocaleKeys.currentBalance.tr(),
//                 //             style: Theme.of(context)
//                 //                 .textTheme
//                 //                 .bodyMedium
//                 //                 ?.copyWith(
//                 //                   color: AppColors.textYellow,
//                 //                 ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //     SizedBox(
//                 //       width: 12.w,
//                 //     ),
//                 //     BlocBuilder<WalletCubit, WalletState>(
//                 //       buildWhen: (previous, current) {
//                 //         return current is GetWalletSuccessState ||
//                 //             current is GetWalletErrorState ||
//                 //             current is GetWalletLoadingState;
//                 //       },
//                 //       builder: (context, state) {
//                 //         return
//                 //           Column(
//                 //           crossAxisAlignment: CrossAxisAlignment.start,
//                 //           children: [
//                 //             Text(
//                 //               '${WalletCubit.get(context).walletDollar} \$',
//                 //               style: Theme.of(context)
//                 //                   .textTheme
//                 //                   .headlineSmall
//                 //                   ?.copyWith(
//                 //                     color: AppColors.yellow2,
//                 //                 fontFamily: GoogleFonts.cairo().fontFamily, // Add this line
//                 //               ),
//                 //             ),
//                 //
//                 //             // WalletCubit.get(context).walletEgp<=0?const SizedBox ():Text(
//                 //             //   "${ Methods.removeTrailingZeros( WalletCubit.get(context).walletEgp)} LE",
//                 //             //   style: Theme.of(context).textTheme.headlineSmall,
//                 //             // ),
//                 //
//                 //           ],
//                 //         );
//                 //       },
//                 //     ),
//                 //   ],
//                 // ),
//                 // SizedBox(
//                 //   height: 18.h,
//                 // ),
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////////// slider
// //                 BlocBuilder<HomeCubit, HomeState>( ///  ده القديمه بشمهندس جمعه عدلها
// //                   buildWhen: (previous, current) {
// //                     if (current is GetSlidersLoadingState ||
// //                         current is GetSlidersSuccessState ||
// //                         current is GetSlidersErrorState) {
// //                       return true;
// //                     } else {
// //                       return false;
// //                     }
// //                   },
// //                   builder: (context, state) {
// //                     HomeCubit cubit = HomeCubit.get(context);
// //                     return CarouselSlider(
// //                       options: CarouselOptions(
// //                         autoPlay: false,
// //                         aspectRatio: 2.0,
// //                         viewportFraction: 0.9,
// //                         enlargeCenterPage: true,
// //                         clipBehavior: Clip.none,
// //                       ),
// //                       items: List.generate(
// //                          cubit.sliders.length,
// //                         (index) => Visibility(
// //                           visible: cubit.sliders.isNotEmpty &&
// //                               state is GetSlidersSuccessState,
// //                           replacement: ShimmerWidget(
// //                             child: Container(
// //                               width: double.infinity,
// //                               height: 150.h,
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(12.r),
// //                                 border: Border.all(
// //                                   color: AppColors.yellowBorder,
// //                                   width: 0.5.sp,
// //                                   strokeAlign: BorderSide.strokeAlignInside,
// //                                 ),
// //                               ),
// //                               clipBehavior: Clip.antiAliasWithSaveLayer,
// //                               child: ClipRRect(
// //                                 borderRadius: BorderRadius.circular(12.r),
// //                                 child: Image.network(
// //                                   cubit.sliders[index].image ?? '',
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (context, error, stackTrace) {
// //                                     return Padding(
// //                                       padding: EdgeInsets.all(12.sp),
// //                                       child: Image.asset(
// //                                         AppAssets.logoPng,
// //                                         fit: BoxFit.contain,
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           child: Container(
// //                             width: double.infinity,
// //                             height: 150.h,
// //                             decoration: BoxDecoration(
// //                               borderRadius: BorderRadius.circular(12.r),
// //                               border: Border.all(
// //                                 color: AppColors.yellowBorder,
// //                                 width: 1.sp,
// //                                 strokeAlign: BorderSide.strokeAlignInside,
// //                               ),
// //                             ),
// //                             clipBehavior: Clip.antiAliasWithSaveLayer,
// //                             child: ClipRRect(
// //                               borderRadius: BorderRadius.circular(12.r),
// //                               child: Stack(
// //                                 fit: StackFit.expand,
// //                                 children: [
// //                                   Image.network(
// //                                     cubit.sliders[index].image ?? '',
// //                                     fit: BoxFit.cover,
// //                                     errorBuilder: (context, error, stackTrace) {
// //                                       return Padding(
// //                                         padding: EdgeInsets.all(12.sp),
// //                                         child: Image.asset(
// //                                           AppAssets.logoPng,
// //                                           fit: BoxFit.contain,
// //                                         ),
// //                                       );
// //                                     },
// //                                   ),
// //                                   Positioned.fill(
// //                                     child: Material(
// //                                       color: Colors.transparent,
// //                                       child: InkWell(
// //                                         onTap: () async {
// //                                           Uri url = Uri.parse(
// //                                               cubit.sliders[index].link ?? '');
// //                                           bool can = await canLaunchUrl(url);
// //                                           if (can) {
// //                                             await launchUrl(url);
// //                                           }
// //                                         },
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
//                 BlocBuilder<HomeCubit, HomeState>(
//                   buildWhen: (previous, current) =>
//                   current is GetSlidersLoadingState ||
//                       current is GetSlidersSuccessState ||
//                       current is GetSlidersErrorState,
//                   builder: (context, state) {
//                     final cubit = HomeCubit.get(context);
//
//                     // Loading / Empty: show shimmer placeholder (حتى لو list فاضية)
//                     if (state is GetSlidersLoadingState || cubit.sliders.isEmpty) {
//                       return ShimmerWidget(
//                         child: Container(
//                           width: double.infinity,
//                           height: 150.h,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(
//                               color: AppColors.yellowBorder,
//                               width: 0.5.sp,
//                               strokeAlign: BorderSide.strokeAlignInside,
//                             ),
//                           ),
//                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12.r),
//                             child: Image.asset(
//                               AppAssets.logoPng,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//
//                     // Error state (اختياري تعرض مكانها Widget مناسب)
//                     if (state is GetSlidersErrorState) {
//                       return const SizedBox.shrink();
//                     }
//
//                     // Success
//                     final sliders = cubit.sliders;
//
//                     // ✅ لو عنصر واحد: عرض شاشة بدون سكرول
//                     if (sliders.length == 1) {
//                       final item = sliders.first;
//
//                       return Container(
//                         width: double.infinity,
//                         height: 150.h,
//                         margin: EdgeInsets.symmetric(horizontal: 12.w), // اختياري
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(
//                             color: AppColors.yellowBorder,
//                             width: 1.sp,
//                             strokeAlign: BorderSide.strokeAlignInside,
//                           ),
//                         ),
//                         clipBehavior: Clip.antiAliasWithSaveLayer,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12.r),
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               Image.network(
//                                 item.image ?? '',
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Padding(
//                                     padding: EdgeInsets.all(12.sp),
//                                     child: Image.asset(
//                                       AppAssets.logoPng,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   );
//                                 },
//                               ),
//                               Positioned.fill(
//                                 child: Material(
//                                   color: Colors.transparent,
//                                   child: InkWell(
//                                     onTap: () async {
//                                       final link = item.link ?? '';
//                                       if (link.isEmpty) return;
//
//                                       final url = Uri.tryParse(link);
//                                       if (url == null) return;
//
//                                       final can = await canLaunchUrl(url);
//                                       if (can) {
//                                         await launchUrl(url, mode: LaunchMode.externalApplication);
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//
// //////////////////////////////////////////////////////////////////// // ✅ لو أكتر من عنصر: Carousel طبيعي
//                     return CarouselSlider(
//                       options: CarouselOptions(
//                         autoPlay: false,
//                         aspectRatio: 2.0,
//                         viewportFraction: 0.9,
//                         enlargeCenterPage: true,
//                         clipBehavior: Clip.none,
//                       ),
//                       items: List.generate(sliders.length, (index) {
//                         final item = sliders[index];
//
//                         return Container(
//                           width: double.infinity,
//                           height: 150.h,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(
//                               color: AppColors.yellowBorder,
//                               width: 1.sp,
//                               strokeAlign: BorderSide.strokeAlignInside,
//                             ),
//                           ),
//                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12.r),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 Image.network(
//                                   item.image ?? '',
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Padding(
//                                       padding: EdgeInsets.all(12.sp),
//                                       child: Image.asset(
//                                         AppAssets.logoPng,
//                                         fit: BoxFit.contain,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 Positioned.fill(
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       onTap: () async {
//                                         final link = item.link ?? '';
//                                         if (link.isEmpty) return;
//
//                                         final url = Uri.tryParse(link);
//                                         if (url == null) return;
//
//                                         final can = await canLaunchUrl(url);
//                                         if (can) {
//                                           await launchUrl(url, mode: LaunchMode.externalApplication);
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                     );
//                   },
//                 ),
//
//                 SizedBox(
//                   height: 12.h,
//                 ),
//
//
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     PreciousMetalsWidget
//                 PreciousMetalsWidget(),
//
//                 SizedBox(
//                   height: 12.h,
//                 ),
//
//
//
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// newa
//                 Row(
//                   children: [
//                     SvgWidget(
//                       assetName: AppAssets.news,
//                       height: 20.h,
//                     ),
//                     SizedBox(
//                       width: 12.w,
//                     ),
//                     Text(
//                       LocaleKeys.news.tr(),
//                       style:
//                       Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         color: AppColors.yellow2,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 12.h,
//                 ),
//                 SizedBox(
//                   height: 100.h,
//                   child: BlocBuilder<HomeCubit, HomeState>(
//                     buildWhen: (previous, current) {
//                       if (current is GetNewsLoadingState ||
//                           current is GetNewsSuccessState ||
//                           current is GetNewsErrorState) {
//                         return true;
//                       } else {
//                         return false;
//                       }
//                     },
//                     builder: (context, state) {
//                       HomeCubit cubit = HomeCubit.get(context);
//                       if (state is GetNewsLoadingState) {
//                         return ListView.separated(
//                           clipBehavior: Clip.none,
//                           scrollDirection: Axis.horizontal,
//                           itemBuilder: (context, index) {
//                             return ShimmerWidget(
//                               child: Container(
//                                 width: 120.w,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   border: Border.all(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                     strokeAlign: BorderSide.strokeAlignInside,
//                                   ),
//                                 ),
//                                 clipBehavior: Clip.antiAliasWithSaveLayer,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   child: Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       Image.asset(
//                                         AppAssets.newsImage,
//                                         fit: BoxFit.cover,
//                                       ),
//                                       Positioned.fill(
//                                         child: Material(
//                                           color: Colors.transparent,
//                                           child: InkWell(
//                                             onTap: () {
//                                               Navigation.push(
//                                                 context,
//                                                 NewsScreen(
//                                                   newModel: cubit.news[index],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                           separatorBuilder: (context, index) => SizedBox(
//                             width: 12.w,
//                           ),
//                           itemCount: 5,
//                         );
//                       }
//                       return ListView.separated(
//                         clipBehavior: Clip.none,
//                         scrollDirection: Axis.horizontal,
//                         itemBuilder: (context, index) {
//                           return Container(
//                             width: 120.w,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12.r),
//                               border: Border.all(
//                                 color: AppColors.yellowBorder,
//                                 width: 1.w,
//                                 strokeAlign: BorderSide.strokeAlignInside,
//                               ),
//                             ),
//                             clipBehavior: Clip.antiAliasWithSaveLayer,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12.r),
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   Image.network(
//                                     cubit.news[index].image ?? '',
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Padding(
//                                         padding: EdgeInsets.all(12.sp),
//                                         child: Image.asset(
//                                           AppAssets.logoPng,
//                                           fit: BoxFit.contain,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   Positioned.fill(
//                                     child: Material(
//                                       color: Colors.transparent,
//                                       child: InkWell(
//                                         onTap: () {
//                                           Navigation.push(
//                                             context,
//                                             NewsScreen(
//                                               newModel: cubit.news[index],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                         separatorBuilder: (context, index) => SizedBox(
//                           width: 12.w,
//                         ),
//                         itemCount: cubit.news.length,
//                       );
//                     },
//                   ),
//                 ),
//
//
//
//                 SizedBox(
//                   height: 33.h,
//                 ),
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
