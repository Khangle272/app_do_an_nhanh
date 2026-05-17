import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/services/order_service.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId; // cần truyền document ID từ Firestore
  final int paymentMethod; // 1: COD, 2: MoMo
  final String name;
  final String phone;
  final String address;
  final String totalAmount;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalAmount,
  });

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: OrderService().listenOrderStatus(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy đơn hàng"));
          }

          final order = snapshot.data!;
          final status = order['status'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Trạng thái đơn hàng real-time
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Trạng thái: $status",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusTimeline(status: status),
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
                          Text(paymentMethod == 1
                              ? 'Tiền mặt (COD)'
                              : 'Ví MoMo'),
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
          );
        },
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    Color prepColor = status == "Đang chuẩn bị" ||
            status == "Đang giao" ||
            status == "Đã giao"
        ? AppColors.primary
        : Colors.grey;
    Color shipColor = status == "Đang giao" || status == "Đã giao"
        ? AppColors.primary
        : Colors.grey;
    Color doneColor = status == "Đã giao" ? AppColors.primary : Colors.grey;

    return Row(
      children: [
        Icon(Icons.restaurant, color: prepColor, size: 20),
        Expanded(child: Container(height: 3, color: prepColor)),
        Icon(Icons.pedal_bike, color: shipColor, size: 20),
        Expanded(child: Container(height: 3, color: shipColor)),
        Icon(Icons.home, color: doneColor, size: 20),
      ],
    );
  }
}
