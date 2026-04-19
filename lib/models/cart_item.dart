import 'package:flutter/foundation.dart';

class CartItem {
  final String id;       // ID của món đồ trong giỏ (thường dùng DateTime để tạo)
  final String title;    // Tên món ăn
  final int quantity;    // Số lượng khách đặt
  final double price;    // Giá tiền trên 1 món

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}