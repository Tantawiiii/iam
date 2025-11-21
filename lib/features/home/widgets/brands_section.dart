import 'package:bounce/bounce.dart';
import 'package:iam/core/constant/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/brands_cubit.dart';
import '../models/brand_model.dart';
import 'brand_shimmer_loading.dart';

class BrandsSection extends StatefulWidget {
  const BrandsSection({super.key});

  @override
  State<BrandsSection> createState() => _BrandsSectionState();
}

class _BrandsSectionState extends State<BrandsSection> {
  @override
  void initState() {
    super.initState();
    context.read<BrandsCubit>().getBrands();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTexts.allBrands,
                style: TextStyle(
                  color: AppColors.blackTextColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.textOnPrimary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        BlocBuilder<BrandsCubit, BrandsState>(
          builder: (context, state) {
            if (state is BrandsLoading) {
              return const BrandShimmerLoading();
            }

            if (state is BrandsFailure) {
              return SizedBox(
                height: 140.h,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
                      SizedBox(height: 8.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: AppColors.greyTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is BrandsSuccess) {
              final brands = state.response.data
                  .where((brand) => brand.active)
                  .toList();

              if (brands.isEmpty) {
                return SizedBox(
                  height: 140.h,
                  child: Center(
                    child: Text(
                      AppTexts.noBrandsAvailable,
                      style: TextStyle(
                        color: AppColors.greyTextColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 140.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return _buildBrandItem(brand, index);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBrandItem(BrandModel brand, int index) {
    final gradients = [
      AppColors.primaryGradient,
      AppColors.secondaryGradient,
      AppColors.accentGradient,
      AppColors.purpleGradient,
      AppColors.horizontalGradient,
    ];
    final gradient = gradients[index % gradients.length];

    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Bounce(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.brandProducts,
            arguments: {'brandId': brand.id, 'brandName': brand.name},
          );
        },
        child: Container(
          width: 120.w,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowGlow.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: brand.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: CachedNetworkImage(
                                imageUrl: brand.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.textOnPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.branding_watermark,
                                  color: AppColors.textOnPrimary,
                                  size: 40.sp,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.branding_watermark,
                              color: AppColors.textOnPrimary,
                              size: 40.sp,
                            ),
                    ),
                    SizedBox(height: 8.h),
                    Flexible(
                      child: Text(
                        brand.name,
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
