import '../../../../core/usecases/usecase.dart';
import '../entities/hybrid_switch_entity.dart';
import '../repositories/hybrid_switch_repository.dart';

class GetHybridSwitch {
  final HybridSwitchRepository repository;

  GetHybridSwitch(this.repository);

  Future<List<HybridSwitchEntity>> call(NoParams params) {
    return repository.getAll();
  }
}
