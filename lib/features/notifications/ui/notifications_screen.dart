import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../cubit/notifications_cubit.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final notifications = cubit.notifications;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppTexts.notifications),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            actions: [
              if (notifications.isNotEmpty && cubit.unreadCount > 0)
                TextButton(
                  onPressed: () {
                    cubit.markAllAsRead();
                  },
                  child: Text(
                    AppTexts.markAllAsRead,
                    style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
                  ),
                ),
            ],
          ),
          body: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppTexts.noNotifications,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationItem(
                      notification: notification,
                      onTap: () {
                        if (!notification.isRead) {
                          cubit.markAsRead(notification.id);
                        }
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({required this.notification, required this.onTap});

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.accountApproved:
        return AppColors.success;
      case NotificationType.accountRejected:
        return AppColors.error;
      case NotificationType.underReview:
        return AppColors.warning;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.accountApproved:
        return Icons.check_circle;
      case NotificationType.accountRejected:
        return Icons.cancel;
      case NotificationType.underReview:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor();
    final icon = _getNotificationIcon();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surfaceVariant
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : color.withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  //SizedBox(height: 8.h),
                  // Text(
                  //   _formatDate(notification.createdAt),
                  //   style: TextStyle(
                  //     color: AppColors.textTertiary,
                  //     fontSize: 12.sp,
                  //   ),
                  // ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return AppTexts.now;
        }
        return AppTexts.minutesAgo.replaceAll(
          '%minutes%',
          '${difference.inMinutes}',
        );
      }
      return AppTexts.hoursAgo.replaceAll('%hours%', '${difference.inHours}');
    } else if (difference.inDays == 1) {
      return AppTexts.yesterday;
    } else if (difference.inDays < 7) {
      return AppTexts.daysAgo.replaceAll('%days%', '${difference.inDays}');
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
