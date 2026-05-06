// Trong search_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_search_controller.dart';
import 'search_results_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  void _goToResults(String query, BookSearchController controller) {
    if (query.trim().isEmpty) return;
    controller.performSearch(query);
    Get.to(() => const SearchResultsPage());
  }

  @override
  Widget build(BuildContext context) {
    final BookSearchController controller = Get.put(BookSearchController());
    final Color primaryColor = Colors.lightBlueAccent[200]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: GetBuilder<BookSearchController>(
              id: 'search_bar',
              builder: (ctrl) {
                return TextField(
                  controller: ctrl.textController,
                  autofocus: true,
                  onChanged: ctrl.onSearchChanged,
                  onSubmitted: (value) => _goToResults(value, ctrl),
                  decoration: InputDecoration(
                    hintText: 'Tìm "tên sách" hoặc "#theloai"...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    // Bỏ .value ở searchText
                    suffixIcon: ctrl.searchText.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                      onPressed: ctrl.clearSearch,
                    )
                        : null,
                  ),
                );
              }
          ),
        ),
      ),
      body: GetBuilder<BookSearchController>(
        id: 'search_suggestions', // Chỉ update vùng gợi ý
        builder: (ctrl) {
          // Bỏ .value
          if (ctrl.searchText.isEmpty) {
            return _buildSearchHistory();
          }

          if (ctrl.suggestions.isEmpty) {
            return const Center(child: Text("Đang tìm kiếm..."));
          }

          // BƯỚC ĐỆM: Chuyển Map thành List để dùng cho ListView
          final suggestionList = ctrl.suggestions.values.toList();

          return ListView.builder(
            itemCount: suggestionList.length + 1, // +1 cho nút "Tìm kiếm cho..."
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.search, color: Colors.grey),
                  title: Text('Tìm "${ctrl.searchText}"', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  onTap: () => _goToResults(ctrl.searchText, ctrl),
                );
              }

              // Trừ 1 do đã chèn phần tử ở index 0
              final book = suggestionList[index - 1];
              return ListTile(
                leading: const Icon(Icons.book_outlined, color: Colors.grey),
                title: Text(book.title), // Không còn lỗi potentially null
                onTap: () => _goToResults(book.title, ctrl),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchHistory() {
    return const Center(
      child: Text("Lịch sử tìm kiếm sẽ hiển thị ở đây", style: TextStyle(color: Colors.grey)),
    );
  }
}