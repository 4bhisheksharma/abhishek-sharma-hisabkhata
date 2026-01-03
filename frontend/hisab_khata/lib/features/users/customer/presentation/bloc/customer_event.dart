import 'package:equatable/equatable.dart';

/// Base class for all customer events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

/// Event to load customer dashboard
class LoadCustomerDashboard extends CustomerEvent {
  const LoadCustomerDashboard();
}

/// Event to load customer profile
class LoadCustomerProfile extends CustomerEvent {
  const LoadCustomerProfile();
}

/// Event to update customer profile

class UpdateCustomerProfileEvent extends CustomerEvent {
  final String? fullName;
  final String? phoneNumber;
  final String? profilePicturePath;
  const UpdateCustomerProfileEvent({
    this.fullName,
    this.phoneNumber,
    this.profilePicturePath,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, profilePicturePath];
}

/// Event to load recent businesses
class LoadRecentBusinesses extends CustomerEvent {
  final int limit;
  const LoadRecentBusinesses({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}
