
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formatDate = DateFormat('dd-MM-yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng", style: TextStyle(fontSize: 18, color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusBanner(),
            _buildShippingInfo(),
            const SizedBox(height: 8),
            _buildProductList(formatCurrency),
            const SizedBox(height: 8),

            _buildPaymentDetails(formatCurrency),

            const SizedBox(height: 8),
            _buildOrderInfo(formatDate),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(controller),
    );
  }

  Widget _buildStatusBanner() {
    Color bgColor = Colors.orange;
    String statusText = "Chờ xác nhận";
    IconData icon = Icons.pending_actions;

    if (order.status == 1) { bgColor = Colors.blue; statusText = "Đang giao hàng"; icon = Icons.local_shipping; }
    else if (order.status == 2) { bgColor = Colors.green; statusText = "Đã giao"; icon = Icons.check_circle; }
    else if (order.status == 3) { bgColor = Colors.green; statusText = "Hoàn thành"; icon = Icons.check_circle; }
    else if (order.status == 4) { bgColor = Colors.red; statusText = "Đã hủy"; icon = Icons.cancel; }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Cảm ơn bạn đã mua sắm tại Bookstore", style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Địa chỉ nhận hàng", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(order.shippingAddress, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(NumberFormat format) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.storefront, size: 20),
                SizedBox(width: 8),
                Text("Bookstore Mall", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...order.items.map((item) {
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.bookTitle, style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("x${item.quantity}", style: TextStyle(color: Colors.grey[600])),

                            // === ĐÃ SỬA CỤM GIÁ TIỀN Ở ĐÂY ===
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(format.format(item.unitPrice), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                                if (item.unitPrice < item.originalPrice)
                                  Text(
                                      format.format(item.originalPrice),
                                      style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)
                                  ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(NumberFormat format) {
    double shippingFee = 25000;
    double pointDiscount = order.poinIsUsed * 1000.0;
    String paymentMethodStr = order.paymentMethod == 1 ? "Chuyển khoản QR Code" : "Thanh toán khi nhận hàng (COD)";

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chi tiết thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Phương thức thanh toán
          _buildSummaryRow("Phương thức thanh toán", paymentMethodStr, isBold: false),
          const Divider(height: 24),

          // Tiền gốc
          _buildSummaryRow("Tổng tiền hàng", format.format(order.totalAmount)),
          _buildSummaryRow("Phí vận chuyển", format.format(shippingFee)),

          // Trừ điểm (chỉ hiển thị nếu có dùng)
          if (order.poinIsUsed > 0)
            _buildSummaryRow(
                "Sử dụng Bookstore Points",
                "- ${format.format(pointDiscount)}",
                valueColor: Colors.green
            ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Thành tiền", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                  format.format(order.finalAmount), // Lấy thẳng finalAmount từ DB
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
              value,
              style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? Colors.black87,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal
              )
          ),
        ],
      ),
    );
  }
  Widget _buildOrderInfo(DateFormat format) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Mã đơn hàng", style: TextStyle(color: Colors.grey[700])), Text("#${order.id}", style: const TextStyle(fontWeight: FontWeight.w500))],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Thời gian đặt hàng", style: TextStyle(color: Colors.grey[700])), Text(format.format(order.orderDate.toLocal()))],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(OrderController controller) {
    if (order.status == 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (order.status == 0)
            OutlinedButton(
              onPressed: () async {
                await controller.cancelOrder(order.id, order.status);
                Get.back();
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black87),
              child: const Text("Hủy đơn hàng"),
            ),
          if (order.status == 1)
            ElevatedButton(
              onPressed: () async {
                await controller.completeOrder(order.id, order.status);
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
              child: const Text("Đã nhận được hàng"),
            ),
        ],
      ),
    );
  }
}