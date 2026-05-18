import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/screens/order_tracking_screen.dart';
import 'package:app_do_an_nhanh/services/order_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Lịch sử đơn hàng',
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService().getOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được lịch sử đơn',
              message: 'Kiểm tra lại kết nối hoặc đăng nhập rồi thử lại.',
            );
          }

          final orders = (snapshot.data?.docs ?? const [])
            ..sort((a, b) {
              final aTime = _createdAtValue(a);
              final bTime = _createdAtValue(b);
              return bTime.compareTo(aTime);
            });
          if (orders.isEmpty) {
            return const _EmptyHistory();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox(height: 12)
                : const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _HistoryHeader();
              }

              final order = orders[index - 1];
              return _OrderHistoryCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.history, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng gần đây',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Xem lại đơn đã đặt và theo dõi trạng thái giao hàng.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final data = order.data() as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? const []);
    final status = _safeString(data['status'], defaultValue: 'Đang chuẩn bị');
    final itemsSummary = _buildItemsSummary(items);
    final paymentMethod = _paymentLabel(data['paymentMethod']);
    final totalPrice = _formatMoney(data['totalPrice']);
    final createdAt = _formatDateTime(data['createdAt']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(
                orderId: order.id,
                paymentMethod: data['paymentMethod'] is int
                    ? data['paymentMethod'] as int
                    : 1,
                name: _safeString(data['name']),
                phone: _safeString(data['phone']),
                address: _safeString(data['address']),
                totalAmount: totalPrice,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã đơn: ${order.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          createdAt,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                itemsSummary,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.payments_outlined,
                    label: paymentMethod,
                  ),
                  _MetaChip(
                    icon: Icons.shopping_bag_outlined,
                    label: '${items.length} món',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Tổng tiền',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    totalPrice,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId: order.id,
                          paymentMethod: data['paymentMethod'] is int
                              ? data['paymentMethod'] as int
                              : 1,
                          name: _safeString(data['name']),
                          phone: _safeString(data['phone']),
                          address: _safeString(data['address']),
                          totalAmount: totalPrice,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Theo dõi đơn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: Icons.receipt_long_outlined,
      title: 'Bạn chưa có đơn hàng nào',
      message: 'Đơn hàng sau khi thanh toán sẽ hiển thị ở đây để bạn theo dõi.',
    );
  }
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

String _formatMoney(dynamic value) {
  if (value is num) {
    final number = value.toInt().toString();
    return '$number đ';
  }

  final text = _safeString(value);
  if (text.isEmpty) return '0 đ';
  if (text.endsWith('đ')) return text;
  return '$text đ';
}

String _formatDateTime(dynamic value) {
  DateTime? dateTime;

  if (value is Timestamp) {
    dateTime = value.toDate();
  } else if (value is DateTime) {
    dateTime = value;
  }

  if (dateTime == null) {
    return 'Chưa có thời gian tạo đơn';
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

  final mapped = items.map((item) {
    if (item is Map) {
      final quantity = item['quantity'] ?? 1;
      final title = item['title'] ?? 'Sản phẩm';
      return '$quantity x $title';
    }
    return item.toString();
  }).toList();

  if (mapped.length <= 2) {
    return mapped.join(', ');
  }

  return '${mapped.take(2).join(', ')} +${mapped.length - 2} món';
}

int _createdAtValue(QueryDocumentSnapshot order) {
  final data = order.data() as Map<String, dynamic>;
  final createdAt = data['createdAt'];

  if (createdAt is Timestamp) {
    return createdAt.millisecondsSinceEpoch;
  }

  if (createdAt is DateTime) {
    return createdAt.millisecondsSinceEpoch;
  }

  return 0;
}

String _paymentLabel(dynamic value) {
  if (value is int) {
    return switch (value) {
      1 => 'Tiền mặt (COD)',
      2 => 'Ví MoMo',
      _ => 'Thanh toán khác',
    };
  }
  return _safeString(value, defaultValue: 'Chưa xác định');
}

Color _statusColor(String status) {
  return switch (status) {
    'Đã giao' => Colors.green,
    'Đang giao' => Colors.orange,
    'Đã hủy' => Colors.red,
    _ => Colors.blueGrey,
  };
}
