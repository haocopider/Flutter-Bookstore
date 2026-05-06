import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/book.dart';
import '../models/review.dart';

class AddReviewPage extends StatefulWidget {
  final Book book;

  const AddReviewPage({super.key, required this.book});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int _rating = 5;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  String? _uploadedImageUrl;

  Future<void> _submitReview() async {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser?.id;

    if (userId == null) {
      Get.snackbar("Lỗi", "Vui lòng đăng nhập để đánh giá");
      return;
    }

    setState(() => _isSubmitting = true);

    // 1. Tạo gói tin DTO
    final payload = Review(
      userId: userId,
      bookId: widget.book.id,
      ratingValue: _rating,
      comment: _commentCtrl.text.trim(),
      reviewImg: _uploadedImageUrl,
    );

    // 2. Gửi API (Giả lập gọi API thành công sau 1.5 giây)
    // Thực tế: await apiService.postAsync(endpoint: "reviews", item: payload.toJson());
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() => _isSubmitting = false);

    Get.back();
    Get.snackbar("Thành công", "Cảm ơn bạn đã đánh giá sản phẩm!", backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Đánh giá sản phẩm", style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hiển thị sách đang đánh giá
              Row(
                children: [
                  Image.network(widget.book.imgUrl, width: 50, height: 50, fit: BoxFit.cover),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ],
              ),
              const Divider(height: 30),

              // 2. Chọn số sao (Rating)
              const Center(child: Text("Chất lượng sản phẩm", style: TextStyle(fontSize: 16))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              Center(
                child: Text(
                  _rating == 5 ? "Tuyệt vời" : _rating == 4 ? "Hài lòng" : _rating == 3 ? "Bình thường" : _rating == 2 ? "Không hài lòng" : "Tệ",
                  style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Nhập nội dung đánh giá
              TextField(
                controller: _commentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Hãy chia sẻ cảm nhận của bạn về cuốn sách này nhé...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Nút Thêm ảnh (Mô phỏng)
              GestureDetector(
                onTap: () {
                  // MÔ PHỎNG UPLOAD ẢNH THÀNH CÔNG
                  setState(() => _uploadedImageUrl = "https://example.com/mock_review_img.jpg");
                  Get.snackbar("Thành công", "Đã tải ảnh lên (Mô phỏng)");
                },
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.deepOrange, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _uploadedImageUrl == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.deepOrange),
                      SizedBox(height: 4),
                      Text("Thêm ảnh", style: TextStyle(color: Colors.deepOrange, fontSize: 12)),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("GỬI ĐÁNH GIÁ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}