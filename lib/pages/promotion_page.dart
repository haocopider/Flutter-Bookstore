// lib/pages/promotion_event_page.dart
import 'package:bookstore/pages/promotion_book_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promotion_controller.dart';
import '../models/promotion.dart';

class PromotionEventPage extends StatelessWidget {
  const PromotionEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<PromotionController>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Sự Kiện & Khuyến Mãi", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: GetBuilder<PromotionController>(
        id: 'event_list',
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          if (ctrl.events.isEmpty) {
            return const Center(child: Text("Hiện tại chưa có sự kiện nào."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildEventBanner(ctrl.events[index]);
            },
          );
        },
      ),
    );
  }

  // Giao diện Banner Sự kiện Sử dụng Ảnh
  Widget _buildEventBanner(Promotion promo) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BooksInPromotionPage(promotionId: promo.id));
      },
      child: Container(
        height: 140, // Độ cao của Banner
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: (promo.imageUrl != null && promo.imageUrl!.isNotEmpty)
                    ? Image.network(
                  promo.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Nội dung chính của Banner (Giữ nguyên)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tên sự kiện
                    Text(
                      promo.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Mức giảm giá
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promo.displayDiscount,
                        style: const TextStyle(
                            color: Colors.deepOrange, // Màu nhấn cố định
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Hạn sử dụng
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Áp dụng đến: ${promo.displayEndDate}",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hình ảnh thay thế khi không có imageUrl hoặc bị lỗi
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 60, color: Colors.deepOrange.withOpacity(0.6)),
            const SizedBox(height: 8),
            Text(
              "Sự kiện đang diễn ra",
              style: TextStyle(color: Colors.deepOrange.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}