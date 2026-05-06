class CartItem {
  final int id;
  int quantity;
  bool isSelected;

  CartItem({required this.id, required this.quantity, this.isSelected = false});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }
}
