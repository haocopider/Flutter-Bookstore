import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/author_controller.dart';
import '../models/author.dart';
import 'book_detail_page.dart';
import 'components/book_card.dart';

class AuthorDetailPage extends StatelessWidget {
  final Author author;

  const AuthorDetailPage({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.lightBlueAccent[700]!;

    // Khởi tạo Controller bằng author.id
    Get.put(AuthorController(author.id), tag: author.id.toString());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text("Chi tiết tác giả", style: TextStyle(color: Colors.black87, fontSize: 16)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // HEADER: THÔNG TIN TÁC GIẢ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar lớn
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(
                          author.imageUrl ?? 'https://i.pinimg.com/originals/88/76/1a/88761a81450af688cd5386e36190dd02.jpg'
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tên tác giả
                  Text(
                    author.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Tiểu sử
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      author.biography ?? "Tác giả hiện chưa có thông tin tiểu sử chi tiết. Chúng tôi sẽ cập nhật sớm nhất.",
                      style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TIÊU ĐỀ: TÁC PHẨM CỦA TÁC GIẢ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.library_books, color: primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                      "Tác phẩm nổi bật",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),

          // BODY: DANH SÁCH SÁCH (GRID)
          GetBuilder<AuthorController>(
            tag: author.id.toString(),
            id: 'author_books',
            builder: (controller) {
              if (controller.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.authorBooks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text("Tác giả này chưa có tác phẩm nào.", style: TextStyle(color: Colors.grey[500])),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final book = controller.authorBooks[index];
                      return BookCard(
                        book: book,
                        onTap: () => Get.to(() => BookDetailPage(bookId: book.id)),
                      );
                    },
                    childCount: controller.authorBooks.length,
                  ),
                ),
              );
            },
          ),

          // Đệm dưới cùng
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}