import '../../domain/entities/hybrid_switch_entity.dart';

class HybridSwitchModel extends HybridSwitchEntity {
  const HybridSwitchModel({required super.id});

  factory HybridSwitchModel.fromJson(Map<String, dynamic> json) {
    return HybridSwitchModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
