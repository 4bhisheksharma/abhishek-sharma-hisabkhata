import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_notifications_usecase.dart';
import '../../../domain/usecases/get_unread_notifications_usecase.dart';
import '../../../domain/usecases/get_unread_count_usecase.dart';
import '../../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../../domain/usecases/delete_notification_usecase.dart';
import '../../../domain/usecases/delete_all_read_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetAllNotificationsUseCase getAllNotificationsUseCase;
  final GetUnreadNotificationsUseCase getUnreadNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final DeleteAllReadNotificationsUseCase deleteAllReadNotificationsUseCase;

  NotificationBloc({
    required this.getAllNotificationsUseCase,
    required this.getUnreadNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    required this.deleteNotificationUseCase,
    required this.deleteAllReadNotificationsUseCase,
  }) : super(const NotificationInitial()) {
    on<GetAllNotificationsEvent>(_onGetAllNotifications);
    on<GetUnreadNotificationsEvent>(_onGetUnreadNotifications);
    on<GetUnreadCountEvent>(_onGetUnreadCount);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<DeleteAllReadNotificationsEvent>(_onDeleteAllReadNotifications);
  }

  /// Handle get all notifications event
  Future<void> _onGetAllNotifications(
    GetAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await getAllNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (notifications) =>
          emit(AllNotificationsLoaded(notifications: notifications)),
    );
  }

  /// Handle get unread notifications event
  Future<void> _onGetUnreadNotifications(
    GetUnreadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await getUnreadNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (notifications) =>
          emit(UnreadNotificationsLoaded(notifications: notifications)),
    );
  }

  /// Handle get unread count event
  Future<void> _onGetUnreadCount(
    GetUnreadCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await getUnreadCountUseCase();
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (count) => emit(UnreadCountLoaded(count: count)),
    );
  }

  /// Handle mark notification as read event
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await markNotificationAsReadUseCase(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (notification) {
        emit(NotificationMarkedAsRead(notification: notification));
        // Reload notifications
        add(const GetAllNotificationsEvent());
      },
    );
  }

  /// Handle mark all notifications as read event
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await markAllNotificationsAsReadUseCase();
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (count) {
        emit(AllNotificationsMarkedAsRead(count: count));
        // Reload notifications
        add(const GetAllNotificationsEvent());
      },
    );
  }

  /// Handle delete notification event
  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await deleteNotificationUseCase(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (_) {
        emit(const NotificationDeleted());
        // Reload notifications
        add(const GetAllNotificationsEvent());
      },
    );
  }

  /// Handle delete all read notifications event
  Future<void> _onDeleteAllReadNotifications(
    DeleteAllReadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    final result = await deleteAllReadNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationError(message: failure.failureMessage)),
      (count) {
        emit(AllReadNotificationsDeleted(count: count));
        // Reload notifications
        add(const GetAllNotificationsEvent());
      },
    );
  }
}
