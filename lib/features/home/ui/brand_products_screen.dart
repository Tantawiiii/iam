import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../cubit/brand_products_cubit.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../widgets/product_grid_card.dart';

class BrandProductsScreen extends StatelessWidget {
  final int brandId;
  final String brandName;

  const BrandProductsScreen({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              di.sl<BrandProductsCubit>()..getBrandById(brandId),
        ),
        BlocProvider(
          create: (context) {
            final cubit = di.sl<FavoritesCubit>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cubit.getFavorites();
            });
            return cubit;
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(brandName),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<BrandProductsCubit, BrandProductsState>(
          builder: (context, state) {
            if (state is BrandProductsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            if (state is BrandProductsFailure) {
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
                        context.read<BrandProductsCubit>().getBrandById(
                          brandId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is BrandProductsSuccess) {
              final products = state.response.data.products
                  .where((product) => product.active)
                  .toList();

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.greyTextColor,
                        size: 48.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No products available',
                        style: TextStyle(
                          color: AppColors.greyTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favoritesState) {

                        bool isFavorite = false;
                        if (favoritesState is FavoritesSuccess) {
                          isFavorite = favoritesState.response.data.any(
                            (fav) => fav.card.id == product.id,
                          );
                        }

                        return ProductGridCard(
                          product: product,
                          isFavorite: isFavorite,
                          onFavoriteTap: () {
                            context.read<FavoritesCubit>().toggleFavorite(
                              cardId: product.id,
                              method: isFavorite ? 'delete' : 'add',
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

