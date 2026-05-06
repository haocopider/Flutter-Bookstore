import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/book_detail_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/order.dart';
import 'checkout_page.dart';

class BookDetailPage extends StatelessWidget {
  final int bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookDetailController(bookId), tag: bookId.toString());
    final Color primaryColor = Colors.lightBlueAccent[200]!;

    return Scaffold(
      backgroundColor: Colors.white,

      body: GetBuilder<BookDetailController>(
        tag: bookId.toString(),
        id: 'book_detail',
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (ctrl.book == null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Lỗi")),
              body: const Center(child: Text("Không tìm thấy thông tin sách.")),
            );
          }

          final book = ctrl.book!;
          final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

          // Xử lý giá sau khi áp dụng Khuyến mãi
          double finalPrice = book.price;
          String discountLabel = "";
          if (book.promotion != null) {
            if (book.promotion!.discountType == 1) {
              finalPrice = book.price * (1 - book.promotion!.discountValue / 100);
              discountLabel = "-${book.promotion!.discountValue.toInt()}%";
            } else {
              finalPrice = book.price - book.promotion!.discountValue;
              discountLabel = "-${NumberFormat.compact().format(book.promotion!.discountValue)}";
            }
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // 1. ẢNH BÌA SÁCH
                    SliverAppBar(
                      expandedHeight: 350,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      iconTheme: IconThemeData(color: primaryColor),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          color: Colors.grey[50],
                          child: Hero(
                            tag: 'book_${book.id}',
                            child: _buildBookImage(book.imgUrl),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => Get.toNamed('/cart')),
                        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                      ],
                    ),

                    // 2. BANNER KHUYẾN MÃI
                    if (book.promotion != null)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.redAccent, Colors.orangeAccent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    book.promotion!.name.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              const Text("Đang diễn ra", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),

                    // 3. THÔNG TIN CƠ BẢN (GIÁ + TÊN SÁCH)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (book.promotion != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(currencyFormat.format(finalPrice), style: const TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.w900)),
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(currencyFormat.format(book.price), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 16)),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                                    ),
                                    child: Text(discountLabel, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(currencyFormat.format(book.price), style: TextStyle(color: primaryColor, fontSize: 28, fontWeight: FontWeight.w900)),
                            ],
                            const SizedBox(height: 12),
                            Text(book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(thickness: 8, color: Color(0xFFF5F5F5))),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                "Thông tin chi tiết",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 16),

                            _buildDetailRow(
                                "Tác giả:",
                                book.authorName ?? "Đang cập nhật"
                            ),

                            // _buildDetailRow(
                            //     "Thể loại:",
                            //     book.categories?.isNotEmpty == true
                            //         ? book.categories!.map((c) => c.name).join(', ')
                            //         : "Đang cập nhật"
                            // ),

                            _buildDetailRow("Nhà xuất bản:", "Đang cập nhật"),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(thickness: 8, color: Color(0xFFF5F5F5))),
                    // 4. MÔ TẢ
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(book.description ?? 'Đang cập nhật...', style: TextStyle(color: Colors.grey[800], height: 1.7, fontSize: 15)),
                      ),
                    )
                  ],
                ),
              ),

              // THANH ĐIỀU HƯỚNG BOTTOM NẰM BÊN NGOÀI SCROLL
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    _buildBottomIconButton(Icons.chat_outlined, 'Chat ngay', primaryColor),
                    Container(width: 1, height: 30, color: Colors.grey[200]),

                    // MỚI: BẤM VÀO SẼ MỞ BOTTOM SHEET CHỌN SỐ LƯỢNG (Action = 'cart')
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () => _showFormatSelectionBottomSheet(context, ctrl, primaryColor, action: 'cart', currencyFormat: currencyFormat, finalPrice: finalPrice),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_shopping_cart, color: primaryColor),
                            const Text('Thêm vào giỏ', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

                    // MỚI: BẤM VÀO SẼ MỞ BOTTOM SHEET (Action = 'buy')
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => _showFormatSelectionBottomSheet(context, ctrl, primaryColor, action: 'buy', currencyFormat: currencyFormat, finalPrice: finalPrice),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Text('Mua Ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HÀM XÂY DỰNG CỬA SỔ BOTTOM SHEET KIỂU SHOPEE ---
  void _showFormatSelectionBottomSheet(BuildContext context, BookDetailController ctrl, Color primaryColor, {required String action, required NumberFormat currencyFormat, required double finalPrice}) {
    // Reset số lượng về 1 mỗi khi mở sheet
    ctrl.selectedQuantity = 1;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GetBuilder<BookDetailController>(
                tag: ctrl.bookId.toString(),
                id: 'bottom_sheet_actions',
                builder: (sheetCtrl) {
                  final book = sheetCtrl.book!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Ảnh nhỏ + Giá + Nút Tắt
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(book.imgUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.book, size: 80)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(currencyFormat.format(finalPrice), style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("Kho: 150", style: TextStyle(color: Colors.grey[600], fontSize: 14)), // Tạm fix cứng, nên lấy từ DB
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1),

                      // // Phân loại: Định dạng sách
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text("Định dạng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      //       const SizedBox(height: 12),
                      //       Wrap(
                      //         spacing: 12,
                      //         children: List.generate(mockFormats.length, (index) {
                      //           bool isSelected = sheetCtrl.selectedFormatIndex == index;
                      //           return GestureDetector(
                      //             onTap: () => sheetCtrl.selectFormat(index),
                      //             child: Container(
                      //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //               decoration: BoxDecoration(
                      //                 color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[100],
                      //                 border: Border.all(color: isSelected ? primaryColor : Colors.transparent),
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //               child: Text(
                      //                 mockFormats[index],
                      //                 style: TextStyle(color: isSelected ? primaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      //               ),
                      //             ),
                      //           );
                      //         }),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const Divider(thickness: 1),

                      // Chọn Số lượng
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Số lượng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: () => sheetCtrl.updateQuantity(-1), color: Colors.grey[700]),
                                  Container(width: 40, alignment: Alignment.center, child: Text('${sheetCtrl.selectedQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                  IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () => sheetCtrl.updateQuantity(1), color: Colors.grey[700]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Nút Xác nhận phía dưới cùng
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Get.back();

                            if (action == 'cart') {
                              final cartController = Get.find<CartController>();

                              cartController.addToCart(book.id, quantity: sheetCtrl.selectedQuantity);

                              Get.snackbar(
                                  "Thành công",
                                  "Đã thêm vào giỏ hàng",
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM
                              );
                            } else {
                              // Chuyển sang CheckoutPage
                              Get.to(() => CheckoutPage(
                                items: [
                                  CheckoutItem(
                                    book: book,
                                    quantity: sheetCtrl.selectedQuantity,
                                    originalPrice: book.price,
                                    finalPrice: finalPrice,
                                  )
                                ],
                                isFromCart: false,
                              ));
                            }
                          },
                          child: Text("Xác nhận", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                }
            ),
          );
        }
    );
  }

  // --- CÁC WIDGET PHỤ TRỢ ---

  // Xử lý hiển thị ảnh an toàn
  Widget _buildBookImage(String? url) {
    if (url == null || url.trim().isEmpty) {
      return const Center(child: Icon(Icons.menu_book, size: 80, color: Colors.grey));
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
    );
  }

  Widget _buildBottomIconButton(IconData icon, String label, Color color) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}