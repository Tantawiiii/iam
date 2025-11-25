import 'package:bounce/bounce.dart';
import 'package:iam/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../auth/models/user_model.dart';
import '../../notifications/cubit/notifications_cubit.dart';
import '../../notifications/ui/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = di.sl<StorageService>();
    return BlocProvider(
      create: (context) => di.sl<NotificationsCubit>(),
      child: ValueListenableBuilder<UserModel?>(
        valueListenable: storageService.userNotifier,
        builder: (context, user, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (user != null) {
              context.read<NotificationsCubit>().updateNotificationsFromUser(
                user,
              );
            }
          });

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    final unreadCount = context
                        .read<NotificationsCubit>()
                        .unreadCount;
                    return Bounce(
                      onTap: () {
                        final notificationsCubit = context
                            .read<NotificationsCubit>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: notificationsCubit,
                              child: const NotificationsScreen(),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: ClipOval(
                              child: Image.asset(
                                AppAssets.newLogoLight,
                                height: 60.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: -4.w,
                              top: -4.h,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 18.w,
                                  minHeight: 18.w,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    SizedBox(width: 12.w),
                    // User Profile
                    Bounce(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.userInfo);
                      },
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                user?.name ?? '',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'ID: ${user?.id.toString() ?? ''}',
                                style: TextStyle(
                                  color: AppColors.greyTextColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: AppColors.textFieldBorderColor,
                            backgroundImage:
                                (user?.avatar != null &&
                                    user!.avatar!.isNotEmpty)
                                ? NetworkImage(user.avatar!)
                                : null,
                            child:
                                (user?.avatar == null || user!.avatar!.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    color: AppColors.greyTextColor,
                                    size: 20.sp,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
