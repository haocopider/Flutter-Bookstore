import 'package:bookstore/models/author.dart';
import 'package:bookstore/models/promotion.dart';
import '../services/base_service.dart';
import '../services/di_service.dart';

class Book {
  final int id;
  final String title;
  final double price;
  final String imgUrl;
  final String? authorName;
  final String? publishDate;
  final int? soldCount;
  final String? description;
  final Promotion? promotion;

  Book({
    required this.id,
    required this.title,
    required this.price,
    required this.imgUrl,
    this.authorName,
    this.publishDate,
    this.soldCount,
    this.description,
    this.promotion,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Đang cập nhật',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imgUrl: json['imageUrl'] ?? json['imgUrl'] ?? '',
      authorName: json['authorName'],
      publishDate: json['publishDate'],
      soldCount: json['soldCount'],
      description: json['description'],
      promotion: json['promotion'] != null
          ? Promotion.fromJson(json['promotion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imgUrl': imgUrl,
      'authorName': authorName,
      'publishDate': publishDate,
      'soldCount': soldCount,
      'description': description,
    };
  }
}

class BookSnapshot {

  static Future<List<Book>> fetchBooksForHome() async {
    return await getIt<BaseService<Book>>().getAll();
  }

  static Future<List<Book>> searchByKeyword(String input) async {
    String? tag;
    String searchText = input;

    if (input.contains('#')) {
      final RegExp hashtagRegex = RegExp(r'#([a-zA-Z0-9_]+)');
      final match = hashtagRegex.firstMatch(input);

      if (match != null) {
        tag = match.group(1);
        searchText = input.replaceAll(match.group(0)!, '').trim();
      }
    }

    final Map<String, String> params = {};
    if (searchText.isNotEmpty) params['searchText'] = searchText;
    if (tag != null) params['tag'] = tag;

    return await getIt<BaseService<Book>>().getAll(
      path: "/search",
      params: params,
    );
  }

  static Future<Book?> fetchById(int id) async {
    try {
      // Gọi service tương tự như lúc lấy danh sách, nhưng dùng hàm lấy 1 object
      // Giả sử BaseService của bạn có hàm get() hoặc getById()
      return await getIt<BaseService<Book>>().getById(id);
    } catch (e) {
      print("🚨 Lỗi gọi API lấy chi tiết sách ID $id: $e");
      return null;
    }
  }


  static Future<List<Book>> fetchLatestCartDetails(List<int> bookIds) async {
    if (bookIds.isEmpty) return [];

    return await getIt<BaseService<Book>>().getAll(
      path: "/batch",
      params: {'ids': bookIds.join(",")},
    );
  }

  static Future<List<Book>> fetchBooksByCategory(int categoryId) async {
    return await getIt<BaseService<Book>>().getAll(
      path: "/categories",
      params: {'id': categoryId.toString()},
    );
  }

  static Future<List<Book>> fetchBooksByPromotion(int promotionId) async {
    return await getIt<BaseService<Book>>().getAll(
      path: "/promotions",
      params: {'id': promotionId.toString()},
    );
  }

  static Future<List<Book>> fetchBooksByAuthorId(int authorId) async {
    return await getIt<BaseService<Book>>().getAll(
      path: "/authors",
      params: {'id': authorId.toString()},
    );
  }
}