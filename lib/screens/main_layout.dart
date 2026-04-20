import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart'; // Import thêm file này để chuyển trang

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Định nghĩa danh sách màn hình ngay trong hàm build để có thể sử dụng Navigator dễ dàng
    final List<Widget> _screens = [
      const HomeScreen(),
      const SearchScreen(),
      const CartScreen(),
      _buildProfileTab(), // Gọi hàm xây dựng giao diện Profile ở đây
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }

  // Bước 2: Hàm xây dựng giao diện Profile (Tài khoản)
  Widget _buildProfileTab() {
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
                  subtitle: 'Theo dõi các đơn hàng đang giao',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // TRUYỀN THÊM DÒNG NÀY VÀO ĐỂ HẾT LỖI ĐỎ Ở MAIN_LAYOUT
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

  // Widget phụ để tạo các dòng Menu nhanh hơn
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
              color: AppColors.primary.withOpacity(0.1),
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
}
