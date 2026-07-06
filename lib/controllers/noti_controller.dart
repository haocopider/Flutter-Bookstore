import 'package:bookstore/models/order.dart';
import 'package:bookstore/pages/order_history_page.dart';
import 'package:get/get.dart';
import '../models/notification.dart';
import '../pages/order_detail_page.dart';

class NotificationController extends GetxController {
  bool isLoading = true;
  Map<int, Noti> notifications = {};

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading = true;
    update(['noti_list']);

    try {
      final notiList = await NotiSnapshot.fetchNotifications();
      notifications = {for (final noti in notiList) noti.id: noti};

    } finally {
      isLoading = false;
      update(['noti_list']);
    }
  }

  Future<void> markAsReadAndNavigate(Noti noti) async {
    if (!noti.isRead) {
      notifications[noti.id]!.isRead = true;
      update(['noti_list']);
      await NotiSnapshot.markAsRead(noti.id, notifications[noti.id]!);
    }
    if (noti.orderId != null) {
      Get.to(() => OrderHistoryPage());
    }
  }

  Future<void> deleteNotification(int id) async {
    if (notifications.containsKey(id)) {
      // Cập nhật UI ngay lập tức
      notifications.remove(id);
      update(['noti_list']);

      await NotiSnapshot.deleteNotification(id);

      Get.snackbar(
        "Thành công", "Đã xóa thông báo",
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: const Duration(milliseconds: 300),
      );
    }
  }
}