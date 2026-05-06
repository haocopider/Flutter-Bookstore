import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    double finalPrice = book.price;
    String discountLabel = "";

    if (book.promotion != null) {
      if (book.promotion!.discountType == 1) {
        finalPrice = book.price * (1 - book.promotion!.discountValue / 100);
        discountLabel = "-${book.promotion!.discountValue.toInt()}%";
      } else {
        finalPrice = book.price - book.promotion!.discountValue;
        discountLabel = "-${NumberFormat.compact().format(book.promotion!.discountValue)}";
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Bo góc mềm mại hơn
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Đổ bóng cực mờ và hiện đại
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          // Viền siêu mỏng tạo cảm giác sắc nét trên màn hình xịn
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PHẦN HÌNH ẢNH (Dùng Expanded để tự động co giãn trong GridView)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageFallback(book.imgUrl),

                    // Badge khuyến mãi thiết kế lơ lửng (Floating Pill)
                    if (book.promotion != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: ModernBadge(label: discountLabel),
                      ),
                  ],
                ),
              ),
            ),

            // 2. PHẦN THÔNG TIN TEXT
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sách
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600, // Đừng dùng bold quá đậm, w600 là vừa đẹp
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Giá sách
                  if (book.promotion != null) ...[
                    Text(
                      currencyFormat.format(finalPrice),
                      style: TextStyle(
                          color: Colors.orangeAccent[700], // Màu cam đỏ kích thích mua hàng
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormat.format(book.price),
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else
                    Text(
                      currencyFormat.format(book.price),
                      style: TextStyle(
                          color: Colors.lightBlueAccent[700], // Hoặc primary color của bạn
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tối ưu hàm load ảnh để fill đầy vùng chứa
  Widget _buildImageFallback(String? url) {
    if (url == null || url.trim().isEmpty) {
      return _buildPlaceholder();
    }
    return Image.network(
      url,
      fit: BoxFit.cover, // Đảm bảo ảnh sách luôn tràn viền đẹp mắt
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[50],
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[400],
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.menu_book_rounded, size: 40, color: Colors.grey[300]),
      ),
    );
  }
}

// Badge mới dạng viên thuốc (Pill Shape) hiện đại
class ModernBadge extends StatelessWidget {
  final String label;
  const ModernBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.redAccent, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // Dáng viên thuốc
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11
            ),
          ),
        ],
      ),
    );
  }
}