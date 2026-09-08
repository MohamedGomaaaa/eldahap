// import '../../../view_model/cubit/static_page_cubit/static_page_states.dart';
// import '../../../view_model/cubit/static_page_cubit/static_page_cubit.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../services/app_service/app_service.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../model/static_page.dart';
// import '../../../utils/app_color.dart';
// import 'package:flutter/material.dart';
//
// class OldStaticPageScreen extends StatelessWidget {
//   final int pageId;
//
//   const OldStaticPageScreen({required this.pageId, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PageCubit(ApiService())..loadPage(pageId),
//       child: SinglePageView(),
//     );
//   }
// }
//
// class SinglePageView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const SizedBox(),
//       ),
//       body: BlocBuilder<PageCubit, PageState>(
//         builder: (context, state) {
//           if (state is PageLoading) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
//               ),
//             );
//           }
//
//           if (state is PageError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     color: AppColors.red,
//                     size: 60.sp,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     state.message,
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: 16.sp,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20.h),
//                   ElevatedButton(
//                     onPressed: () {
//                       context
//                           .read<PageCubit>()
//                           .loadPage(1); // Retry with same ID
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.yellow,
//                       foregroundColor: AppColors.black,
//                     ),
//                     child: Text(
//                       'Retry',
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16.sp,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (state is PageLoaded) {
//             return PageContent(page: state.page);
//           }
//
//           return const Center(
//             child: Text(
//               'Welcome',
//               style: TextStyle(color: AppColors.white),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class PageContent extends StatelessWidget {
//   final StaticPageModel page;
//
//   const PageContent({required this.page, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.all(12.sp),
//       children: [
//         // Title Row with Icon
//         Row(
//           children: [
//             Icon(
//               Icons.article_outlined,
//               color: AppColors.yellow,
//               size: 20.h,
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(
//                 page.title,
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       color: AppColors.yellow,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 20.h),
//
//         // Image Carousel
//         CarouselSlider(
//           options: CarouselOptions(
//             autoPlay: true,
//             aspectRatio: 2.0,
//             viewportFraction: 0.9,
//             enlargeCenterPage: true,
//             clipBehavior: Clip.none,
//             autoPlayInterval: Duration(seconds: 3),
//             autoPlayAnimationDuration: Duration(milliseconds: 800),
//             autoPlayCurve: Curves.fastOutSlowIn,
//           ),
//           items: [
//             Container(
//               width: double.infinity,
//               height: 150.h,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(
//                   color: AppColors.yellowBorder,
//                   width: 0.5.sp,
//                   strokeAlign: BorderSide.strokeAlignInside,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.yellow.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               clipBehavior: Clip.antiAliasWithSaveLayer,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: CachedNetworkImage(
//                   imageUrl: page.image,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     color: AppColors.grey,
//                     child: const Center(
//                       child: CircularProgressIndicator(
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(AppColors.yellow),
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: AppColors.grey,
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.broken_image_outlined,
//                             color: AppColors.lightGrey,
//                             size: 40.sp,
//                           ),
//                           SizedBox(height: 8.h),
//                           Text(
//                             'Image not available',
//                             style: TextStyle(
//                               color: AppColors.lightGrey,
//                               fontSize: 12.sp,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 20.h),
//
//         // Content
//         Container(
//           padding: EdgeInsets.all(16.sp),
//           decoration: BoxDecoration(
//             color: AppColors.backgroundGrey,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 0.5.sp,
//             ),
//           ),
//           child: Text(
//             page.content,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   color: AppColors.yellow,
//                   height: 1.6,
//                   fontSize: 16.sp,
//                 ),
//           ),
//         ),
//
//         SizedBox(height: 20.h),
//
//         // Status Indicator
//         // if (page.publish == 1)
//         //   Container(
//         //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         //     decoration: BoxDecoration(
//         //       color: AppColors.green.withOpacity(0.1),
//         //       borderRadius: BorderRadius.circular(20.r),
//         //       border: Border.all(color: AppColors.green, width: 1),
//         //     ),
//         //     child: Row(
//         //       mainAxisSize: MainAxisSize.min,
//         //       children: [
//         //         Icon(
//         //           Icons.check_circle,
//         //           color: AppColors.green,
//         //           size: 16.sp,
//         //         ),
//         //         SizedBox(width: 8.w),
//         //         Text(
//         //           'Published',
//         //           style: TextStyle(
//         //             color: AppColors.green,
//         //             fontSize: 12.sp,
//         //             fontWeight: FontWeight.w500,
//         //           ),
//         //         ),
//         //       ],
//         //     ),
//         //   ),
//       ],
//     );
//   }
// }
