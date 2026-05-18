import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/screens/order_tracking_screen.dart';
import 'package:app_do_an_nhanh/services/order_service.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState
    extends State<AdminOrderManagementScreen> {
  final OrderService _orderService = OrderService();
  final Set<String> _updatingOrderIds = {};
  final List<String> _statusOptions = const [
    'Đang chuẩn bị',
    'Đang giao',
    'Đã giao',
  ];

  Future<void> _updateStatus(String orderId, String newStatus) async {
    setState(() => _updatingOrderIds.add(orderId));
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái đơn.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingOrderIds.remove(orderId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Quản lý đơn hàng',
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _orderService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được đơn hàng',
              message: 'Kiểm tra kết nối rồi thử lại sau.',
            );
          }

          final orders = snapshot.data?.docs ?? const [];
          if (orders.isEmpty) {
            return const _StateMessage(
              icon: Icons.receipt_long_outlined,
              title: 'Chưa có đơn hàng',
              message: 'Đơn mới sẽ hiển thị tại đây để quản lý.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final items = (data['items'] as List<dynamic>? ?? const []);
              final status =
                  _safeString(data['status'], defaultValue: 'Đang chuẩn bị');
              final createdAt = _formatDateTime(data['createdAt']);
              final itemsSummary = _buildItemsSummary(items);
              final paymentLabel = _paymentLabel(data['paymentMethod']);
              final totalPrice = _formatMoney(data['totalPrice']);
              final dropdownValue = _statusOptions.contains(status)
                  ? status
                  : _statusOptions.first;
              final isUpdating = _updatingOrderIds.contains(order.id);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
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
                    const SizedBox(height: 12),
                    Text(
                      itemsSummary,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _safeString(data['name'], defaultValue: '---'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _safeString(data['phone'], defaultValue: '---'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _safeString(data['address'], defaultValue: '---'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: paymentLabel,
                        ),
                        _MetaChip(
                          icon: Icons.shopping_bag_outlined,
                          label: '${items.length} món',
                        ),
                        _MetaChip(
                          icon: Icons.receipt_long_outlined,
                          label: totalPrice,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: dropdownValue,
                            decoration: const InputDecoration(
                              labelText: 'Trạng thái',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _statusOptions
                                .map((status) => DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: isUpdating
                                ? null
                                : (value) {
                                    if (value == null || value == status) {
                                      return;
                                    }
                                    _updateStatus(order.id, value);
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (isUpdating)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                        label: const Text('Xem chi tiết'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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

String _buildItemsSummary(List<dynamic> items) {
  if (items.isEmpty) return 'Không có món.';
  final summary = items
      .map((item) {
        final map = item as Map<String, dynamic>;
        final title = map['title']?.toString() ?? '';
        final quantity = map['quantity']?.toString() ?? '1';
        if (title.isEmpty) return null;
        return '$quantity x $title';
      })
      .whereType<String>()
      .join(', ');
  return summary.isEmpty ? 'Không có món.' : summary;
}

String _formatMoney(dynamic value) {
  if (value is num) {
    return '${value.toInt()} đ';
  }
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return '0 đ';
}

String _formatDateTime(dynamic value) {
  if (value is Timestamp) {
    final dateTime = value.toDate();
    return _formatDate(dateTime);
  }
  if (value is DateTime) {
    return _formatDate(value);
  }
  return '---';
}

String _formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year - $hour:$minute';
}

String _paymentLabel(dynamic value) {
  final method = value is int ? value : int.tryParse(value?.toString() ?? '1');
  if (method == 2) return 'Ví MoMo';
  return 'Tiền mặt (COD)';
}

Color _statusColor(String status) {
  switch (status) {
    case 'Đang giao':
      return Colors.orange;
    case 'Đã giao':
      return Colors.green;
    default:
      return AppColors.primary;
  }
}
