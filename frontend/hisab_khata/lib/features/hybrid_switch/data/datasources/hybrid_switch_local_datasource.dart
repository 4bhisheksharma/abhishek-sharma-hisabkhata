abstract class HybridSwitchLocalDatasource {
  Future<void> cacheData(List<Map<String, dynamic>> data);
  Future<List<Map<String, dynamic>>> getCachedData();
}
