import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart'; // Sử dụng bảng màu chung của nhóm
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    final productIds = cart.items.keys.toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Giỏ Hàng',
        showBackButton: false,
        centerTitle: true,
      ),
      // LOGIC: Nếu giỏ hàng trống hiện giao diện Empty, ngược lại hiện danh sách
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, i) => Dismissible(
                      // TÍNH NĂNG: Vuốt để xóa (Swipe to delete)
                      key: ValueKey(cartItems[i].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) {
                        // Gọi hàm xóa món khỏi giỏ hàng
                        cart.decrementQuantity(productIds[i]);
                        // Lưu ý: Nếu muốn xóa sạch món đó luôn thay vì giảm 1,
                        // bạn có thể thêm hàm remove hoàn toàn vào Provider.
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.fastfood,
                                color: AppColors.primary),
                          ),
                          title: Text(
                            cartItems[i].title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${cartItems[i].price.toInt()} đ x ${cartItems[i].quantity}',
                          ),
                          trailing: Container(
                            width: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.red, size: 18),
                                  onPressed: () =>
                                      cart.decrementQuantity(productIds[i]),
                                ),
                                Text('${cartItems[i].quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.green, size: 18),
                                  onPressed: () =>
                                      cart.incrementQuantity(productIds[i]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Thanh Tổng tiền và Nút Thanh toán
                _buildBottomSummary(context, cart),
              ],
            ),
    );
  }

  // 1. Giao diện khi giỏ hàng TRỐNG (Empty State)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 120, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            'Giỏ hàng đang trống!',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text('Vui lòng chọn món ăn để tiếp tục thanh toán.'),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/main'), // Điều hướng về Home
            child: const Text('MUA SẮM NGAY',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 2. Widget Summary dưới cùng
  Widget _buildBottomSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tổng cộng:',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  '${cart.totalAmount.toInt()} đ',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'THANH TOÁN',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
