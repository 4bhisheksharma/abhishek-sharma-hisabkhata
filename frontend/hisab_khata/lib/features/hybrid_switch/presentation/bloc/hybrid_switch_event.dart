import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class HybridSwitchEvent extends Equatable {
  const HybridSwitchEvent();

  @override
  List<Object?> get props => [];
}

class HybridSwitchLoadRequested extends HybridSwitchEvent {
  const HybridSwitchLoadRequested();
}

class HybridSwitchRefreshRequested extends HybridSwitchEvent {
  const HybridSwitchRefreshRequested();
}

class HybridSwitchCitizenshipUploadRequested extends HybridSwitchEvent {
  final File citizenshipFile;

  const HybridSwitchCitizenshipUploadRequested({required this.citizenshipFile});

  @override
  List<Object?> get props => [citizenshipFile.path];
}

class HybridSwitchSubmitRequested extends HybridSwitchEvent {
  final int? hybridRequestId;

  const HybridSwitchSubmitRequested({this.hybridRequestId});

  @override
  List<Object?> get props => [hybridRequestId];
}

class HybridSwitchClearMessageRequested extends HybridSwitchEvent {
  const HybridSwitchClearMessageRequested();
}
