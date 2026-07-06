import 'package:bookstore/services/base_service.dart';
import '../services/di_service.dart';

class Noti {
  final int id;
  final String title;
  final String content;
  bool isRead;
  final DateTime createdAt;
  final int? orderId;
  final String? orderCode;

  Noti({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.orderId,
    this.orderCode
  });

  factory Noti.fromJson(Map<String, dynamic> json) {
    return Noti(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      orderId: json['orderId'],
      orderCode: json['orderCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {

    };
  }
}

class NotiSnapshot{
  static Future<List<Noti>> fetchNotifications() async {
    return await getIt<BaseService<Noti>>().getAll();
  }
  static Future<bool> markAsRead(int id, Noti noti) async {
    return await getIt<BaseService<Noti>>().update(id, noti);
  }
  static Future<bool> deleteNotification(int id) async {
    return await getIt<BaseService<Noti>>().delete(id);
  }
}