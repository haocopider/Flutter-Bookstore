import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../controllers/noti_controller.dart';
import '../../models/notification.dart';

class NotiCard extends StatelessWidget {
  final Noti notification;
  final NotificationController controller;

  const NotiCard({super.key, required this.notification, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bgColor = notification.isRead ? Colors.white : Colors.blue.withOpacity(0.08);
    final titleWeight = notification.isRead ? FontWeight.normal : FontWeight.bold;
    final titleColor = notification.isRead ? Colors.black87 : Colors.black;

    // Icon thay đổi theo loại thông báo (Dựa vào OrderId)
    final iconData = notification.orderCode != null ? Icons.local_shipping_outlined : Icons.campaign_outlined;
    final iconColor = notification.orderCode != null ? Colors.orange : Colors.redAccent;

    return Slidable(
      // Key rất quan trọng để Slidable hoạt động đúng khi xóa item
      key: ValueKey(notification.id),

      // Lướt từ phải sang trái (endActionPane)
      endActionPane: ActionPane(
        motion: const StretchMotion(), // Hiệu ứng kéo dãn đẹp mắt
        dismissible: DismissiblePane(onDismissed: () => controller.deleteNotification(notification.id)),
        children: [
          SlidableAction(
            onPressed: (context) => controller.deleteNotification(notification.id),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Xóa',
          ),
        ],
      ),

      // Nội dung thẻ
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: () => controller.markAsReadAndNavigate(notification),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khối Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Khối Nội dung
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(fontSize: 16, fontWeight: titleWeight, color: titleColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Chấm xanh thông báo chưa đọc
                          if (!notification.isRead)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.content,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}