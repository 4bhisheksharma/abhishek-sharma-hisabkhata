import 'hybrid_switch_event.dart';
import 'hybrid_switch_state.dart';

class HybridSwitchBloc {
  HybridSwitchState _state = HybridSwitchInitial();

  HybridSwitchState get state => _state;

  void add(HybridSwitchEvent event) {
    // TODO: handle events and emit states
  }
}
