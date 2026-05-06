import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<OrderController>;
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Đơn mua", style: TextStyle(fontSize: 18, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Chờ xác nhận"),
              Tab(text: "Đang giao"),
              Tab(text: "Đã giao"),
              Tab(text: "Hoàn thành"),
              Tab(text: "Đã hủy"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderListView(status: null), // Tất cả
            OrderListView(status: 0),    // Chờ xác nhận
            OrderListView(status: 1),    // Đang giao
            OrderListView(status: 2),    // Đã giao
            OrderListView(status: 3),    // Hoàn thành
            OrderListView(status: 4),    // Đã hủy
          ],
        ),
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  final int? status;
  const OrderListView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GetBuilder<OrderController>(
      id: 'tab_$status',
      builder: (controller) {
        bool isLoading = controller.isLoadingMap[status] ?? true;
        List<Order> orders = controller.ordersMap[status] ?? [];

        if (isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.lightBlue,
          onRefresh: () => controller.fetchOrders(status),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order, formatCurrency, controller);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Order order, NumberFormat formatter, OrderController controller) {
    String statusText = "";
    Color statusColor = Colors.black;
    if (order.status == 0) { statusText = "CHỜ XÁC NHẬN"; statusColor = Colors.orange; }
    else if (order.status == 1) { statusText = "ĐANG GIAO"; statusColor = Colors.blue; }
    else if (order.status == 2) { statusText = "ĐÃ GIAO"; statusColor = Colors.lightGreen; }
    else if (order.status == 3) { statusText = "HOÀN THÀNH"; statusColor = Colors.green; }
    else if (order.status == 4) { statusText = "ĐÃ HUỶ"; statusColor = Colors.red; }

    return GestureDetector(
      onTap: (){
        Get.to(() => OrderDetailPage(order: order), transition: Transition.cupertino, duration: const Duration(milliseconds: 400));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER: MÃ ĐƠN HÀNG VÀ TRẠNG THÁI
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text("Đơn hàng #${order.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Hiển thị trạng thái ở đây
                  Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 2. DANH SÁCH SẢN PHẨM
            ...order.items.map((item) => Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[50],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60, height: 60, color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.bookTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("x${item.quantity}", style: TextStyle(color: Colors.grey[700])),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatter.format(item.unitPrice), style: const TextStyle(fontWeight: FontWeight.w500)),
                                if (item.unitPrice < item.originalPrice)
                                  Text(
                                      formatter.format(item.originalPrice),
                                      style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)
                                  ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
            const Divider(height: 1),

            // 3. TỔNG KẾT VÀ NÚT HÀNH ĐỘNG
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${order.items.length} sản phẩm", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Row(
                        children: [
                          const Text("Thành tiền: "),
                          // Sử dụng finalAmount ở đây sẽ hợp lý hơn vì nó là số tiền cuối cùng khách phải trả
                          Text(formatter.format(order.finalAmount),
                              style: const TextStyle(color: Colors.deepOrange, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),

                  // Nút Hủy đơn
                  if (order.status == 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => controller.cancelOrder(order.id, status),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white, // Đổi màu nền thành trắng để nhìn giống viền hơn
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("Hủy đơn hàng"),
                        ),
                      ],
                    )
                  ],
                  // Nút Đã nhận hàng
                  if (order.status == 2) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton( // Đổi thành ElevatedButton để nổi bật hơn
                          onPressed: () => controller.completeOrder(order.id, status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("Đã nhận được hàng"),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}