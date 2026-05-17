import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_do_an_nhanh/providers/cart_provider.dart';
import 'package:app_do_an_nhanh/providers/order_provider.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/widgets/primary_button.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/models/order_history_model.dart';
import 'package:app_do_an_nhanh/screens/order_tracking_screen.dart';
import 'package:app_do_an_nhanh/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  int _selectedPayment = 1;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thanh toán',
        onBackPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Họ và tên người nhận',
                prefixIcon: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Số nhà, tên đường, phường...',
                prefixIcon: Icon(Icons.location_on, color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Tiền mặt (COD)'),
              leading: Radio<int>(
                value: 1,
                groupValue: _selectedPayment,
                onChanged: (value) => setState(() => _selectedPayment = value!),
              ),
            ),
            ListTile(
              title: const Text('Ví điện tử MoMo'),
              leading: Radio<int>(
                value: 2,
                groupValue: _selectedPayment,
                onChanged: (value) => setState(() => _selectedPayment = value!),
              ),
            ),
            const Spacer(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền:', style: TextStyle(fontSize: 18)),
                Text(
                  '${cart.totalAmount.toInt()} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'XÁC NHẬN ĐẶT HÀNG',
              onPressed: () async {
                // 1. Kiểm tra dữ liệu nhập
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập tên người nhận!')),
                  );
                  return;
                }
                if (_phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập số điện thoại!')),
                  );
                  return;
                }
                if (_addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập địa chỉ giao hàng!')),
                  );
                  return;
                }

                final totalStr = '${cart.totalAmount.toInt()} đ';

                // 2. Tạo đơn hàng trên Firestore
                final orderService = OrderService();
                final docRef = await orderService.createOrder({
                  'items': cart.items.values
                      .map((i) => {
                            'title': i.title,
                            'quantity': i.quantity,
                            'price': i.price,
                          })
                      .toList(),
                  'totalPrice': cart.totalAmount,
                  'name': _nameController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  'address': _addressController.text.trim(),
                  'paymentMethod': _selectedPayment,
                  'status': 'Đang chuẩn bị',
                  'createdAt': DateTime.now(),
                });

                // 3. Tạo bản ghi local để hiển thị nhanh
                final now = DateTime.now();
                final dateStr =
                    '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                final order = OrderHistoryItem(
                  code: docRef.id, // dùng document ID làm mã đơn
                  date: dateStr,
                  itemsSummary: cart.items.values
                      .map((i) => '${i.quantity}x ${i.title}')
                      .join(', '),
                  total: totalStr,
                  status: 'Đang chuẩn bị',
                  paymentMethod: _selectedPayment,
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                  address: _addressController.text.trim(),
                );

                // 🟢 gọi addOrder, không gán kết quả
                Provider.of<OrderProvider>(context, listen: false).addOrder(
                  order,
                  deliveryDuration: const Duration(minutes: 30),
                );

                // 4. Clear giỏ hàng
                cart.clearCart();

                // 5. Tránh lỗi context sau async
                if (!mounted) return;

                // 6. Điều hướng sang OrderTrackingScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(
                      orderId: docRef.id, // ✅ truyền document ID
                      paymentMethod: _selectedPayment,
                      name: order.name,
                      phone: order.phone,
                      address: order.address,
                      totalAmount: totalStr,
                    ),
                  ),
                  (route) => false,
                );
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
