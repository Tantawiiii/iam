import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constant/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final String currentPrice;
  final String originalPrice;
  final String discount;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final int? cartQuantity;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;
  final VoidCallback? onIncreaseQuantity;

  const ProductCard({
    super.key,
    required this.title,
    required this.description,
    required this.currentPrice,
    required this.originalPrice,
    required this.discount,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.cartQuantity,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.onIncreaseQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: Container(
      width: 180.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 150.h,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                          fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              color: AppColors.textFieldBorderColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
              if (onFavoriteTap != null)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Bounce(
                    onTap: () {
                      if (onFavoriteTap != null) {
                        onFavoriteTap!();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        //gradient: AppColors.glassGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
            Flexible(
              child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.blackTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                  SizedBox(height: 4.h),
                Wrap(
                    spacing: 6.w,
                    runSpacing: 3.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        currentPrice,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),

                      ),
                    ),
                    Text(
                      originalPrice,
                      style: TextStyle(
                        color: AppColors.greyTextColor,
                        fontSize: 12.sp,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '$discount Off',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                  SizedBox(height: 4.h),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 14.sp,
                      );
                    }),
                    SizedBox(width: 4.w),
                    Text(
                      reviewCount.toString(),
                      style: TextStyle(
                        color: AppColors.greyTextColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                if (cartQuantity != null && cartQuantity! > 0) ...[
                    SizedBox(height: 6.h),
                  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onRemoveFromCart,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            cartQuantity.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: cartQuantity != null && cartQuantity! > 0
                              ? onIncreaseQuantity
                              : onAddToCart,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16.sp,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (onAddToCart != null) ...[
                    SizedBox(height: 6.h),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 18.sp,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.greyTextColor,
        size: 40.sp,
      ),
    );
  }
}
