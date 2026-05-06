import '../services/base_service.dart';
import '../services/di_service.dart';

class Category{
  final int id;
  final String name;
  final String slug;
  Category({required this.id, required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'description': slug,
    };
  }
}

class CategorySnapshot{
  static Future<List<Category>> fetchCategories() async {
    return await getIt<BaseService<Category>>().getAll();
  }

  static Future<Category?> fetchById(int id) async {
    return await getIt<BaseService<Category>>().getById(id);
  }
}