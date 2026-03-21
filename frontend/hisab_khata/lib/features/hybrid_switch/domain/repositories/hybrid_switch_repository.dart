import '../entities/hybrid_switch_entity.dart';

abstract class HybridSwitchRepository {
  Future<List<HybridSwitchEntity>> getAll();
  Future<HybridSwitchEntity?> getById(String id);
}
