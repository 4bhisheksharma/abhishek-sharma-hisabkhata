import 'dart:io';

import 'package:hisab_khata/core/data/base_remote_data_source.dart';

import '../models/hybrid_switch_model.dart';

abstract class HybridSwitchRemoteDatasource {
  Future<HybridSwitchStatusModel> getStatus();

  Future<HybridSwitchRequestModel> uploadCitizenship({
    required File citizenshipFile,
  });

  Future<HybridSwitchRequestModel> submitRequest({int? hybridRequestId});

  Future<List<HybridSwitchRequestModel>> getMyRequests();
}

class HybridSwitchRemoteDatasourceImpl extends BaseRemoteDataSource
    implements HybridSwitchRemoteDatasource {
  HybridSwitchRemoteDatasourceImpl({super.client});

  @override
  Future<HybridSwitchStatusModel> getStatus() async {
    final response = await get('hybrid-switch/status/', includeAuth: true);
    return HybridSwitchStatusModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<HybridSwitchRequestModel> uploadCitizenship({
    required File citizenshipFile,
  }) async {
    final response = await multipart(
      'hybrid-switch/upload-citizenship/',
      'POST',
      includeAuth: true,
      files: {'citizenship_document': citizenshipFile},
    );
    final requestJson = (response as Map<String, dynamic>)['request'];
    return HybridSwitchRequestModel.fromJson(
      requestJson as Map<String, dynamic>,
    );
  }

  @override
  Future<HybridSwitchRequestModel> submitRequest({int? hybridRequestId}) async {
    final Map<String, dynamic> body = {};
    if (hybridRequestId != null) {
      body['hybrid_request_id'] = hybridRequestId;
    }

    final response = await post(
      'hybrid-switch/submit/',
      body: body,
      includeAuth: true,
    );

    final requestJson = (response as Map<String, dynamic>)['request'];
    return HybridSwitchRequestModel.fromJson(
      requestJson as Map<String, dynamic>,
    );
  }

  @override
  Future<List<HybridSwitchRequestModel>> getMyRequests() async {
    final response = await get('hybrid-switch/my-requests/', includeAuth: true);
    final data = response as List<dynamic>;
    return data
        .map(
          (item) =>
              HybridSwitchRequestModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
