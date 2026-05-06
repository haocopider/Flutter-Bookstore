import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client _httpClient;
  final String baseUrl;

  ApiService(
      this._httpClient, {
        this.baseUrl = "https://192.168.100.67:7259",
      });

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<List<T>?> getListAsync<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    String? path,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, path: path, params: queryParameters);

    try {
      final customHeaders = await _getHeaders();
      final response = await _httpClient.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<T> parsedList = [];

        for (var item in data) {
          try {
            parsedList.add(fromJson(item as Map<String, dynamic>));
          } catch (e) {
            print("🚨 Lỗi Parse 1 phần tử trong danh sách ($endpoint):");
            print("Chi tiết lỗi: $e");
            print("Dữ liệu gây lỗi: $item\n");
          }
        }

        return parsedList;
      }
      return null;
    } catch (e) {
      print("GET List HTTP Error ($endpoint): $e");
      return null;
    }
  }

  Future<T?> getOneAsync<T>({
    required String endpoint,
    int? id,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final uri = id != null ? _buildUri(endpoint, id: id) : Uri.parse("$baseUrl/api/$endpoint");

    try {
      final customHeaders = await _getHeaders();

      final response = await _httpClient.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      }

      print("API Fail: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> postAsync<T>({
    required String endpoint,
    required T item,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final customHeaders = await _getHeaders();
      final response = await _httpClient.post(
        uri,
        headers: customHeaders,
        body: jsonEncode(toJson(item)),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<bool> putAsync<T>({
    required String endpoint,
    int? id,
    required T item,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final uri = _buildUri(endpoint, id: id);
    try {
      final customHeaders = await _getHeaders();
      final response = await _httpClient.put(
        uri,
        headers: customHeaders,
        body: jsonEncode(toJson(item)),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAsync({required String endpoint, int? id}) async {
    final uri = _buildUri(endpoint, id: id);
    try {
      final customHeaders = await _getHeaders();
      final response = await _httpClient.delete(uri, headers: customHeaders);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Uri _buildUri(String endpoint, {int? id, String? path, Map<String, String>? params}) {
    String fullPath = "/api/$endpoint";
    if (id != null) fullPath += "/$id";
    if (path != null) fullPath += path;

    return Uri.parse("$baseUrl$fullPath").replace(queryParameters: params);
  }
}