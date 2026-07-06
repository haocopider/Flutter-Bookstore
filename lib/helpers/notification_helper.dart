import 'package:bookstore/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../services/di_service.dart';

class NotificationHelper {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> registerDeviceTokenWithBackend() async {
    try {
      // 1. Xin quyền thông báo từ người dùng (nếu chưa có)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Lấy FCM Token duy nhất của thiết bị hiện tại từ Google Server
        String? fcmToken = await _firebaseMessaging.getToken();

        if (fcmToken != null) {
          print("Mã thiết bị FCM Token của máy này là: $fcmToken");

          // 3. Đẩy token này lên API của Backend để lưu vào cột FcmToken
          // Giả sử bạn sử dụng ApiService đã xây dựng:
          final response = await getIt<AuthService>().updateFcmToken(fcmToken);

          if (response == true) {
            print("Đã đồng bộ mã thiết bị với hệ thống Backend thành công.");
          }
        }
      }
    } catch (e) {
      print("Lỗi khi đăng ký cấu hình thông báo: $e");
    }
  }
}