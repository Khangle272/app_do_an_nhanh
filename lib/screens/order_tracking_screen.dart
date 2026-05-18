import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/services/order_service.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final int paymentMethod;
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
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Theo dõi đơn',
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
          }
        },
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Vui lòng liên hệ quán qua số hỗ trợ trên app.'),
                ),
              );
            },
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

          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được trạng thái đơn',
              message: 'Kiểm tra kết nối mạng rồi mở lại màn hình này.',
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _StateMessage(
              icon: Icons.search_off_outlined,
              title: 'Không tìm thấy đơn hàng',
              message:
                  'Đơn hàng có thể đã bị xóa hoặc chưa đồng bộ lên Firestore.',
            );
          }

          final order = snapshot.data!.data() as Map<String, dynamic>;
          final status =
              _safeString(order['status'], defaultValue: 'Đang chuẩn bị');
          final paymentLabel =
              _paymentLabel(order['paymentMethod'], fallback: paymentMethod);
          final totalLabel =
              _moneyLabel(order['totalPrice'], fallback: totalAmount);
          final createdAt = _formatDate(order['createdAt']);
          final itemsSummary =
              _buildItemsSummary(order['items'] as List<dynamic>? ?? const []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(
                  orderId: orderId,
                  status: status,
                  createdAt: createdAt,
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Tiến trình đơn hàng',
                  child: _StatusTimeline(status: status),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Tóm tắt đơn',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Món đã đặt',
                        value: itemsSummary,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Thanh toán',
                        value: paymentLabel,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Tổng cộng',
                        value: totalLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Giao đến',
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Người nhận',
                        value: name,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Số điện thoại',
                        value: phone,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Địa chỉ',
                        value: address,
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

class _HeaderCard extends StatelessWidget {
  final String orderId;
  final String status;
  final String createdAt;

  const _HeaderCard({
    required this.orderId,
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF0E5A2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.local_shipping_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đơn hàng của bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã đơn: $orderId',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cập nhật lúc: $createdAt',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = <_TimelineStepData>[
      _TimelineStepData(
        icon: Icons.restaurant,
        title: 'Chuẩn bị',
        description: 'Quán đang xác nhận và chế biến đơn hàng.',
        active: status == 'Đang chuẩn bị' ||
            status == 'Đang giao' ||
            status == 'Đã giao',
      ),
      _TimelineStepData(
        icon: Icons.pedal_bike,
        title: 'Đang giao',
        description: 'Đơn hàng đã rời quán và đang trên đường đến bạn.',
        active: status == 'Đang giao' || status == 'Đã giao',
      ),
      _TimelineStepData(
        icon: Icons.home,
        title: 'Đã giao',
        description: 'Đơn hàng đã được giao thành công.',
        active: status == 'Đã giao',
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: step.active
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.active
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    step.icon,
                    size: 18,
                    color: step.active ? AppColors.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color:
                              step.active ? Colors.black : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index != steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
                child: Container(
                  width: 2,
                  height: 22,
                  color: index == 0 && !steps[1].active
                      ? Colors.grey.shade300
                      : AppColors.primary.withOpacity(0.35),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _TimelineStepData {
  final IconData icon;
  final String title;
  final String description;
  final bool active;

  const _TimelineStepData({
    required this.icon,
    required this.title,
    required this.description,
    required this.active,
  });
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

String _safeString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  final text = value.toString().trim();
  return text.isEmpty ? defaultValue : text;
}

String _moneyLabel(dynamic value, {String fallback = ''}) {
  if (value is num) {
    return '${value.toInt()} đ';
  }

  final text = _safeString(value, defaultValue: fallback);
  if (text.isEmpty) return fallback;
  if (text.endsWith('đ')) return text;
  return '$text đ';
}

String _formatDate(dynamic value) {
  DateTime? dateTime;

  if (value is Timestamp) {
    dateTime = value.toDate();
  } else if (value is DateTime) {
    dateTime = value;
  }

  if (dateTime == null) {
    return 'Đang chờ cập nhật thời gian';
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year - $hour:$minute';
}

String _buildItemsSummary(List<dynamic> items) {
  if (items.isEmpty) return 'Không có thông tin sản phẩm';

  final summary = items.map((item) {
    if (item is Map) {
      final quantity = item['quantity'] ?? 1;
      final title = item['title'] ?? 'Sản phẩm';
      return '$quantity x $title';
    }
    return item.toString();
  }).toList();

  if (summary.length <= 2) {
    return summary.join(', ');
  }

  return '${summary.take(2).join(', ')} +${summary.length - 2} món';
}

String _paymentLabel(dynamic value, {required int fallback}) {
  final paymentMethod = value is int ? value : fallback;
  return switch (paymentMethod) {
    1 => 'Tiền mặt (COD)',
    2 => 'Ví MoMo',
    _ => 'Thanh toán khác',
  };
}

Color _statusColor(String status) {
  return switch (status) {
    'Đã giao' => Colors.green,
    'Đang giao' => Colors.orange,
    'Đã hủy' => Colors.red,
    _ => Colors.blueGrey,
  };
}
