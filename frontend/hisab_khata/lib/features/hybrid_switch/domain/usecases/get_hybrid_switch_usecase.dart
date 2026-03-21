import '../../../../core/usecases/usecase.dart';
import '../entities/hybrid_switch_entity.dart';
import '../repositories/hybrid_switch_repository.dart';

class GetHybridSwitch implements UseCase<List<HybridSwitchEntity>, NoParams> {
  final HybridSwitchRepository repository;

  GetHybridSwitch(this.repository);

  @override
  Future<List<HybridSwitchEntity>> call(NoParams params) {
    return repository.getAll();
  }
}
