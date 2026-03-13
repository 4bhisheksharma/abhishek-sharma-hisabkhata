import 'package:equatable/equatable.dart';

abstract class KhaltiAccountEvent extends Equatable {
  const KhaltiAccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadKhaltiAccount extends KhaltiAccountEvent {
  const LoadKhaltiAccount();
}

class LinkKhaltiAccount extends KhaltiAccountEvent {
  final String khaltiId;
  final String accountName;

  const LinkKhaltiAccount({required this.khaltiId, required this.accountName});

  @override
  List<Object?> get props => [khaltiId, accountName];
}

class UpdateKhaltiAccount extends KhaltiAccountEvent {
  final String? khaltiId;
  final String? accountName;

  const UpdateKhaltiAccount({this.khaltiId, this.accountName});

  @override
  List<Object?> get props => [khaltiId, accountName];
}

class UnlinkKhaltiAccount extends KhaltiAccountEvent {
  const UnlinkKhaltiAccount();
}
