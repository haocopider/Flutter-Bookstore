import 'api_service.dart';

class BaseService<T> {
  final ApiService _apiService;
  final String _endpoint;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  BaseService(this._apiService, this._endpoint, this._fromJson, this._toJson);

  Future<List<T>> getAll({String? path, Map<String, String>? params}) async {
    final items = await _apiService.getListAsync<T>(
      endpoint: _endpoint,
      fromJson: _fromJson,
      path: path,
      queryParameters: params,
    );
    return items ?? [];
  }

  Future<T?> getById(int id) async {
    return await _apiService.getOneAsync<T>(
      endpoint: _endpoint,
      id: id,
      fromJson: _fromJson,
    );
  }

  Future<bool> create(T item) => _apiService.postAsync(
    endpoint: _endpoint,
    item: item,
    toJson: _toJson,
  );

  Future<bool> update(int id, T item) => _apiService.putAsync(
    endpoint: _endpoint,
    id: id,
    item: item,
    toJson: _toJson,
  );

  Future<bool> delete(int id) => _apiService.deleteAsync(
    endpoint: _endpoint,
    id: id,
  );
}