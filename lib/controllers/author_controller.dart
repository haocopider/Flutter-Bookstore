import 'package:get/get.dart';
import '../models/book.dart';

class AuthorController extends GetxController {
  final int authorId;
  bool isLoading = true;
  List<Book> authorBooks = [];

  AuthorController(this.authorId);

  @override
  void onInit() {
    super.onInit();
    fetchBooksByAuthor();
  }

  Future<void> fetchBooksByAuthor() async {
    isLoading = true;
    update(['author_books']);

    try {
      var books = await BookSnapshot.fetchBooksByAuthorId(authorId);
      authorBooks = books;
    } catch (e) {
      print("Lỗi tải sách của tác giả: $e");
    } finally {
      isLoading = false;
      update(['author_books']);
    }
  }
}