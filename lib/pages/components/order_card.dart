import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/order_controller.dart';
import '../../models/order.dart';
import '../order_detail_page.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final int? currentStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );

    final statusInfo = _getStatusInfo(order.status);

    return GestureDetector(
      onTap: () {
        Get.to(
              () => OrderDetailPage(order: order),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Đơn hàng #${order.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  /// trạng thái
                  Text(
                    statusInfo.label,
                    style: TextStyle(
                      color: statusInfo.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            /// DANH SÁCH SẢN PHẨM
            ...order.items.map(
                  (item) => Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[50],
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    /// ảnh sản phẩm
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: item.imageUrl != null
                          ? ClipRRect(
                        borderRadius:
                        BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return const Icon(
                              Icons.book,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                          : const Icon(
                        Icons.book,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.bookTitle,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              Text(
                                "x${item.quantity}",
                                style: TextStyle(
                                  color:
                                  Colors.grey[700],
                                ),
                              ),

                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,
                                children: [
                                  Text(
                                    formatter.format(
                                      item.unitPrice,
                                    ),
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: Colors
                                          .deepOrange,
                                    ),
                                  ),

                                  if (item.unitPrice <
                                      item.originalPrice)
                                    Text(
                                      formatter.format(
                                        item
                                            .originalPrice,
                                      ),
                                      style:
                                      const TextStyle(
                                        decoration:
                                        TextDecoration
                                            .lineThrough,
                                        color:
                                        Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            /// FOOTER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// tổng tiền
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${order.items.length} sản phẩm",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Thành tiền: "),
                          Text(
                            formatter.format(
                              order.finalAmount,
                            ),
                            style: const TextStyle(
                              color:
                              Colors.deepOrange,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// BUTTON ACTIONS
                  if (order.status == 0) ...[
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            controller.cancelOrder(
                              order.id,
                              currentStatus,
                            );
                          },
                          style:
                          OutlinedButton.styleFrom(
                            foregroundColor:
                            Colors.redAccent,
                            side: const BorderSide(
                              color:
                              Colors.redAccent,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(6),
                            ),
                          ),
                          child: const Text(
                            "Hủy đơn hàng",
                          ),
                        ),
                      ],
                    ),
                  ],

                  /// đã giao -> xác nhận hoàn thành
                  if (order.status == 2) ...[
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            controller.completeOrder(
                              order.id,
                              currentStatus,
                            );
                          },
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.green,
                            foregroundColor:
                            Colors.white,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(6),
                            ),
                          ),
                          child: const Text(
                            "Đã nhận hàng",
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OrderStatusInfo _getStatusInfo(int status) {
    switch (status) {
      case 0:
        return _OrderStatusInfo(
          label: "CHỜ XÁC NHẬN",
          color: Colors.orange,
        );

      case 1:
        return _OrderStatusInfo(
          label: "ĐANG GIAO",
          color: Colors.blue,
        );

      case 2:
        return _OrderStatusInfo(
          label: "ĐÃ GIAO",
          color: Colors.lightGreen,
        );

      case 3:
        return _OrderStatusInfo(
          label: "HOÀN THÀNH",
          color: Colors.green,
        );

      case 4:
        return _OrderStatusInfo(
          label: "ĐÃ HỦY",
          color: Colors.red,
        );

      default:
        return _OrderStatusInfo(
          label: "KHÔNG XÁC ĐỊNH",
          color: Colors.grey,
        );
    }
  }
}

class _OrderStatusInfo {
  final String label;
  final Color color;

  _OrderStatusInfo({
    required this.label,
    required this.color,
  });
}