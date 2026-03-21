abstract class HybridSwitchState {}

class HybridSwitchInitial extends HybridSwitchState {}

class HybridSwitchLoading extends HybridSwitchState {}

class HybridSwitchLoaded extends HybridSwitchState {
  final List<dynamic> items;
  HybridSwitchLoaded(this.items);
}

class HybridSwitchError extends HybridSwitchState {
  final String message;
  HybridSwitchError(this.message);
}
