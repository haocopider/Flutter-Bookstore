// Trong search_results_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_search_controller.dart';
import 'book_detail_page.dart';
import '../models/book.dart';
import 'components/book_card.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BookSearchController controller = Get.find<BookSearchController>();
    final Color primaryColor = Colors.lightBlueAccent[200]!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: GetBuilder<BookSearchController>(
          id: 'search_bar',
          builder: (ctrl) => Text(
            'Kết quả cho "${ctrl.searchText}"', // Bỏ .value
            style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: GetBuilder<BookSearchController>(
        id: 'search_results', // Lắng nghe riêng vùng kết quả
        builder: (ctrl) {
          // Bỏ .value
          if (ctrl.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (ctrl.results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Không tìm thấy kết quả nào phù hợp", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // BƯỚC ĐỆM: Chuyển Map kết quả thành List để rải vào Grid
          final resultList = ctrl.results.values.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: resultList.length,
            itemBuilder: (context, index) => BookCard(
                book: resultList[index],
                onTap: () => Get.to(() => BookDetailPage(bookId: resultList[index].id))
            ),
          );
        },
      ),
    );
  }

}