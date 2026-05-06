import 'package:intl/intl.dart';

import '../services/base_service.dart';
import '../services/di_service.dart';

class Promotion {
  final int id;
  final String name;
  final int discountType;
  final double discountValue;
  final DateTime endDate;
  final String? imageUrl;

  Promotion({
    required this.id,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.endDate,
    this.imageUrl,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Chương trình khuyến mãi',
      discountType: json['discountType'] as int? ?? 1,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now().add(const Duration(days: 1)),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discountType': discountType,
      'discountValue': discountValue,
      'endDate': endDate,
      'imageUrl': imageUrl,
    };
  }

  String get displayDiscount {
    if (discountType == 1) {
      return "GIẢM ${discountValue.toInt()}%";
    } else {
      return "GIẢM ${(discountValue / 1000).toInt()}K";
    }
  }

  String get displayEndDate {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(endDate);
  }
}

class PromotionSnapshot {
  static Future<List<Promotion>> fetchPromotions() async {
    return await getIt<BaseService<Promotion>>().getAll();
  }
  static Future<Promotion?> fetchPromotionById(int id) async{
    return await getIt<BaseService<Promotion>>().getById(id);
  }
}