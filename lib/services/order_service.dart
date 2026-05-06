import 'package:bookstore/services/api_service.dart';
import '../models/order.dart';
import 'di_service.dart';

class OrderService{
  final ApiService _apiService = getIt<ApiService>();
  final String _endpoint = "orders";

  Future<bool> createOrder(Map<String, dynamic> orderPayload) async {
    try {
      final response = await _apiService.postAsync(
        endpoint: _endpoint,
        item: orderPayload,
        toJson: (item) => item,
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<Order?> getOrderDetail(int orderId) async {
    try {
      final response = await _apiService.getOneAsync(endpoint: "$_endpoint/$orderId", fromJson: Order.fromJson);
      if (response != null) {
        return response;
      }
      return null;
    } catch (e) {
      print("Lỗi lấy chi tiết đơn hàng: $e");
      return null;
    }
  }

  Future<List<Order>> getOrderHistory({int? status}) async {
    try {
      String endpoint = "$_endpoint/history";
      if (status != null) {
        endpoint += "?status=$status";
      }

      final response = await _apiService.getListAsync(endpoint: endpoint, fromJson: Order.fromJson);

      if (response != null) {
        return response;
      }
      return [];
    } catch (e) {
      print("Lỗi lấy lịch sử đơn hàng: $e");
      return [];
    }
  }

  Future<bool> cancelOrder(int orderId, String reason) async {
    try {
      final response = await _apiService.putAsync(
        endpoint: "$_endpoint/$orderId/cancel",
        item: {"reason": reason},
        toJson: (item) => item,
      );
      return response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeOrder(int orderId, String confirm) async{
    try {
      final response = await _apiService.putAsync(
        endpoint: "$_endpoint/$orderId/complete",
        item: {"confirm" : confirm},
        toJson: (item) => item,
      );
      return response;
    } catch (e) {
      return false;
    }
  }
}