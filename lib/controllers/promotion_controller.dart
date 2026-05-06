import 'package:bookstore/models/book.dart';
import 'package:get/get.dart';

import '../models/promotion.dart';

class PromotionController extends GetxController {
  bool isLoading = true;
  List<Promotion> events = [];
  Map<int, List<dynamic>> eventBooksMap = {};

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading = true;
    update(['event_list']);
    try {
      var packet = await PromotionSnapshot.fetchPromotions();
      events = packet;
    } catch (e) {
      print("Lỗi tải sự kiện: $e");
    } finally {
      isLoading = false;
      update(['event_list']);
    }
  }

  Future<void> fetchBooksByEvent(int promotionId) async {
    if (eventBooksMap.containsKey(promotionId)) return;

    isLoading = true;
    update(['event_books_$promotionId']);

    try {
      var books = await BookSnapshot.fetchBooksByPromotion(promotionId);
      eventBooksMap[promotionId] = books;
    } catch (e) {
      print("Lỗi tải sách theo sự kiện: $e");
    } finally {
      isLoading = false;
      update(['event_books_$promotionId']);
    }
  }
}