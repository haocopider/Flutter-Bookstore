import 'package:bookstore/models/promotion.dart';
import 'package:bookstore/pages/promotion_book_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotionCarousel extends StatelessWidget {
  final List<Promotion> promotions;

  const PromotionCarousel({super.key, required this.promotions});

  String getDiscountText(Promotion p) {
    if (p.discountType == 1) {
      return '${p.discountValue}%';
    } else {
      return '${p.discountValue.toInt()}đ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final item = promotions[index];

          return GestureDetector(
            onTap: () => Get.to(() => BooksInPromotionPage(promotionId: item.id), transition: Transition.cupertino, duration: Duration(milliseconds: 400)),
            child: Container(
              margin: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.network(item.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),

                    /// overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Giảm ${getDiscountText(item)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'HSD: ${item.endDate.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}