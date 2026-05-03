import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';

class OrderTrackingScreen extends StatelessWidget {
  // Thêm biến này để nhận dữ liệu từ Checkout gửi sang
  final int paymentMethod; // 1: Tiền mặt, 2: MoMo

  const OrderTrackingScreen({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Theo dõi đơn',
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Cần hỗ trợ?'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Phần Trạng thái Timeline Ngang
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('16:30 - 16:40',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Text('Đúng giờ',
                          style: TextStyle(
                              color: AppColors
                                  .primary, // Đổi sang màu đỏ chuẩn của bạn
                              fontWeight: FontWeight.bold)),
                      Text(' • Bếp đang chuẩn bị đơn của bạn.'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.restaurant,
                          color: AppColors.primary, size: 20),
                      Expanded(
                          child: Container(
                              height: 3,
                              color: AppColors.primary)), // Đổi sang RED
                      const Icon(Icons.pedal_bike,
                          color: Colors.grey, size: 20),
                      Expanded(
                          child: Container(
                              height: 3, color: Colors.grey.shade300)),
                      const Icon(Icons.home, color: Colors.grey, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(thickness: 8, color: AppColors.background),

            // 2. Thông tin Quán ăn
            const ListTile(
              leading: CircleAvatar(
                  backgroundColor: AppColors.primary, // Đổi sang RED
                  child: Icon(Icons.store, color: Colors.white)),
              title: Text('FastFood',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('123A Hậu Giang'),
              trailing: Icon(Icons.favorite_border),
            ),
            const Divider(),

            // 3. Tóm tắt thanh toán
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // LOGIC: Thay đổi Icon và Chữ dựa trên paymentMethod
                      Icon(
                          paymentMethod == 1
                              ? Icons.payments
                              : Icons.credit_card,
                          color:
                              paymentMethod == 1 ? Colors.orange : Colors.blue,
                          size: 20),
                      const SizedBox(width: 10),
                      Text(paymentMethod == 1 ? 'Tiền mặt (COD)' : 'Ví MoMo',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng cộng',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('115.000đ',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors
                                  .primary)), // Đổi sang RED cho nổi bật
                    ],
                  ),
                ],
              ),
            ),
            const Divider(thickness: 8, color: AppColors.background),

            // 4. Địa chỉ giao hàng
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.radio_button_checked,
                          color: AppColors.primary, size: 16), // Đổi sang RED
                      SizedBox(width: 10),
                      Text('FastFood - 123A Hậu Giang'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: AppColors.primary, size: 16), // Đổi sang RED
                      SizedBox(width: 10),
                      Text('Chung cư Tân Phú - Tòa B'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
