import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  Map<int?, List<Order>> ordersMap = {};
  Map<int?, bool> isLoadingMap = {};
  Map<int, int> statusMap ={};
  @override
  void onReady() {
    super.onReady();
    fetchAllTabs();
  }

  void fetchAllTabs() {
    fetchOrders(null);
    fetchOrders(0);
    fetchOrders(1);
    fetchOrders(2);
    fetchOrders(3);
    fetchOrders(4);
  }


  Future<void> fetchOrders(int? status) async {
    isLoadingMap[status] = true;
    update(['tab_$status']);

    final data = await OrderSnapshot.getOrderHistory(status: status);

    ordersMap[status] = data;
    if (status != null) statusMap[status] = data.length;

    isLoadingMap[status] = false;
    update(['tab_$status']);
  }

  Future<void> completeOrder(int orderId, int? currentTabStatus) async {
    bool confirm = await Get.defaultDialog(
      title: "Xác nhận",
      middleText: "Bạn xác nhận đã nhận được hàng và sản phẩm không có vấn đề gì?",
      textConfirm: "Đã nhận",
      textCancel: "Đóng",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () => Get.back(result: true),
    ) ?? false;

    if (!confirm) return;

    Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);

    bool success = await OrderSnapshot.completeOrder(orderId, '');

    Get.back();

    if (success) {
      Get.snackbar("Thành công", "Cảm ơn bạn đã mua sắm!", backgroundColor: Colors.green, colorText: Colors.white);

      fetchOrders(currentTabStatus);
      fetchOrders(2);
      fetchOrders(null);
    } else {
      Get.snackbar("Lỗi", "Không thể cập nhật trạng thái lúc này", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> cancelOrder(int orderId, int? currentTabStatus) async {
    bool confirm = await Get.defaultDialog(
      title: "Xác nhận",
      middleText: "Bạn có chắc chắn muốn hủy đơn hàng này không?",
      textConfirm: "Đồng ý",
      textCancel: "Đóng",
      confirmTextColor: Colors.white,
      buttonColor: Colors.deepOrange,
      onConfirm: () => Get.back(result: true),
    ) ?? false;

    if (!confirm) return;

    Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.deepOrange)), barrierDismissible: false);

    bool success = await OrderSnapshot.cancelOrder(orderId, "Tôi thay đổi ý định");

    Get.back();

    if (success) {
      Get.snackbar("Thành công", "Đã hủy đơn hàng", backgroundColor: Colors.green, colorText: Colors.white);

      fetchOrders(currentTabStatus);
      fetchOrders(3);
      fetchOrders(null);
    } else {
      Get.snackbar("Lỗi", "Không thể hủy đơn hàng lúc này", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}