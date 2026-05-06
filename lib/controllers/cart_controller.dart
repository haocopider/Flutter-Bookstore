import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/storage_helper.dart';
import '../models/book.dart';
import '../models/cart.dart'; // Đảm bảo import đúng nơi chứa class CartItem
import '../models/order.dart';
import 'auth_controller.dart'; // Đảm bảo import class CheckoutItem

class CartController extends GetxController {
  Map<int, CartItem> cartMap = {};
  Map<int, Book> cartProducts = {};
  bool isLoading = false;

  String get _userIdentifier {
    if (Get.isRegistered<AuthController>()) {
      final user = Get.find<AuthController>().currentUser;
      if (user != null) return user.id.toString();
    }
    return 'guest';
  }

  @override
  void onInit() {
    super.onInit();
    loadCartFromStorage();
  }

  void reloadCartForUser() {
    cartMap.clear();
    cartProducts.clear();
    loadCartFromStorage();
  }

  Future<void> loadCartFromStorage() async {
    String? cartData = await StorageHelper.getData('local_cart', identifier: _userIdentifier);

    if (cartData != null) {
      try {
        Map<String, dynamic> decoded = jsonDecode(cartData);
        cartMap = decoded.map((key, value) {
          if (value is int) {
            return MapEntry(int.parse(key), CartItem(id: int.parse(key), quantity: value, isSelected: true));
          }
          return MapEntry(int.parse(key), CartItem.fromJson(value));
        });
      } catch (e) {
        cartMap = {};
      }
    }
    await fetchCartDetails();
  }

  Future<void> _saveToStorage() async {
    String encoded = jsonEncode(cartMap.map((key, value) => MapEntry(key.toString(), value.toJson())));
    await StorageHelper.saveData('local_cart', encoded, identifier: _userIdentifier);
  }

  void addToCart(int bookId, {int quantity = 1}) {
    if (cartMap.containsKey(bookId)) {
      cartMap[bookId]!.quantity += quantity;
    } else {
      cartMap[bookId] = CartItem(id: bookId, quantity: quantity, isSelected: true);
      fetchCartDetails();
    }

    _saveToStorage();
    update(['cart_badge', 'cart_list', 'cart_checkout']);
  }
  void updateQuantity(int bookId, int change) {
    if (cartMap.containsKey(bookId)) {
      int newQuantity = cartMap[bookId]!.quantity + change;

      if (newQuantity <= 0) {
        removeItem(bookId);
      } else {
        cartMap[bookId]!.quantity = newQuantity;
        _saveToStorage();
        update(['cart_list', 'cart_checkout']);
      }
    }
  }

  void removeItem(int bookId) {
    cartMap.remove(bookId);
    cartProducts.remove(bookId);
    _saveToStorage();
    update(['cart_badge', 'cart_list', 'cart_checkout']);
  }


  void toggleSelection(int bookId) {
    if (cartMap.containsKey(bookId)) {
      cartMap[bookId]!.isSelected = !cartMap[bookId]!.isSelected;
      _saveToStorage();
      update(['cart_list', 'cart_checkout']);
    }
  }

  void toggleSelectAll(bool value) {
    cartMap.forEach((key, item) => item.isSelected = value);
    _saveToStorage();
    update(['cart_list', 'cart_checkout']);
  }

  void removeCheckoutItems() {
    cartMap.removeWhere((key, item) => item.isSelected);
    _saveToStorage();
    update(['cart_badge', 'cart_list', 'cart_checkout']);
  }

  List<CheckoutItem> get selectedCheckoutItems {
    List<CheckoutItem> items = [];
    cartMap.forEach((bookId, item) {
      if (item.isSelected && cartProducts.containsKey(bookId)) {
        final book = cartProducts[bookId]!;

        // Tính toán giá khuyến mãi
        double finalPrice = book.price;
        if (book.promotion != null) {
          if (book.promotion!.discountType == 1) {
            finalPrice = book.price * (1 - book.promotion!.discountValue / 100);
          } else {
            finalPrice = book.price - book.promotion!.discountValue;
          }
        }

        items.add(CheckoutItem(
          book: book,
          quantity: item.quantity,
          originalPrice: book.price,
          finalPrice: finalPrice,
        ));
      }
    });
    return items;
  }

  double get totalPrice {
    double total = 0;
    cartMap.forEach((bookId, item) {
      if (item.isSelected) {
        final book = cartProducts[bookId];
        if (book != null) {
          double finalPrice = book.price;
          if (book.promotion != null) {
            if (book.promotion!.discountType == 1) {
              finalPrice = book.price * (1 - book.promotion!.discountValue / 100);
            } else {
              finalPrice = book.price - book.promotion!.discountValue;
            }
          }
          total += finalPrice * item.quantity;
        }
      }
    });
    return total;
  }

  Future<void> fetchCartDetails() async {
    if (cartMap.isEmpty) {
      cartProducts.clear();
      update(['cart_list', 'cart_checkout']);
      return;
    }

    isLoading = true;
    update(['cart_list']);

    try {
      List<int> ids = cartMap.keys.toList();
      final resultsList = await BookSnapshot.fetchLatestCartDetails(ids);
      if (resultsList.isNotEmpty) {
        cartProducts = {for (var book in resultsList) book.id: book};
      }
    } catch (e) {
      print("Lỗi fetch chi tiết giỏ hàng: $e");
    } finally {
      isLoading = false;
      update(['cart_list', 'cart_checkout']);
    }
  }
}