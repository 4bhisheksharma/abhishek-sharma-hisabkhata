import 'package:equatable/equatable.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_dashboard.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_profile.dart';

/// Base class for all business states
abstract class BusinessState extends Equatable {
  const BusinessState();
  @override
  List<Object?> get props => [];
}

/// Initial state
class BusinessInitial extends BusinessState {
  const BusinessInitial();
}

/// Loading state
class BusinessLoading extends BusinessState {
  const BusinessLoading();
}

/// Dashboard loaded successfully
class BusinessDashboardLoaded extends BusinessState {
  final BusinessDashboard dashboard;
  const BusinessDashboardLoaded(this.dashboard);
  @override
  List<Object?> get props => [dashboard];
}

/// Profile loaded successfully
class BusinessProfileLoaded extends BusinessState {
  final BusinessProfile profile;
  const BusinessProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

/// Profile updated successfully
class BusinessProfileUpdated extends BusinessState {
  final BusinessProfile profile;
  final String message;
  const BusinessProfileUpdated(this.profile, this.message);
  @override
  List<Object?> get props => [profile, message];
}

/// Error state
class BusinessError extends BusinessState {
  final String message;
  const BusinessError(this.message);

  @override
  List<Object?> get props => [message];
}
