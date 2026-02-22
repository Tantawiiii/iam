import 'dart:async';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/offers_cubit.dart';
import '../models/offer_model.dart';

class OffersSlider extends StatefulWidget {
  const OffersSlider({super.key});

  @override
  State<OffersSlider> createState() => _OffersSliderState();
}

class _OffersSliderState extends State<OffersSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  int _offerCount = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int itemCount) {
    _autoScrollTimer?.cancel();
    if (itemCount <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }

      final nextPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        if (state is OffersInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<OffersCubit>().getOffers();
            }
          });
          return _buildLoadingShimmer();
        }

        if (state is OffersLoading) {
          return _buildLoadingShimmer();
        }

        if (state is OffersFailure) {
          return const SizedBox.shrink();
        }

        if (state is OffersSuccess) {
          final offers = state.response.data;

          if (offers.isEmpty) {
            return const SizedBox.shrink();
          }

          if (_offerCount != offers.length) {
            _offerCount = offers.length;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoScroll(offers.length);
            });
          }

          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                height: 240.h,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return _buildOfferBanner(offer);
                  },
                ),
              ),
              if (offers.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    offers.length,
                    (index) => _buildPageIndicator(index == _currentPage),
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOfferBanner(OfferModel offer) {
    return Bounce(
      onTap: offer.productId != null
          ? () {
              Navigator.pushNamed(
                context,
                AppRoutes.productDetails,
                arguments: {'productId': offer.productId},
              );
            }
          : null,
      child: ClipRRect(
        child: CachedNetworkImage(
          imageUrl: offer.avatar,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: AppColors.overlayColor,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.overlayColor,
            child: Icon(
              Icons.image_outlined,
              color: AppColors.greyTextColor,
              size: 40.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryColor
            : AppColors.greyTextColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      height: 200.h,
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceVariant,
        highlightColor: AppColors.background,
        period: const Duration(milliseconds: 1200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }
}
