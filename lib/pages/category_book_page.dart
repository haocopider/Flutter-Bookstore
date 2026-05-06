import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import 'book_detail_page.dart';
import 'components/book_card.dart';

class CategoryBooksPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const CategoryBooksPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlueAccent[200]!;
    Get.put(CategoryController(categoryId), tag: categoryId.toString());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),

      body: GetBuilder<CategoryController>(
        tag: categoryId.toString(),
        id: 'category_books_$categoryId',
        builder: (controller) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (controller.booksMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Chưa có sách nào thuộc thể loại này", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          final booksList = controller.booksMap.values.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: booksList.length,
            itemBuilder: (context, index) => BookCard(
                book: booksList[index],
                onTap: () => Get.to(() => BookDetailPage(bookId: booksList[index].id))
            ),
          );
        },
      ),
    );
  }

}