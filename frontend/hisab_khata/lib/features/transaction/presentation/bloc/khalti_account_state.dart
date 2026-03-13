import 'package:equatable/equatable.dart';
import '../../domain/entities/khalti_entities.dart';

abstract class KhaltiAccountState extends Equatable {
  const KhaltiAccountState();

  @override
  List<Object?> get props => [];
}

class KhaltiAccountInitial extends KhaltiAccountState {
  const KhaltiAccountInitial();
}

class KhaltiAccountLoading extends KhaltiAccountState {
  const KhaltiAccountLoading();
}

class KhaltiAccountLoaded extends KhaltiAccountState {
  final BusinessKhaltiAccount? account;

  const KhaltiAccountLoaded(this.account);

  bool get isLinked => account != null;

  @override
  List<Object?> get props => [account];
}

class KhaltiAccountActionLoading extends KhaltiAccountState {
  final BusinessKhaltiAccount? currentAccount;

  const KhaltiAccountActionLoading(this.currentAccount);

  @override
  List<Object?> get props => [currentAccount];
}

class KhaltiAccountError extends KhaltiAccountState {
  final String message;
  final BusinessKhaltiAccount? currentAccount;

  const KhaltiAccountError(this.message, {this.currentAccount});

  @override
  List<Object?> get props => [message, currentAccount];
}

class KhaltiAccountActionSuccess extends KhaltiAccountState {
  final String message;
  final BusinessKhaltiAccount? account;

  const KhaltiAccountActionSuccess(this.message, {this.account});

  @override
  List<Object?> get props => [message, account];
}
