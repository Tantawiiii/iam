import 'package:bloc/bloc.dart';
import '../models/notification_model.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/constant/app_texts.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial());

  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void updateNotificationsFromUser(UserModel? user) {
    if (user == null) {
      _notifications = [];
      emit(NotificationsLoaded(_notifications));
      return;
    }

    _notifications = [];

    final hasUploadedDocuments =
        user.idImage != null ||
        user.bankStatementImage != null ||
        user.invoiceImage != null;

    if (hasUploadedDocuments && !user.active && user.isRefused != true) {
      _notifications.add(
        NotificationModel(
          id: 'review_${user.id}',
          title: AppTexts.accountUnderReviewTitle,
          message: AppTexts.accountUnderReview,
          createdAt: DateTime.now(),
          type: NotificationType.underReview,
        ),
      );
    }

    if (user.active) {
      _notifications.add(
        NotificationModel(
          id: 'approved_${user.id}',
          title: AppTexts.accountApprovedTitle,
          message: AppTexts.accountApprovedMessage,
          createdAt: DateTime.now(),
          type: NotificationType.accountApproved,
        ),
      );
    }

    if (user.isRefused == true) {
      _notifications.add(
        NotificationModel(
          id: 'rejected_${user.id}',
          title: AppTexts.accountRejectedTitle,
          message: AppTexts.accountRejectedMessage,
          createdAt: DateTime.now(),
          type: NotificationType.accountRejected,
        ),
      );
    }

    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(NotificationsLoaded(_notifications));
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        createdAt: _notifications[index].createdAt,
        isRead: true,
        type: _notifications[index].type,
      );
      emit(NotificationsLoaded(_notifications));
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        createdAt: n.createdAt,
        isRead: true,
        type: n.type,
      );
    }).toList();
    emit(NotificationsLoaded(_notifications));
  }

  void reset() {
    _notifications = [];
    emit(NotificationsInitial());
  }
}
