import 'package:equatable/equatable.dart';

class HybridSwitchStatusEntity extends Equatable {
  final String accountType;
  final bool isBusinessVerified;
  final bool canRequest;
  final bool hasPendingRequest;

  const HybridSwitchStatusEntity({
    required this.accountType,
    required this.isBusinessVerified,
    required this.canRequest,
    required this.hasPendingRequest,
  });

  bool get isBusinessAccount => accountType == 'business';
  bool get isCustomerAccount => accountType == 'customer';
  bool get isHybridAccount => accountType == 'hybrid';

  @override
  List<Object?> get props => [
    accountType,
    isBusinessVerified,
    canRequest,
    hasPendingRequest,
  ];
}
