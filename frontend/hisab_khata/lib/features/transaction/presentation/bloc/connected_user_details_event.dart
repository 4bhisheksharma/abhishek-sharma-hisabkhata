import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

/// Events for Connected User Details
abstract class ConnectedUserDetailsEvent extends Equatable {
  const ConnectedUserDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Load connected user details
class LoadConnectedUserDetails extends ConnectedUserDetailsEvent {
  final int relationshipId;

  const LoadConnectedUserDetails(this.relationshipId);

  @override
  List<Object?> get props => [relationshipId];
}

/// Refresh connected user details
class RefreshConnectedUserDetails extends ConnectedUserDetailsEvent {
  final int relationshipId;

  const RefreshConnectedUserDetails(this.relationshipId);

  @override
  List<Object?> get props => [relationshipId];
}

/// Toggle favorite status (for customers only)
class ToggleFavorite extends ConnectedUserDetailsEvent {
  final int businessId;
  final bool currentStatus;

  const ToggleFavorite({required this.businessId, required this.currentStatus});

  @override
  List<Object?> get props => [businessId, currentStatus];
}

/// Create a new transaction
class CreateTransaction extends ConnectedUserDetailsEvent {
  final int relationshipId;
  final double amount;
  final TransactionType type;
  final String? description;

  const CreateTransaction({
    required this.relationshipId,
    required this.amount,
    required this.type,
    this.description,
  });

  @override
  List<Object?> get props => [relationshipId, amount, type, description];
}
