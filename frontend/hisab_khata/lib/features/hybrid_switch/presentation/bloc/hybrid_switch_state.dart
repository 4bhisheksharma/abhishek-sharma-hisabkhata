import 'package:equatable/equatable.dart';

import '../../domain/entities/hybrid_switch_request_entity.dart';
import '../../domain/entities/hybrid_switch_status_entity.dart';

abstract class HybridSwitchState extends Equatable {
  const HybridSwitchState();

  @override
  List<Object?> get props => [];
}

class HybridSwitchInitial extends HybridSwitchState {
  const HybridSwitchInitial();
}

class HybridSwitchLoading extends HybridSwitchState {
  const HybridSwitchLoading();
}

class HybridSwitchLoaded extends HybridSwitchState {
  final HybridSwitchStatusEntity status;
  final List<HybridSwitchRequestEntity> requests;
  final bool isUploading;
  final bool isSubmitting;
  final String? message;

  const HybridSwitchLoaded({
    required this.status,
    required this.requests,
    this.isUploading = false,
    this.isSubmitting = false,
    this.message,
  });

  HybridSwitchRequestEntity? get latestRequest =>
      requests.isEmpty ? null : requests.first;

  HybridSwitchLoaded copyWith({
    HybridSwitchStatusEntity? status,
    List<HybridSwitchRequestEntity>? requests,
    bool? isUploading,
    bool? isSubmitting,
    String? message,
    bool clearMessage = false,
  }) {
    return HybridSwitchLoaded(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      isUploading: isUploading ?? this.isUploading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    requests,
    isUploading,
    isSubmitting,
    message,
  ];
}

class HybridSwitchError extends HybridSwitchState {
  final String message;

  const HybridSwitchError(this.message);

  @override
  List<Object?> get props => [message];
}
