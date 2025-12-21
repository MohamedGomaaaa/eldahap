import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/components/svg_widget.dart';
import 'package:official_gold/view/screen/home/app_bar/app_bar_widget.dart';
import 'package:official_gold/view_model/utils/assets.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/cubit/home_cubit/home_cubit.dart';
import '../../../../../view_model/utils/colors.dart';

class ActivateTheAccountScreen extends StatefulWidget {
  const ActivateTheAccountScreen({super.key});

  @override
  State<ActivateTheAccountScreen> createState() => _ActivateTheAccountScreenState();
}

class _ActivateTheAccountScreenState extends State<ActivateTheAccountScreen> {
  File? nationalIdFront;
  File? nationalIdBack;

  String? nationalIdFrontUrl;
  String? nationalIdBackUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImages();
  }

  Future<void> _loadProfileImages() async {
    final cubit = HomeCubit.get(context);
    final profile = await cubit.getProfile();

    setState(() {
      nationalIdFrontUrl = cubit.user.value.nationalIdFront; // API field
      nationalIdBackUrl = cubit.user.value.nationalIdBack;   // API field
    });
  }

  Future<void> pickImage({required bool isFront}) async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.darkGreen),
                title: const Text("Camera"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: AppColors.darkGreen),
                title: const Text("Gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source, imageQuality: 85);

    if (image != null) {
      setState(() {
        if (isFront) {
          nationalIdFront = File(image.path);
          nationalIdFrontUrl = null;
        } else {
          nationalIdBack = File(image.path);
          nationalIdBackUrl = null;
        }
      });
    }
  }

  Future<void> saveProfile() async {
    final cubit = HomeCubit.get(context);
   await cubit.updateProfileNationalId(nationalIdFront,nationalIdBack);
  }

  Widget _buildImagePreview({
    required File? fileImage,
    required String? networkUrl,
    required String placeholderText,
    required VoidCallback onTap,
    required String svgAsset,
  }) {
    return Material(
      color: AppColors.backgroundGrey,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.yellowBorder, width: 0.5.w),
          ),
          child: Column(
            children: [
              Text(
                placeholderText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  SvgWidget(assetName: svgAsset, color: AppColors.textYellow),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: fileImage != null
                        ? Image.file(fileImage, height: 125.h, fit: BoxFit.fill)
                        : (networkUrl != null
                        ? CachedNetworkImage(
                      imageUrl: networkUrl,
                      height: 125.h,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: AppColors.textYellow),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                    )
                        :
                    // networkUrl == null?
                    // Text(
                    //   placeholderText,
                    //   style: Theme.of(context).textTheme.bodyLarge,
                    // ):
                    const SizedBox.shrink()
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: HomeCubit.get(context)..clearControllers(),
      child: Scaffold(
        body: GradientWidget(
          child: Column(
            children: [
              const AppBarCustom(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(12.sp),
                  children: [
                    SizedBox(height: 12.h),
                    Text(
                      LocaleKeys.activateTheAccount.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 6.h),
                    const Divider(color: AppColors.textYellow),
                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.uploadTheFollowingFiles.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.white),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.pleaseUploadAHighQualityImage.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.red),
                    ),
                    SizedBox(height: 8.h),

                    // Front ID
                    _buildImagePreview(
                      fileImage: nationalIdFront,
                      networkUrl: nationalIdFrontUrl,
                      placeholderText: LocaleKeys.uploadOfIDCardFront.tr(),
                      onTap: () => pickImage(isFront: true),
                      svgAsset: AppAssets.myAccount,
                    ),
                    SizedBox(height: 6.h),

                    SizedBox(height: 8.h),

                    // Back ID
                    _buildImagePreview(
                      fileImage: nationalIdBack,
                      networkUrl: nationalIdBackUrl,
                      placeholderText: LocaleKeys.uploadOfIDCardBack.tr(),
                      onTap: () => pickImage(isFront: false),
                      svgAsset: AppAssets.cardID,
                    ),

                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.dataAndPhotosWillBeReviewedAsSoonAsPossible.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                    ),
                    Text(
                      '.. ${LocaleKeys.thankYou.tr()}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.sp),
                child: SafeArea(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      final isLoading = state is GetProfileLoadingState;

                      return SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null // disable button while loading
                              : () async {
                            if ((nationalIdFront == null && nationalIdFrontUrl == null) ||
                                (nationalIdBack == null && nationalIdBackUrl == null)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("pleaseSelectBothImages")),
                              );
                              return;
                            }
                            await saveProfile();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            LocaleKeys.save.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.white),
                          ),
                        ),
                      );
                    },
                  )
                  ,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
