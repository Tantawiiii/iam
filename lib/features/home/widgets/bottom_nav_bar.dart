import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../cart/cubit/cart_cubit.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      onTap: onTap,
      backgroundColor: Colors.white.withOpacity(0.9),
      color: Colors.white,
      buttonBackgroundColor: AppColors.primary,
      height: (75.h).clamp(0.0, 75.0),
      animationDuration: const Duration(milliseconds: 400),
      items: [
        Icon(
          Icons.favorite_border,
          color: selectedIndex == 0
              ? AppColors.white
              : AppColors.textSecondary,
          size: 26.r,
        ),
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            int itemCount = 0;
            if (state is CartSuccess) {
              itemCount = state.response.data.fold<int>(
                0,
                (total, item) => total + item.quantity,
              );
            }
            return _NavItemWithBadge(
              icon: Icons.shopping_cart,
              count: itemCount,
              isSelected: selectedIndex == 1,
            );
          },
        ),
        Icon(
          Icons.home,
          color: selectedIndex == 2
              ? AppColors.white
              : AppColors.textSecondary,
          size: 28.r,
        ),
        Icon(
          Icons.search,
          color: selectedIndex == 3
              ? AppColors.white
              : AppColors.textSecondary,
          size: 26.r,
        ),
        Icon(
          Icons.settings,
          color: selectedIndex == 4
              ? AppColors.white
              : AppColors.textSecondary,
          size: 26.r,
        ),
      ],
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isSelected;

  const _NavItemWithBadge({
    required this.icon,
    required this.count,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = count > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
          size: 24.r,
        ),
        if (showBadge)
          Positioned(
            right: -6.w,
            top: -6.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
