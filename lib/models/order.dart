import 'package:bookstore/services/order_service.dart';
import '../services/di_service.dart';
import 'book.dart';


class Order {
  final int id;
  final String orderCode;
  final String shippingAddress;
  final double totalAmount;
  final double finalAmount;
  final int poinIsUsed;
  final int paymentMethod;
  final int status;
  final DateTime orderDate;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderCode,
    required this.shippingAddress,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.items,
    required this.finalAmount,
    required this.poinIsUsed,
    required this.paymentMethod
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int? ?? 0,
      orderCode: json['orderCode']?.toString() ?? 'Đang cập nhật',
      shippingAddress: json['shippingAddress']?.toString() ?? 'Chưa cập nhật địa chỉ',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as int? ?? 0,
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate'].toString()) : DateTime.now(),
      poinIsUsed: json['poinIsUsed'] as int? ?? json['pointIsUsed'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as int? ?? 0,
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
    );
  }
}

class OrderItem {
  final int bookId;
  final String bookTitle;
  final String imageUrl;
  final int quantity;
  final double originalPrice;
  final double unitPrice;

  OrderItem({
    required this.bookId,
    required this.bookTitle,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.originalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception("JSON OrderItem bị null");

    return OrderItem(
      bookId: json['bookId'] as int? ?? 0,
      bookTitle: json['bookTitle']?.toString() ?? 'Sách không rõ tên',
      imageUrl: json['imageUrl']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CheckoutItem {
  final Book book;
  final int quantity;
  final double originalPrice;
  final double finalPrice;

  CheckoutItem({
    required this.book,
    required this.quantity,
    required this.originalPrice,
    required this.finalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'book': book.toJson(),
      'quantity': quantity,
      'originalPrice': originalPrice,
      'finalPrice': finalPrice,
    };
  }
}

class OrderSnapshot {
  static Future<bool> createOrder(Map<String, dynamic> payload) async {
    return await getIt<OrderService>().createOrder(payload);
  }
  static Future<List<Order>> getOrderHistory({int? status}) async {
    return await getIt<OrderService>().getOrderHistory(status: status);
  }
  static Future<bool> cancelOrder(int orderId, String reason) async {
    return await getIt<OrderService>().cancelOrder(orderId, reason);
  }
  static Future<bool> completeOrder(int orderId, String confirm) async {
    return await getIt<OrderService>().completeOrder(orderId, confirm);
  }
}