import 'package:equatable/equatable.dart';

/// Base class for all business events
abstract class BusinessEvent extends Equatable {
  const BusinessEvent();
  @override
  List<Object?> get props => [];
}

/// Event to load business dashboard
class LoadBusinessDashboard extends BusinessEvent {
  const LoadBusinessDashboard();
}

/// Event to load business profile
class LoadBusinessProfile extends BusinessEvent {
  const LoadBusinessProfile();
}

/// Event to update business profile
class UpdateBusinessProfileEvent extends BusinessEvent {
  final String? businessName;
  final String? fullName;
  final String? phoneNumber;
  final String? profilePicturePath;

  const UpdateBusinessProfileEvent({
    this.businessName,
    this.fullName,
    this.phoneNumber,
    this.profilePicturePath,
  });

  @override
  List<Object?> get props => [
    businessName,
    fullName,
    phoneNumber,
    profilePicturePath,
  ];
}
