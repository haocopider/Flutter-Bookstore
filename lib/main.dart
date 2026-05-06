import 'dart:io';
import 'package:bookstore/pages/promotion_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bookstore/controllers/auth_controller.dart';
import 'package:bookstore/controllers/cart_controller.dart';
import 'package:bookstore/pages/home_page.dart';
import 'package:bookstore/pages/profile_page.dart';
import 'package:bookstore/services/di_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/home_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/promotion_controller.dart';


class MainController extends GetxController {
  int selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    update(['bottom_nav']);
  }
}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await SharedPreferences.getInstance();
  setupDI();
  Get.put(HomeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(PromotionController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(OrderController(), permanent: true);
  Get.put(MainController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookstore Clone UI',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainScreen(),
    );
  }
}


class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<MainController>();

    final List<Widget> pages = [
      const HomePage(),
      const PromotionEventPage(),
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_sharp, size: 100),
            Text(
              'Đang trong giai đoạn phát triển',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
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