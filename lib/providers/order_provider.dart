import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_history_model.dart';

class OrderProvider with ChangeNotifier {
  final List<OrderHistoryItem> _orders = [];

  List<OrderHistoryItem> get orders => _orders;

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
    if (_orders.isEmpty) return null;
    return _orders.last;
  }
}
