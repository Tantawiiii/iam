import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/product_details_cubit.dart';
import '../models/product_model.dart';
import '../widgets/product_image_slider.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../home/services/products_service.dart';
import '../../../core/services/storage_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final bool isForSale;
  final String? productNumber;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.isForSale = false,
    this.productNumber,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              di.sl<ProductDetailsCubit>()..getProductDetails(widget.productId),
        ),
      ],
      child: BlocListener<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          if (state is ProductDetailsSuccess) {
            if (_selectedColor == null &&
                state.response.data.colorList.isNotEmpty) {
              setState(() {
                _selectedColor = state.response.data.colorList.first;
              });
            }
            // تحديث السلة عند فتح التفاصيل عشان الكمية اللي اختارها من الهوم تظهر
            final storageService = di.sl<StorageService>();
            final token = storageService.getToken();
            if (token != null && token.isNotEmpty) {
              context.read<CartCubit>().getCart();
            }
          }
          if (state is AddToCartSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AddToCartFailure) {
            print(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AddToCartSuccess) {
            final storageService = di.sl<StorageService>();
            final token = storageService.getToken();
            final hasToken = token != null && token.isNotEmpty;
            if (hasToken) {
              context.read<CartCubit>().getCart();
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.blackTextColor,
                size: 24.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
            builder: (context, state) {
              if (state is ProductDetailsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state is ProductDetailsFailure) {
                print(state.message);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: AppColors.greyTextColor,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductDetailsCubit>().getProductDetails(
                            widget.productId,
                          );
                        },
                        child: Text(AppTexts.retry),
                      ),
                    ],
                  ),
                );
              }

              ProductModel? product;
              if (state is ProductDetailsSuccess) {
                product = state.response.data;
              } else if (state is AddToCartSuccess ||
                  state is AddToCartFailure ||
                  state is AddToCartLoading) {
                final cubit = context.read<ProductDetailsCubit>();
                product = cubit.cachedProductDetails?.data;
              }

              if (product != null) {
                final currentProduct = product;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImageSlider(
                        image: currentProduct.image,
                        linkVideo: currentProduct.linkVideo,
                        gallery: currentProduct.gallery,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentProduct.name,
                              style: TextStyle(
                                color: AppColors.blackTextColor,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 8.h,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${currentProduct.price} ${currentProduct.currency}',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentProduct.oldPrice,
                                  style: TextStyle(
                                    color: AppColors.greyTextColor,
                                    fontSize: 16.sp,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    '${currentProduct.discount}% ${AppTexts.off}',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < currentProduct.averageRating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20.sp,
                                  );
                                }),
                                SizedBox(width: 8.w),
                                Text(
                                  '${currentProduct.averageRating.toStringAsFixed(1)} (${currentProduct.reviewsCount} ${AppTexts.reviewsCountLabel})',
                                  style: TextStyle(
                                    color: AppColors.greyTextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            Text(
                              AppTexts.description,
                              style: TextStyle(
                                color: AppColors.blackTextColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              currentProduct.description,
                              style: TextStyle(
                                color: AppColors.greyTextColor,
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            if (currentProduct.type.isNotEmpty ||
                                currentProduct.colorList.isNotEmpty ||
                                (currentProduct.brand != null &&
                                    currentProduct.brand!.isNotEmpty) ||
                                currentProduct.quantity > 0) ...[
                              Text(
                                AppTexts.productDetails,
                                style: TextStyle(
                                  color: AppColors.blackTextColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              if (currentProduct.brand != null &&
                                  currentProduct.brand!.isNotEmpty)
                                _buildDetailRow(
                                  AppTexts.brand,
                                  currentProduct.brand!,
                                ),
                              if (currentProduct.type.isNotEmpty)
                                _buildDetailRow(
                                  AppTexts.type,
                                  currentProduct.type,
                                ),
                              if (currentProduct.quantity > 0)
                                _buildDetailRow(
                                  AppTexts.quantityAvailable,
                                  currentProduct.quantity.toString(),
                                ),
                              if ((widget.productNumber != null &&
                                      widget.productNumber!.isNotEmpty) ||
                                  currentProduct.productNumber.isNotEmpty)
                                _buildDetailRow(
                                  AppTexts.productNumber,
                                  (widget.productNumber != null &&
                                          widget.productNumber!.isNotEmpty)
                                      ? widget.productNumber!
                                      : currentProduct.productNumber,
                                ),
                              SizedBox(height: 24.h),
                            ],
                            _buildConfidenceSection(currentProduct),
                            SizedBox(height: 24.h),
                             if (!widget.isForSale)
                              BlocBuilder<CartCubit, CartState>(
                                builder: (context, cartState) {
                                  if (currentProduct.colorList.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildColorRow(
                                          context,
                                          currentProduct,
                                          cartState,
                                        ),
                                        SizedBox(height: 24.h),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            if (!widget.isForSale)
                              BlocBuilder<CartCubit, CartState>(
                                builder: (context, cartState) {
                                  int cartQuantity = 0;
                                  if (cartState is CartSuccess) {
                                    try {
                                      final data = cartState.response.data;
                                      final itemsForProduct = data
                                          .where((item) =>
                                              item.cardId ==
                                              currentProduct.id)
                                          .toList();
                                      if (itemsForProduct.isEmpty) {
                                        cartQuantity = 0;
                                      } else if (currentProduct
                                          .colorList.isNotEmpty) {
                                        // منتج فيه ألوان: نطابق حسب اللون المختار (أو أول لون لو لسه مش متحدد)
                                        final effectiveColor = _selectedColor ??
                                            currentProduct.colorList.first;
                                        final match = itemsForProduct
                                            .where((item) =>
                                                (item.color ?? '') ==
                                                effectiveColor)
                                            .toList();
                                        if (match.isNotEmpty) {
                                          cartQuantity = match.first.quantity;
                                        } else {
                                          // لو اللون المختار مش في السلة، نعرض مجموع الكميات أو أول صنف
                                          cartQuantity =
                                              itemsForProduct.first.quantity;
                                        }
                                      } else {
                                        // منتج بدون ألوان: أول آيتيم بنفس card_id
                                        cartQuantity =
                                            itemsForProduct.first.quantity;
                                      }
                                    } catch (e) {
                                      cartQuantity = 0;
                                    }
                                  }

                                  if (cartQuantity > 0) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: AppColors.primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppTexts.inCart,
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              _buildQuantityButton(
                                                context: context,
                                                icon: Icons.remove,
                                                onTap: () {
                                                  _updateQuantity(
                                                    context,
                                                    currentProduct.id,
                                                    'minus',
                                                  );
                                                },
                                              ),
                                              SizedBox(width: 16.w),
                                              Text(
                                                cartQuantity.toString(),
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                              _buildQuantityButton(
                                                context: context,
                                                icon: Icons.add,
                                                onTap: () {
                                                  _updateQuantity(
                                                    context,
                                                    currentProduct.id,
                                                    'plus',
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return BlocBuilder<
                                    ProductDetailsCubit,
                                    ProductDetailsState
                                  >(
                                    builder: (context, state) {
                                      final isLoading =
                                          state is AddToCartLoading;
                                      return PrimaryButton(
                                        title: isLoading
                                            ? AppTexts.addingToCart
                                            : AppTexts.addToCart,
                                        onPressed: isLoading
                                            ? () {}
                                            : () {
                                                context
                                                    .read<ProductDetailsCubit>()
                                                    .addToCart(
                                                      productId:
                                                          currentProduct.id,
                                                      color: _selectedColor,
                                                    );
                                              },
                                      );
                                    },
                                  );
                                },
                              ),
                            SizedBox(height: 16.h),
                            if (currentProduct.reviews.isNotEmpty) ...[
                              Text(
                                AppTexts.reviewsTitle,
                                style: TextStyle(
                                  color: AppColors.blackTextColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentProduct.reviews.where((r) => r.comment.trim().isNotEmpty).length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 6.h),
                                itemBuilder: (context, index) {
                                  final review = currentProduct.reviews
                                      .where((r) => r.comment.trim().isNotEmpty)
                                      .toList()[index];
                                  return Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: AppColors.overlayColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                review.userName.isNotEmpty
                                                    ? review.userName
                                                    : AppTexts.anonymous,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.blackTextColor,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Row(
                                              children: List.generate(5, (
                                                star,
                                              ) {
                                                return Icon(
                                                  star < review.rating.floor()
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16.sp,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        if (review.comment.isNotEmpty) ...[
                                          SizedBox(height: 8.h),
                                          Text(
                                            review.comment,
                                            style: TextStyle(
                                              color: AppColors.greyTextColor,
                                              fontSize: 14.sp,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                        if (review.createdAt.isNotEmpty) ...[
                                          SizedBox(height: 8.h),
                                          Text(
                                            review.createdAt,
                                            style: TextStyle(
                                              color: AppColors.greyTextColor,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 24.h),
                            ],
                            OutlinedButton.icon(
                              onPressed: () async {
                                final storageService = di.sl<StorageService>();
                                final token = storageService.getToken();
                                final hasToken =
                                    token != null && token.isNotEmpty;

                                if (!hasToken) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppTexts.pleaseLoginFirst,
                                      ),
                                      action: SnackBarAction(
                                        label: AppTexts.login,
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.login,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final writtenReviewsCount = currentProduct
                                    .reviews
                                    .where((r) => r.comment.trim().isNotEmpty)
                                    .length;
                                final canWriteTextReview =
                                    writtenReviewsCount < 5;

                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.addReview,
                                  arguments: {
                                    'productId': currentProduct.id,
                                    'canWriteTextReview': canWriteTextReview,
                                  },
                                );
                                if (result == true) {
                                  if (context.mounted) {
                                    context
                                        .read<ProductDetailsCubit>()
                                        .getProductDetails(currentProduct.id);
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.rate_review,
                                size: 18.sp,
                                color: AppColors.primaryColor,
                              ),
                              label: Text(
                                AppTexts.writeAReview,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50.h),
                                side: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceSection(ProductModel product) {
    final items = <String>[
      AppTexts.secureTransaction,
      AppTexts.safeDelivery,
      AppTexts.returnIn15Days,
    ];

    if (product.freeDelivery) {
      items.add(AppTexts.freeDelivery);
    }
    if (product.oneYearWarranty) {
      items.add(AppTexts.oneYearWarranty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.shopWithConfidence,
          style: TextStyle(
            color: AppColors.blackTextColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map(_buildConfidenceChip).toList(),
        ),
      ],
    );
  }

  Widget _buildConfidenceChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.primaryColor,
            size: 18.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blackTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  void _updateQuantity(
    BuildContext context,
    int productId,
    String method,
  ) async {
    final productsService = di.sl<ProductsService>();
    try {
      await productsService.addToCart(
        productId: productId,
        method: method,
        color: _selectedColor,
      );
      if (context.mounted) {
        context.read<CartCubit>().getCart();
        context.read<ProductDetailsCubit>().getProductDetails(productId);
      }
    } catch (e) {
      if (context.mounted) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTexts.failedToUpdateCart}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildColorRow(BuildContext context, ProductModel product, CartState cartState) {
    final colors = product.colorList;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              '${AppTexts.color}:',
              style: TextStyle(
                color: AppColors.greyTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: colors.map((colorName) {
                final isSelected = _selectedColor == colorName;
                return GestureDetector(
                  onTap: () {
                    if (isSelected) return;
                    
                    setState(() {
                      _selectedColor = colorName;
                    });

                    // If already in cart, update color immediately
                    if (cartState is CartSuccess) {
                      final isInCart = cartState.response.data.any(
                        (item) => item.cardId == product.id,
                      );
                      if (isInCart) {
                        _updateQuantity(context, product.id, 'add');
                      }
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.primaryColor.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      colorName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.blackTextColor,
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.greyTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.blackTextColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
