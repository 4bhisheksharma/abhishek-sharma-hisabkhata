import 'package:equatable/equatable.dart';

/// Events for eSewa Account BLoC (Business side)
abstract class EsewaAccountEvent extends Equatable {
  const EsewaAccountEvent();

  @override
  List<Object?> get props => [];
}

/// Load the business's eSewa account
class LoadEsewaAccount extends EsewaAccountEvent {
  const LoadEsewaAccount();
}

/// Link a new eSewa account
class LinkEsewaAccount extends EsewaAccountEvent {
  final String esewaId;
  final String accountName;

  const LinkEsewaAccount({required this.esewaId, required this.accountName});

  @override
  List<Object?> get props => [esewaId, accountName];
}

/// Update the linked eSewa account
class UpdateEsewaAccount extends EsewaAccountEvent {
  final String? esewaId;
  final String? accountName;

  const UpdateEsewaAccount({this.esewaId, this.accountName});

  @override
  List<Object?> get props => [esewaId, accountName];
}

/// Unlink the eSewa account
class UnlinkEsewaAccount extends EsewaAccountEvent {
  const UnlinkEsewaAccount();
}
