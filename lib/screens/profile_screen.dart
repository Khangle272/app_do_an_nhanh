import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/screens/order_history_screen.dart';
import 'package:app_do_an_nhanh/screens/order_tracking_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: AppColors.primary),
                ),
                SizedBox(height: 15),
                Text(
                  'Nhóm Trưởng IT',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  'nhomtruong@student.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu các lựa chọn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                _buildProfileItem(
                  icon: Icons.history,
                  title: 'Đơn hàng của tôi',
                  subtitle: 'Xem danh sách đơn hàng đã đặt',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Theo dõi đơn đang giao',
                  subtitle: 'Xem trạng thái đơn hiện tại',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const OrderTrackingScreen(paymentMethod: 1),
                      ),
                    );
                  },
                ),
                _buildProfileItem(
                  icon: Icons.location_on_outlined,
                  title: 'Địa chỉ của tôi',
                  subtitle: 'Quản lý địa chỉ nhận hàng',
                  onTap: () {},
                ),
                _buildProfileItem(
                  icon: Icons.payment_outlined,
                  title: 'Phương thức thanh toán',
                  subtitle: 'Thẻ ngân hàng, Ví MoMo...',
                  onTap: () {},
                ),
                _buildProfileItem(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  subtitle: 'Thông báo, bảo mật, ngôn ngữ',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                // Nút Đăng xuất
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProfileItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200)),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ),
  );
}
