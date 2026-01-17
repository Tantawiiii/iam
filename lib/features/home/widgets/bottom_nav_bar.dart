import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/localization/language_cubit.dart';
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
    context.watch<LanguageCubit>();
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            selectedIndex == 0 ? Icons.favorite : Icons.favorite_border,
            size: 24.r,
          ),
          label: AppTexts.favorites,
        ),
        BottomNavigationBarItem(
          icon: BlocBuilder<CartCubit, CartState>(
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
                isSelected: selectedIndex == 1,
                count: itemCount,
              );
            },
          ),
          label: AppTexts.cart,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            selectedIndex == 2 ? Icons.home : Icons.home_outlined,
            size: 24.r,
          ),
          label: AppTexts.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: 24.r),
          label: AppTexts.search,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            selectedIndex == 4 ? Icons.settings : Icons.settings_outlined,
            size: 24.r,
          ),
          label: AppTexts.settings,
        ),
      ],
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final int count;

  const _NavItemWithBadge({
    required this.icon,
    required this.isSelected,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = count > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24.r),
        if (showBadge)
          Positioned(
            right: -6.w,
            top: -6.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.background, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 8,
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
