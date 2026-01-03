import 'package:equatable/equatable.dart';
import '../../domain/entities/connected_user_details.dart';

/// States for Connected User Details
abstract class ConnectedUserDetailsState extends Equatable {
  const ConnectedUserDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConnectedUserDetailsInitial extends ConnectedUserDetailsState {
  const ConnectedUserDetailsInitial();
}

/// Loading state
class ConnectedUserDetailsLoading extends ConnectedUserDetailsState {
  const ConnectedUserDetailsLoading();
}

/// Loaded state with user details
class ConnectedUserDetailsLoaded extends ConnectedUserDetailsState {
  final ConnectedUserDetails userDetails;

  const ConnectedUserDetailsLoaded(this.userDetails);

  @override
  List<Object?> get props => [userDetails];
}

/// Error state
class ConnectedUserDetailsError extends ConnectedUserDetailsState {
  final String message;

  const ConnectedUserDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Favorite toggling state (to show loading indicator on favorite button)
class ConnectedUserDetailsFavoriteToggling extends ConnectedUserDetailsState {
  final ConnectedUserDetails userDetails;

  const ConnectedUserDetailsFavoriteToggling(this.userDetails);

  @override
  List<Object?> get props => [userDetails];
}

/// Transaction creating state
class ConnectedUserDetailsTransactionCreating
    extends ConnectedUserDetailsState {
  final ConnectedUserDetails userDetails;

  const ConnectedUserDetailsTransactionCreating(this.userDetails);

  @override
  List<Object?> get props => [userDetails];
}
