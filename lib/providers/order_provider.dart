import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/order_history_model.dart';

class OrderProvider with ChangeNotifier {
  final List<OrderHistoryItem> _orders = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderHistoryItem> get orders => _orders;

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  /// Thêm đơn hàng mới, kèm thời gian giao hàng (ví dụ 30 phút)
  void addOrder(OrderHistoryItem order, {Duration? deliveryDuration}) {
    _orders.add(order);
    notifyListeners();

    // Nếu có thời gian giao hàng, sau khi hết hạn sẽ tự đổi trạng thái
    if (deliveryDuration != null) {
      Timer(deliveryDuration, () {
        final index = _orders.indexOf(order);
        if (index != -1) {
          _orders[index] = OrderHistoryItem(
            userId: order.userId,
            code: order.code,
            date: order.date,
            itemsSummary: order.itemsSummary,
            total: order.total,
            status: 'Đã giao', // ✅ đổi trạng thái
            paymentMethod: order.paymentMethod,
            name: order.name,
            phone: order.phone,
            address: order.address,
          );
          notifyListeners();
        }
      });
    }
  }

  /// Lấy đơn hàng mới nhất
  OrderHistoryItem? get latestOrder {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    for (var index = _orders.length - 1; index >= 0; index--) {
      final order = _orders[index];
      if (order.userId == userId) {
        return order;
      }
    }

    return null;
  }
}
