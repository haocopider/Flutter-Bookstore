import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/noti_controller.dart';
import 'components/noti_card.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<NotificationController>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent[200],
        centerTitle: true,
        elevation: 0,
      ),
      body: GetBuilder<NotificationController>(
        id: 'noti_list',
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return _buildEmptyState();
          }

          // Chuyển Map thành List và sắp xếp theo ngày mới nhất
          final notiList = controller.notifications.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notiList.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
            itemBuilder: (context, index) {
              return NotiCard(
                notification: notiList[index],
                controller: controller,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("Chưa có thông báo nào", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
