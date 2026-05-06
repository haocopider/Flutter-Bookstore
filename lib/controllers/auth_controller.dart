import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/storage_helper.dart';
import '../main.dart';
import '../models/auth.dart';
import '../services/auth_service.dart';
import '../services/di_service.dart';
import 'cart_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = getIt<AuthService>();

  bool isLoading = false;
  bool isPasswordHidden = true;

  UserInfo? currentUser;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update(['password_toggle']);
  }

  Future<void> registerUser(String fullName, String email, String password, String confirmPassword) async {
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Vui lòng điền đầy đủ thông tin.");
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _showError("Email không hợp lệ.");
      return;
    }
    if (password.length < 6) {
      _showError("Mật khẩu phải có ít nhất 6 ký tự.");
      return;
    }
    if (password != confirmPassword) {
      _showError("Mật khẩu xác nhận không khớp.");
      return;
    }

    isLoading = true;
    update(['auth_button']);

    try {
      final success = await _authService.register(fullName.trim(), email.trim(), password);

      if (success) {
        Get.back();
        Get.snackbar("Thành công!", "Tài khoản đã được tạo. Vui lòng đăng nhập.", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        _showError("Email này có thể đã được sử dụng.");
      }
    } finally {
      isLoading = false;
      update(['auth_button']);
    }
  }

  Future<void> loginUser(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return;

    isLoading = true;
    update(['auth_button']);

    try {
      final response = await _authService.login(email.trim(), password);

      if (response != null && response.token.isNotEmpty) {
        await StorageHelper.saveData('jwt_token', response.token);

        String userJson = jsonEncode(response.user.toJson());
        await StorageHelper.saveData('user_info_cache', userJson);

        currentUser = response.user;
        update(['user_profile']);

        if(Get.isRegistered<CartController>()) {
          Get.find<CartController>().reloadCartForUser();
        }

        Get.find<MainController>().changeTab(3);
        Get.offAll(() => const MainScreen());
      }
    } catch (e) {
      _showError("Đăng nhập thất bại. Kiểm tra lại email/mật khẩu.");
    } finally {
      isLoading = false;
      update(['auth_button']);
    }
  }

  Future<void> checkLoginStatus() async {
    final token = await StorageHelper.getData('jwt_token');

    if (token != null && token.isNotEmpty) {
      final cachedUserData = await StorageHelper.getData('user_info_cache');
      if (cachedUserData != null) {
        try {
          currentUser = UserInfo.fromJson(jsonDecode(cachedUserData));
          update(['user_profile']);

          if(Get.isRegistered<CartController>()) {
            Get.find<CartController>().reloadCartForUser();
          }
        } catch (e) {
          print("Lỗi parse cache user info: $e");
        }
      }

      try {
        final profileData = await _authService.getMyProfile();

        if (profileData != null) {
          currentUser = profileData;
          update(['user_profile']);

          String userJson = jsonEncode(profileData.toJson());
          await StorageHelper.saveData('user_info_cache', userJson);
        } else {
          await logout();
        }
      } catch (e) {
        print("Lỗi lấy Profile từ API (Có thể do không có mạng): $e");
      }
    }
  }

  Future<void> updateProfile(UserInfo updatedUser) async {
    if (updatedUser.fullName.trim().isEmpty) return;

    isLoading = true;
    update(['profile_update']);

    try {
      final success = await _authService.updateProfile(updatedUser.fullName, updatedUser.phoneNumber, updatedUser.address);

      if (success && currentUser != null) {
        currentUser = updatedUser;

        String userJson = jsonEncode(updatedUser.toJson());
        await StorageHelper.saveData('user_info_cache', userJson);

        update(['user_profile']);
        Get.back();
        Get.snackbar("Thành công", "Đã cập nhật thông tin cá nhân", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        _showError("Không thể cập nhật thông tin lúc này");
      }
    } finally {
      isLoading = false;
      update(['profile_update']);
    }
  }

  Future<void> logout() async {
    // Xóa tất cả dữ liệu bảo mật
    await StorageHelper.removeData('jwt_token');
    await StorageHelper.removeData('user_info_cache'); // MỚI: Xóa cache user info

    currentUser = null;
    update(['user_profile']);

    if(Get.isRegistered<CartController>()) {
      Get.find<CartController>().reloadCartForUser();
    }

    Get.find<MainController>().changeTab(3);
    Get.offAll(() => const MainScreen());
  }

  Future<void> refreshProfile() async {
    final profileData = await _authService.getMyProfile();
    if (profileData != null) {
      update(['user_profile']);
    }
  }


  Future<void> changePassword(String oldPass, String newPass, String confirmPass) async {
    if (oldPass.isEmpty || newPass.isEmpty) return;
    if (newPass != confirmPass) {
      Get.snackbar("Lỗi", "Mật khẩu xác nhận không khớp", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading = true;
    update(['password_update']);

    try {
      final success = await _authService.changePassword(oldPass, newPass);
      if (success) {
        Get.back();
        Get.snackbar("Thành công", "Đổi mật khẩu thành công", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Lỗi", "Mật khẩu cũ không chính xác", backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isLoading = false;
      update(['password_update']);
    }
  }

  void _showError(String message) {
    Get.snackbar("Lỗi", message, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }
}