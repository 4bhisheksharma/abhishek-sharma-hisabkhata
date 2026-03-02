import 'package:equatable/equatable.dart';
import '../../domain/entities/esewa_entities.dart';

/// States for eSewa Account BLoC (Business side)
abstract class EsewaAccountState extends Equatable {
  const EsewaAccountState();

  @override
  List<Object?> get props => [];
}

class EsewaAccountInitial extends EsewaAccountState {
  const EsewaAccountInitial();
}

class EsewaAccountLoading extends EsewaAccountState {
  const EsewaAccountLoading();
}

/// Account loaded (may be null if not linked)
class EsewaAccountLoaded extends EsewaAccountState {
  final BusinessEsewaAccount? account;

  const EsewaAccountLoaded(this.account);

  bool get isLinked => account != null;

  @override
  List<Object?> get props => [account];
}

class EsewaAccountActionLoading extends EsewaAccountState {
  final BusinessEsewaAccount? currentAccount;

  const EsewaAccountActionLoading(this.currentAccount);

  @override
  List<Object?> get props => [currentAccount];
}

class EsewaAccountError extends EsewaAccountState {
  final String message;
  final BusinessEsewaAccount? currentAccount;

  const EsewaAccountError(this.message, {this.currentAccount});

  @override
  List<Object?> get props => [message, currentAccount];
}

class EsewaAccountActionSuccess extends EsewaAccountState {
  final String message;
  final BusinessEsewaAccount? account;

  const EsewaAccountActionSuccess(this.message, {this.account});

  @override
  List<Object?> get props => [message, account];
}
