import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promotion_controller.dart';
import '../models/promotion.dart';
import 'book_detail_page.dart';
import 'components/book_card.dart';

class BooksInPromotionPage extends StatefulWidget {
  final int promotionId; // Chỉ truyền Id

  const BooksInPromotionPage({super.key, required this.promotionId});

  @override
  State<BooksInPromotionPage> createState() => _BooksInPromotionPageState();
}

class _BooksInPromotionPageState extends State<BooksInPromotionPage> {
  final controller = Get.find<PromotionController>();

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu sách cho sự kiện này
    controller.fetchBooksByEvent(widget.promotionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<PromotionController>(
        id: 'event_books_${widget.promotionId}',
        builder: (ctrl) {
          // Tìm thông tin Promotion từ danh sách đã có trong Controller
          final promo = ctrl.events.firstWhereOrNull((e) => e.id == widget.promotionId);
          final books = ctrl.eventBooksMap[widget.promotionId] ?? [];

          if (ctrl.isLoading && books.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          return CustomScrollView(
            slivers: [
              // 1. App Bar với hiệu ứng Banner
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    promo?.name ?? "Sự kiện",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                    ),
                  ),
                  background: _buildBanner(promo),
                ),
              ),

              // 2. Tiêu đề danh sách hoặc bộ lọc (nếu có)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "Sản phẩm ưu đãi (${books.length})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Danh sách sản phẩm (Grid)
              books.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text("Hết hàng hoặc sự kiện kết thúc")))
                  : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => BookCard(
                      book: books[index],
                      onTap: () => Get.to(() => BookDetailPage(bookId: books[index].id)),
                    ),
                    childCount: books.length,
                  ),
                ),
              ),

              // Khoảng đệm dưới cùng
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBanner(Promotion? promo) {
    if (promo == null || promo.imageUrl == null) {
      return Container(color: Colors.deepOrange);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(promo.imageUrl!, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
      ],
    );
  }
}