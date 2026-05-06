import 'package:bookstore/services/base_service.dart';
import '../services/di_service.dart';
import 'book.dart';

class Author {
  final int id;
  final String name;
  final String? biography;
  final String? imageUrl;
  final List<Book> books;

  Author({
    required this.id,
    required this.name,
    this.biography,
    this.imageUrl,
    this.books = const []
  });

  factory Author.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Author(id: 0, name: 'Tác giả ẩn danh');

    return Author(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Tác giả ẩn danh',
      biography: json['bio']?.toString(),
      imageUrl: json['avatarUrl']?.toString(),
      books: (json['books'] as List?)?.map((i) {
        try {
          return Book.fromJson(i as Map<String, dynamic>);
        } catch (e) {
          print("Lỗi parse Sách bên trong Tác giả: $e");
          return null;
        }
      }).where((b) => b != null).cast<Book>().toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'biography': biography,
      'imageUrl': imageUrl,
    };
  }
}

class AuthorSnapshot {
  static Future<Map<int, Author>> fetchAuthorsForHome() async {
    var results = await getIt<BaseService<Author>>().getAll();
    return {for (var author in results) author.id: author};
  }

  static Future<Author> fetchById(int id) async {
    var result = await getIt<BaseService<Author>>().getById(id);
    if(result == null) throw Exception("Không tìm thấy thông tin tác giả");
    return result;
  }
}