import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';

class OrderTrackingScreen extends StatelessWidget {
  final int paymentMethod; // 1: COD, 2: MoMo
  final String name;
  final String phone;
  final String address;
  final String totalAmount; // nhận từ OrderHistoryItem

  const OrderTrackingScreen({
    super.key,
    required this.paymentMethod,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Tính thời gian giao hàng dự kiến
    DateTime orderTime = DateTime.now();
    DateTime startTime = orderTime.add(const Duration(minutes: 30));
    DateTime endTime = orderTime.add(const Duration(minutes: 40));

    String formatTime(DateTime time) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }

    String deliveryTimeRange =
        "${formatTime(startTime)} - ${formatTime(endTime)}";

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
            // 1. Thời gian giao hàng dự kiến
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      deliveryTimeRange,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Text('Đúng giờ',
                          style: TextStyle(
                              color: AppColors.primary,
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
                          child:
                              Container(height: 3, color: AppColors.primary)),
                      const Icon(Icons.pedal_bike,
                          color: Colors.grey, size: 20),
                      Expanded(child: Container(height: 3, color: Colors.grey)),
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
                  backgroundColor: AppColors.primary,
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
                      Icon(
                          paymentMethod == 1
                              ? Icons.payments
                              : Icons.credit_card,
                          color: paymentMethod == 1
                              ? const Color.fromARGB(255, 15, 185, 15)
                              : Colors.blue,
                          size: 20),
                      const SizedBox(width: 10),
                      Text(paymentMethod == 1 ? 'Tiền mặt (COD)' : 'Ví MoMo',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng cộng',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(totalAmount,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(thickness: 8, color: AppColors.background),

            // 4. Thông tin giao hàng khách nhập
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 10),
                      Text(name),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 10),
                      Text(phone),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 10),
                      Text(address),
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
