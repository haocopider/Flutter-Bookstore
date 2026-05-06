import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/cart_controller.dart';
import '../models/book.dart';
import '../models/cart.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlueAccent[200]!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        title: const Text('Giỏ hàng của bạn', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: GetBuilder<CartController>(
        id: 'cart_list',
        builder: (controller) {
          if (controller.isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));
          if (controller.cartMap.isEmpty) return _buildEmptyCart(primaryColor);
          if (controller.cartProducts.isEmpty) return const Center(child: Text("Đang cập nhật thông tin..."));

          final cartKeys = controller.cartMap.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartKeys.length,
            itemBuilder: (context, index) {
              final bookId = cartKeys[index];
              final book = controller.cartProducts[bookId];
              final cartItem = controller.cartMap[bookId];
              if (book == null || cartItem == null) return const SizedBox.shrink();

              return _buildCartItem(book, cartItem, controller, primaryColor);
            },
          );
        },
      ),
      bottomNavigationBar: GetBuilder<CartController>(
        id: 'cart_checkout',
        builder: (controller) {
          if (controller.cartMap.isEmpty) return const SizedBox.shrink();
          return _buildCheckoutBar(controller, primaryColor);
        },
      ),
    );
  }

  Widget _buildEmptyCart(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Giỏ hàng của bạn đang trống", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Tiếp tục mua sắm", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(Book book, CartItem cartItem, CartController controller, Color primaryColor) {
    double finalPrice = book.price;
    if (book.promotion != null) {
      if (book.promotion!.discountType == 1) {
        finalPrice = book.price * (1 - book.promotion!.discountValue / 100);
      } else {
        finalPrice = book.price - book.promotion!.discountValue;
      }
    }
    double itemTotal = finalPrice * cartItem.quantity;

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        key: ValueKey(book.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) => controller.removeItem(book.id),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Xóa',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: cartItem.isSelected,
                  activeColor: primaryColor,
                  onChanged: (val) => controller.toggleSelection(book.id),
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.imgUrl.isNotEmpty ? book.imgUrl : 'https://i.pinimg.com/originals/88/76/1a/88761a81450af688cd5386e36190dd02.jpg',
                    width: 70, height: 90, fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. Tên sách
                        Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3)
                        ),

                        // 2. Hiển thị Đơn giá
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                                'Đơn giá: ${formatCurrency.format(finalPrice)}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12)
                            ),
                            if (finalPrice < book.price) ...[
                              const SizedBox(width: 6),
                              Text(
                                formatCurrency.format(book.price),
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough
                                ),
                              ),
                            ]
                          ],
                        ),

                        // 3. Hiển thị Tổng tiền theo số lượng và Nút điều chỉnh
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Tổng tiền = finalPrice * quantity
                            Text(
                                formatCurrency.format(itemTotal),
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16)
                            ),

                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: Row(
                                children: [
                                  _buildQuantityButton(Icons.remove, () => controller.updateQuantity(book.id, -1)),
                                  Container(
                                      width: 30,
                                      alignment: Alignment.center,
                                      child: Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  _buildQuantityButton(Icons.add, () => controller.updateQuantity(book.id, 1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(onTap: onPressed, child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(icon, size: 16, color: Colors.grey[700])));
  }

  Widget _buildCheckoutBar(CartController controller, Color primaryColor) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    bool isAllSelected = controller.cartMap.isNotEmpty && controller.cartMap.values.every((item) => item.isSelected);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  activeColor: primaryColor,
                  onChanged: (val) => controller.toggleSelectAll(val ?? false),
                ),
                const Text("Tất cả", style: TextStyle(fontSize: 13)),
              ],
            ),

            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Tổng thanh toán", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(formatCurrency.format(controller.totalPrice), style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final items = controller.selectedCheckoutItems;
                    if (items.isEmpty) {
                      Get.snackbar("Thông báo", "Vui lòng chọn ít nhất 1 sản phẩm để thanh toán", backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                      return;
                    }
                    Get.to(() => CheckoutPage(items: items, isFromCart: true));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text("Mua hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}