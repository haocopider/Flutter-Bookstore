import 'package:bookstore/pages/order_history_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../main.dart';
import '../models/order.dart';

class CheckoutPage extends StatefulWidget {
  final List<CheckoutItem> items;
  final bool isFromCart;

  const CheckoutPage({
    super.key,
    required this.items,
    this.isFromCart = false,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final AuthController _authCtrl = Get.find<AuthController>();

  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _pointsCtrl = TextEditingController();

  bool _isPlacingOrder = false;
  double _shippingFee = 25000;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // CÁC BIẾN MỚI
  int _paymentMethod = 0; // 0: COD, 1: QRCode
  int _pointIsUsed = 0;    // Số điểm sử dụng

  @override
  void initState() {
    super.initState();
    _addressCtrl.text = _authCtrl.currentUser?.address ?? "230 Hương lộ Ngọc Hiệp";

    // Lắng nghe sự thay đổi của ô nhập điểm
    _pointsCtrl.addListener(() {
      setState(() {
        _pointIsUsed = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  // --- LOGIC TÍNH TIỀN ---
  // 1. Tổng tiền sản phẩm (KHÔNG tính giảm giá) -> totalAmount
  double get _totalOriginalAmount => widget.items.fold(0, (sum, item) => sum + (item.originalPrice * item.quantity));

  // 2. Tổng tiền sản phẩm (ĐÃ tính khuyến mãi của sách)
  double get _totalMerchandise => widget.items.fold(0, (sum, item) => sum + (item.finalPrice * item.quantity));

  // 3. Khuyến mãi từ sách (Giá gốc - Giá sale)
  double get _totalDiscount => _totalOriginalAmount - _totalMerchandise;

  // 4. Số tiền giảm từ Điểm (1 Point = 1000đ)
  double get _pointDiscount => _pointIsUsed * 1000.0;

  // 5. Giá cuối cùng -> finalAmount (Đảm bảo không bị âm)
  double get _finalPayment {
    double total = _totalMerchandise + _shippingFee - _pointDiscount;
    return total < 0 ? 0 : total;
  }

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập địa chỉ giao hàng", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isPlacingOrder = true);

    // GÓI TIN MỚI ĐÃ ĐƯỢC CẬP NHẬT THEO YÊU CẦU
    final Map<String, dynamic> payload = {
      "shippingAddress": _addressCtrl.text.trim(),
      "paymentMethod": _paymentMethod,
      "pointIsUsed": _pointIsUsed,
      "totalAmount": _totalOriginalAmount,
      "finalAmount": _finalPayment,
      "items": widget.items.map((item) {
        return {
          "bookId": item.book.id,
          "bookTitle": item.book.title,
          "quantity": item.quantity,
          "originalPrice": item.originalPrice,
          "unitPrice": item.finalPrice
        };
      }).toList(),
    };

    final success = await OrderSnapshot.createOrder(payload);

    setState(() => _isPlacingOrder = false);

    if (success) {
      if (widget.isFromCart) {
        Get.find<CartController>().removeCheckoutItems();
      }

      Get.offAll(() => const MainScreen());
      Get.find<MainController>().changeTab(3);
      Get.to(() => OrderHistoryPage(), transition: Transition.cupertino, duration: Duration(milliseconds: 400));
      Get.snackbar(
          "Thành công", "Đơn hàng của bạn đã được ghi nhận!",
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM
      );
    } else {
      Get.snackbar("Thất bại", "Có lỗi xảy ra khi tạo đơn hàng.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    // BỌC GESTURE DETECTOR ĐỂ FIX LỖI KHÔNG TẮT ĐƯỢC BÀN PHÍM
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAddressSection(),
                    const SizedBox(height: 8),
                    _buildOrderItemsSection(),
                    const SizedBox(height: 8),
                    _buildPointsSection(),
                    const SizedBox(height: 8),
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 8),
                    _buildOrderSummarySection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // --- GIAO DIỆN NHẬP ĐỊA CHỈ ---
  Widget _buildAddressSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.deepOrange[400], size: 20),
              const SizedBox(width: 8),
              const Text("Địa chỉ nhận hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Nhập địa chỉ nhận hàng của bạn...",
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.deepOrange), borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // --- GIAO DIỆN SẢN PHẨM ---
  Widget _buildOrderItemsSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.black87, size: 20),
                const SizedBox(width: 8),
                const Text("Bookstore Mall", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ...widget.items.map((item) => Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[50],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(item.book.imgUrl, width: 80, height: 80, fit: BoxFit.cover),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formatCurrency.format(item.finalPrice), style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                              if (item.finalPrice < item.originalPrice)
                                Text(formatCurrency.format(item.originalPrice), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Text("x${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // --- GIAO DIỆN NHẬP ĐIỂM  ---
  Widget _buildPointsSection() {
    int availablePoints = _authCtrl.currentUser?.currentPoints ?? 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text("Sử dụng Bookstore Points (Bạn có $availablePoints điểm)", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pointsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Nhập số điểm muốn dùng",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.deepOrange), borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text("1 Point = 1.000₫", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // --- GIAO DIỆN CHỌN PHƯƠNG THỨC THANH TOÁN (NEW) ---
  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.payment, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text("Phương thức thanh toán", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          RadioListTile<int>(
            title: const Text("Thanh toán khi nhận hàng (COD)", style: TextStyle(fontSize: 14)),
            value: 0,
            groupValue: _paymentMethod,
            activeColor: Colors.deepOrange,
            onChanged: (int? value) {
              setState(() => _paymentMethod = value!);
            },
          ),
          RadioListTile<int>(
            title: const Text("Chuyển khoản QR Code", style: TextStyle(fontSize: 14)),
            value: 1,
            groupValue: _paymentMethod,
            activeColor: Colors.deepOrange,
            onChanged: (int? value) {
              setState(() => _paymentMethod = value!);
            },
          ),
        ],
      ),
    );
  }

  // --- GIAO DIỆN TỔNG KẾT ---
  Widget _buildOrderSummarySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chi tiết thanh toán", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng tiền hàng", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              // HIỂN THỊ TỔNG TIỀN GỐC
              Text(formatCurrency.format(_totalOriginalAmount), style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Phí vận chuyển", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              Text(formatCurrency.format(_shippingFee), style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ],
          ),
          if (_totalDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Giảm giá sản phẩm", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                Text("- ${formatCurrency.format(_totalDiscount)}", style: const TextStyle(color: Colors.green, fontSize: 13)),
              ],
            ),
          ],
          // HIỂN THỊ GIẢM GIÁ TỪ ĐIỂM
          if (_pointIsUsed > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sử dụng Bookstore Points", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                Text("- ${formatCurrency.format(_pointDiscount)}", style: const TextStyle(color: Colors.green, fontSize: 13)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  // --- THANH CÔNG CỤ DƯỚI CÙNG ---
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)]),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Tổng thanh toán", style: TextStyle(fontSize: 13)),
                Text(formatCurrency.format(_finalPayment), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ],
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: _isPlacingOrder ? null : _placeOrder,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                color: _isPlacingOrder ? Colors.grey : Colors.deepOrange,
                child: _isPlacingOrder
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Đặt hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}