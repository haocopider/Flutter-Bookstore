import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth.dart';
import 'api_service.dart';
import 'di_service.dart';

class AuthService {
  final ApiService _apiService = getIt<ApiService>();
  final String _endpoint = "auth";

  Future<UserInfo?> getMyProfile() async {
    try {
      return await _apiService.getOneAsync<UserInfo>(
        endpoint: "$_endpoint/me/profile",
        fromJson: UserInfo.fromJson,
      );
    } catch (e) {
      print("Lỗi lấy Profile: $e");
      return null;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    try {
      final data = {
        "fullName": fullName,
        "email": email,
        "password": password
      };

      return await _apiService.postAsync(
        endpoint: "$_endpoint/register",
        item: data,
        toJson: (item) => item,
      );
    } catch (e) {
      print("Lỗi Service Đăng ký: $e");
      return false;
    }
  }

  Future<LoginResponse?> login(String email, String password) async {
    try {
      final data = {
        "email": email,
        "password": password
      };

      final uri = Uri.parse("${_apiService.baseUrl}/api/auth/login");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? "Sai tài khoản hoặc mật khẩu";
        throw Exception(errorMsg);
      }
    } catch (e) {
      print("Lỗi Service Đăng nhập: $e");
      rethrow;
    }
  }

  Future<bool> updateProfile(String fullName, String phoneNumber, String address) async {
    try {
      return await _apiService.putAsync(
        endpoint: "$_endpoint/me/profile",
        item: {
          "fullName": fullName,
          "phoneNumber": phoneNumber,
          "address": address},
        toJson: (item) => item,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      return await _apiService.putAsync(
        endpoint: "$_endpoint/update-fcm-token",
        item: {"Token": fcmToken},
        toJson: (item) => item,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      return await _apiService.putAsync(
        endpoint: "$_endpoint/me/change-password",
        item: {"oldPassword": oldPassword, "newPassword": newPassword},
        toJson: (item) => item,
      );
    } catch (e) {
      return false;
    }
  }
}