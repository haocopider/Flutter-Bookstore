import 'package:bookstore/models/category.dart';
import 'package:bookstore/services/auth_service.dart';
import 'package:bookstore/services/order_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../models/author.dart';
import '../models/book.dart';
import '../models/promotion.dart';
import 'api_service.dart';
import 'base_service.dart';
import 'logging_client_service.dart';

final getIt = GetIt.instance;

void setupDI() {
  final client = LoggingClient(http.Client());

  final apiService = ApiService(client);
  getIt.registerSingleton<ApiService>(apiService);

  getIt.registerLazySingleton<BaseService<Book>>(
          () => BaseService<Book>(getIt<ApiService>(), "books", Book.fromJson, (b) => b.toJson())
  );

  getIt.registerLazySingleton<BaseService<Author>>(
          () => BaseService<Author>(getIt<ApiService>(), "authors", Author.fromJson, (a) => a.toJson())
  );

  getIt.registerLazySingleton<BaseService<Category>>(
      () => BaseService<Category>(getIt<ApiService>(), "categories", Category.fromJson, (c) => c.toJson())
  );

  getIt.registerLazySingleton<BaseService<Promotion>>(
      () => BaseService<Promotion>(getIt<ApiService>(), "promotions", Promotion.fromJson, (p) => p.toJson())
  );

  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<OrderService>(() => OrderService());
}
