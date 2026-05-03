import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/providers/cart_provider.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/screens/checkout_screen.dart';

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
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, i) => Dismissible(
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
                        cart.decrementQuantity(productIds[i]);
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
                _buildBottomSummary(context, cart),
              ],
            ),
    );
  }

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
            onPressed: () => Navigator.pushNamed(context, '/main'),
            child: const Text('MUA SẮM NGAY',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(),
                        ),
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
