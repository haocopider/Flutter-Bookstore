import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import 'components/order_card.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  OrderHistoryPage({super.key});

  final OrderController controller =
  Get.put(OrderController());

  final tabs = const [
    {'title': 'Tất cả', 'status': null},
    {'title': 'Chờ xác nhận', 'status': 0},
    {'title': 'Đang giao', 'status': 1},
    {'title': 'Đã giao', 'status': 2},
    {'title': 'Hoàn thành', 'status': 3},
    {'title': 'Đã hủy', 'status': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text(
            "Đơn mua",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.deepOrange,
            tabs: tabs
                .map(
                  (e) => Tab(
                text: e['title'] as String,
              ),
            )
                .toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((e) {
            return OrderListView(
              status: e['status'] as int?,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class OrderListView extends StatefulWidget {
  final int? status;

  const OrderListView({
    super.key,
    required this.status,
  });

  @override
  State<OrderListView> createState() =>
      _OrderListViewState();
}

class _OrderListViewState
    extends State<OrderListView>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      controller.fetchOrders(widget.status);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<OrderController>(
      id: 'tab_${widget.status}',
      builder: (_) {
        bool isLoading =
            controller.loadingMap[widget.status] ??
                true;

        List<Order> orders =
            controller.ordersMap[widget.status] ??
                [];

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có đơn hàng",
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchOrders(
            widget.status,
            forceRefresh: true,
          ),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, index) {
              final order = orders[index];

              return OrderCard(
                order: order,
                currentStatus: widget.status,
              );
            },
          ),
        );
      },
    );
  }
}