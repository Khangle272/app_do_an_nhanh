import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, int price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (ex) => CartItem(
          id: ex.id,
          title: ex.title,
          price: ex.price,
          quantity: ex.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price.toDouble(),
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (ex) => CartItem(
          id: ex.id,
          title: ex.title,
          price: ex.price,
          quantity: ex.quantity + 1,
        ),
      );
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (ex) => CartItem(
          id: ex.id,
          title: ex.title,
          price: ex.price,
          quantity: ex.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
