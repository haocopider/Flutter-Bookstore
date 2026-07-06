import 'package:get/get.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/category.dart';

class HomeController extends GetxController {
  bool isBooksLoading = true;
  bool isCategoriesLoading = true;
  bool isAuthorsLoading = true;

  Map<int, Book> promoBooks = {};
  Map<int, Book> trendingBooks = {};
  Map<int, Book> allBooks = {};
  Map<int, Author> authors = {};
  Map<int, Author> filteredAuthors = {};
  Map<int, Category> categories = {};

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    fetchAuthors();
    fetchCategories();
  }

  Future<void> fetchHomeData() async {
    isBooksLoading = true;
    update(['books_section']);

    try {
      final allBooksList = await BookSnapshot.fetchBooksForHome();

      if (allBooksList.isNotEmpty) {
        allBooks = {for (var b in allBooksList) b.id: b};
        var promoList = allBooksList.where((b) => b.promotion != null).toList();
        promoBooks = {for (var b in promoList) b.id: b};

        trendingBooks = {for (var b in allBooksList.reversed.take(6)) b.id: b};
      }
    } catch (e) {
      print("Lỗi tải sách: $e");
    } finally {
      isBooksLoading = false;
      update(['books_section']);
    }
  }

  Future<void> fetchAuthors() async {
    isAuthorsLoading = true;
    update(['authors_section']);

    try {
      authors = await AuthorSnapshot.fetchAuthorsForHome();
      filteredAuthors = Map.from(authors);
    } catch (e) {
      print("Lỗi tải tác giả: $e");
    } finally {
      isAuthorsLoading = false;
      update(['authors_section']);
    }
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading = true;
    update(['categories_section']);

    try {
      final categoryList = await CategorySnapshot.fetchCategories();

      if (categoryList.isNotEmpty) {
        categories = {for (var c in categoryList) c.id: c};
      }
    } catch (e) {
      print("Lỗi tải thể loại: $e");
    } finally {
      isCategoriesLoading = false;
      update(['categories_section']);
    }
  }

  void searchAuthor(String query) {
    if (query.isEmpty) {
      filteredAuthors = Map.from(authors);
    } else {
      filteredAuthors = Map.fromEntries(
          authors.entries.where((entry) =>
              entry.value.name.toLowerCase().contains(query.toLowerCase())
          )
      );
    }
    update(['authors_section']);
  }
}