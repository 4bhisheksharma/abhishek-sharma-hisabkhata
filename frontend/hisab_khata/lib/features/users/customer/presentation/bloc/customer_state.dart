import 'package:equatable/equatable.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_dashboard_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';

/// Base class for all customer states
abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

/// Initial state
class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

/// Loading state
class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

/// Dashboard loaded successfully
class CustomerDashboardLoaded extends CustomerState {
  final CustomerDashboardEntity dashboard;
  final List<RecentConnectionEntity> recentBusinesses;

  const CustomerDashboardLoaded(
    this.dashboard, {
    this.recentBusinesses = const [],
  });

  @override
  List<Object?> get props => [dashboard, recentBusinesses];
}

/// Profile loaded successfully
class CustomerProfileLoaded extends CustomerState {
  final CustomerProfileEntity profile;
  const CustomerProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

/// Profile updated successfully

class CustomerProfileUpdated extends CustomerState {
  final CustomerProfileEntity profile;
  final String message;
  const CustomerProfileUpdated(this.profile, this.message);
  @override
  List<Object?> get props => [profile, message];
}

/// Error state
class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
