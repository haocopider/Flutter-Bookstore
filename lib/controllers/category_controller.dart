import 'package:get/get.dart';
import '../models/book.dart';

class CategoryController extends GetxController {
  final int categoryId;
  CategoryController(this.categoryId);

  bool isLoading = true;
  Map<int, Book> booksMap = {};

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    isLoading = true;
    update(['category_books_$categoryId']);

    try {
      final booksList = await BookSnapshot.fetchBooksByCategory(categoryId);
      if (booksList.isNotEmpty) {
        booksMap = {for (var b in booksList) b.id: b};
      }
    } finally {
      isLoading = false;
      update(['category_books_$categoryId']);
    }
  }
}