import 'dart:io';
import 'package:bookstore/pages/notification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Imports dự án của bạn ---
import 'package:bookstore/services/di_service.dart';
import 'package:bookstore/controllers/auth_controller.dart';
import 'package:bookstore/controllers/cart_controller.dart';
import 'package:bookstore/controllers/home_controller.dart';
import 'package:bookstore/controllers/order_controller.dart';
import 'package:bookstore/controllers/promotion_controller.dart';
import 'package:bookstore/pages/home_page.dart';
import 'package:bookstore/pages/promotion_page.dart';
import 'package:bookstore/pages/profile_page.dart';

import 'controllers/noti_controller.dart';

class MainController extends GetxController {
  int selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    update(['bottom_nav']);
  }
}

// LƯU Ý: Chỉ dùng cho Localhost/Dev. Lên Production cần xóa/comment.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // Giữ màn hình Splash của Native (Android/iOS) cho đến khi app load xong
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  HttpOverrides.global = MyHttpOverrides();
  await SharedPreferences.getInstance();
  setupDI();

  // 1. CHỈ đưa lên bộ nhớ vĩnh viễn các Core Controller (Cần dùng mọi lúc)
  Get.put(AuthController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(MainController(), permanent: true);

  // 2. LAZY LOAD các Controller của từng trang (Khi nào chuyển qua tab đó mới tốn RAM)
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => PromotionController(), fenix: true);
  Get.lazyPut(() => OrderController(), fenix: true);
  Get.lazyPut(() => NotificationController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    FlutterNativeSplash.remove();

    // THAY VÌ ĐỢI 2 GIÂY VÔ TRI, HÃY BẮT APP ĐỢI AUTH CHECK XONG!
    final authController = Get.find<AuthController>();
    await authController.checkLoginStatus(); // Đợi hàm này hoàn tất 100%

    if (mounted) {
      setState(() {
        _isLoading = false; // Tắt màn hình Splash, hiện MainScreen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bookstore',
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? Scaffold(
        body: Image.asset(
          'assets/splash/splash_full.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      )
          : const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Không cần gọi Get.find<MainController>() ở đây nữa vì GetBuilder đã tự tìm

    final List<Widget> pages = [
      const HomePage(),
      const PromotionEventPage(),
      const NotificationPage(),
      const Profile(),
    ];

    return GetBuilder<MainController>(
        id: 'bottom_nav',
        builder: (ctrl) {
          return Scaffold(
            body: IndexedStack(
              index: ctrl.selectedIndex,
              children: pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: ctrl.selectedIndex,
              selectedItemColor: Colors.lightBlue,
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: 12,
              unselectedFontSize: 12,
              onTap: ctrl.changeTab,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.celebration_outlined),
                  activeIcon: Icon(Icons.celebration),
                  label: 'Event',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Thông báo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Tôi',
                ),
              ],
            ),
          );
        }
    );
  }
}