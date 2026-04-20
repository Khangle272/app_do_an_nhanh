import 'package:app_do_an_nhanh/screens/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();

  // Bước 1: Sửa String thành int (1: Tiền mặt, 2: MoMo) để khớp với trang Tracking
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
              'Địa chỉ giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // Bước 2: Cập nhật ListTile cho Tiền mặt (value: 1)
            ListTile(
              title: const Text('Tiền mặt (COD)'),
              leading: Radio<int>(
                value: 1,
                groupValue: _selectedPayment,
                onChanged: (value) => setState(() => _selectedPayment = value!),
              ),
            ),

            // Bước 3: Cập nhật ListTile cho MoMo (value: 2)
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
                  '${cart.totalAmount} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kiểm tra địa chỉ trước khi đặt
                if (_addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vui lòng nhập địa chỉ giao hàng!')),
                  );
                  return;
                }

                cart.clearCart();

                // Bước 4: Chuyển trang (Đã bỏ const và truyền biến int vào)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderTrackingScreen(paymentMethod: _selectedPayment),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'XÁC NHẬN ĐẶT HÀNG',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
