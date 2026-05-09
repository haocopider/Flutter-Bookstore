import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/order.dart';

class OrderController extends GetxController {
  /// cache orders theo status
  final Map<int?, List<Order>> ordersMap = {};

  /// loading state theo tab
  final Map<int?, bool> loadingMap = {};

  /// tránh fetch nhiều lần
  final Map<int?, bool> loadedMap = {};

  /// fetch orders
  Future<void> fetchOrders(
      int? status, {
        bool forceRefresh = false,
      }) async {
    /// nếu đã load rồi thì không gọi lại
    if (loadedMap[status] == true && !forceRefresh) return;

    loadingMap[status] = true;
    update(['tab_$status']);

    try {
      final orders = await OrderSnapshot.getOrderHistory(
        status: status,
      );

      ordersMap[status] = orders;
      loadedMap[status] = true;
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể tải đơn hàng",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingMap[status] = false;
      update(['tab_$status']);
    }
  }

  /// refresh nhiều tab liên quan
  Future<void> refreshRelatedTabs(List<int?> tabs) async {
    await Future.wait(
      tabs.map(
            (e) => fetchOrders(
          e,
          forceRefresh: true,
        ),
      ),
    );
  }

  /// hoàn thành đơn
  Future<void> completeOrder(
      int orderId,
      int? currentTab,
      ) async {
    bool confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text(
          "Bạn xác nhận đã nhận được hàng?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Đã nhận"),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await OrderSnapshot.completeOrder(
        orderId,
        '',
      );

      Get.back();

      if (!success) {
        Get.snackbar(
          "Lỗi",
          "Không thể cập nhật trạng thái",
        );
        return;
      }

      Get.snackbar(
        "Thành công",
        "Cảm ơn bạn đã mua sắm",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await refreshRelatedTabs([
        currentTab,
        2,
        3,
        null,
      ]);
    } catch (e) {
      Get.back();

      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi",
      );
    }
  }

  /// hủy đơn
  Future<void> cancelOrder(
      int orderId,
      int? currentTab,
      ) async {
    bool confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text(
          "Bạn chắc chắn muốn hủy đơn hàng?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await OrderSnapshot.cancelOrder(
        orderId,
        "Tôi thay đổi ý định",
      );

      Get.back();

      if (!success) {
        Get.snackbar(
          "Lỗi",
          "Không thể hủy đơn hàng",
        );
        return;
      }

      Get.snackbar(
        "Thành công",
        "Đã hủy đơn hàng",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await refreshRelatedTabs([
        currentTab,
        0,
        4,
        null,
      ]);
    } catch (e) {
      Get.back();

      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi",
      );
    }
  }
}