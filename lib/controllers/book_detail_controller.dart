import 'package:get/get.dart';
import '../models/book.dart';

class BookDetailController extends GetxController {
  final int bookId;
  BookDetailController(this.bookId);

  bool isLoading = true;
  Book? book;

  int selectedFormatIndex = 0;
  int selectedQuantity = 1;

  @override
  void onInit() {
    super.onInit();
    fetchBookDetail();
  }

  Future<void> fetchBookDetail() async {
    isLoading = true;
    update(['book_detail']);

    try {
      var result = await BookSnapshot.fetchById(bookId);
      await Future.delayed(const Duration(milliseconds: 600));
      book = result;
    } catch (e) {
      print("Lỗi tải chi tiết sách: $e");
      book = null;
    } finally {
      isLoading = false;
      update(['book_detail']);
    }
  }

  // Cập nhật số lượng trong Bottom Sheet
  void updateQuantity(int delta) {
    if (selectedQuantity + delta > 0) {
      selectedQuantity += delta;
      update(['bottom_sheet_actions']);
    }
  }

  // Cập nhật định dạng sách được chọn
  void selectFormat(int index) {
    selectedFormatIndex = index;
    update(['bottom_sheet_actions']);
  }
}