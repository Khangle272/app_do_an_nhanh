import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/providers/order_provider.dart';
import 'package:app_do_an_nhanh/screens/order_history_screen.dart';
import 'package:app_do_an_nhanh/screens/admin_order_management_screen.dart';
import 'package:app_do_an_nhanh/screens/admin_food_management_screen.dart';
import 'package:app_do_an_nhanh/services/auth_service.dart';
import 'package:app_do_an_nhanh/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        await _userService.updateAvatar(File(pickedFile.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật ảnh thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải ảnh: $e')),
          );
        }
      }
    }
  }

  void _showEditProfileDialog(Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final phoneController =
        TextEditingController(text: userData['phone'] ?? '');
    final addressController =
        TextEditingController(text: userData['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa thông tin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _userService.updateUserInfo(
                    nameController.text.trim(),
                    phoneController.text.trim(),
                    addressController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi cập nhật: $e')),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAddressDialog(String currentAddress) {
    final addressController = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Địa chỉ của tôi'),
          content: TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ giao hàng',
              hintText: 'Số nhà, tên đường, phường...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _userService
                      .updateUserAddress(addressController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cập nhật địa chỉ thành công')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi cập nhật: $e')),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPaymentDialog(int currentPayment) {
    int selectedPayment = currentPayment;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Phương thức thanh toán'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    value: 1,
                    groupValue: selectedPayment,
                    onChanged: (value) =>
                        setState(() => selectedPayment = value ?? 1),
                    title: const Text('Tiền mặt (COD)'),
                  ),
                  RadioListTile<int>(
                    value: 2,
                    groupValue: selectedPayment,
                    onChanged: (value) =>
                        setState(() => selectedPayment = value ?? 1),
                    title: const Text('Ví điện tử MoMo'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _userService.updatePaymentMethod(selectedPayment);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cập nhật thanh toán thành công')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi cập nhật: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _paymentMethodLabel(dynamic value) {
    switch (value) {
      case 1:
        return 'Tiền mặt (COD)';
      case 2:
        return 'Ví điện tử MoMo';
      default:
        return 'Chưa chọn';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final avatarUrl = userData['avatarUrl'];
        final name = userData['name'] ?? 'Chưa cập nhật tên';
        final email = userData['email'] ?? '';
        final role = (userData['role'] ?? '').toString().toLowerCase();
        final isAdmin = role == 'admin';
        final address = (userData['address'] ?? '').toString();
        final paymentMethod = userData['paymentMethod'];
        final paymentLabel = _paymentMethodLabel(paymentMethod);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Profile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? const Icon(Icons.person,
                                  size: 60, color: AppColors.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 20, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                          onPressed: () => _showEditProfileDialog(userData),
                        ),
                      ],
                    ),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.white70),
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
                    if (isAdmin)
                      _buildProfileItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Quản lý đơn hàng',
                        subtitle: 'Cập nhật trạng thái đơn của khách',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminOrderManagementScreen(),
                            ),
                          );
                        },
                      ),
                    if (isAdmin)
                      _buildProfileItem(
                        icon: Icons.fastfood_outlined,
                        title: 'Quản lý món ăn',
                        subtitle: 'Thêm, sửa, xóa món ăn trên app',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminFoodManagementScreen(),
                            ),
                          );
                        },
                      ),
                    _buildProfileItem(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ của tôi',
                      subtitle: address.isEmpty
                          ? 'Chưa có địa chỉ mặc định'
                          : address,
                      onTap: () => _showEditAddressDialog(address),
                    ),
                    _buildProfileItem(
                      icon: Icons.payment_outlined,
                      title: 'Phương thức thanh toán',
                      subtitle: paymentLabel,
                      onTap: () => _showEditPaymentDialog(
                        paymentMethod is int ? paymentMethod : 1,
                      ),
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
                      onTap: () async {
                        Provider.of<OrderProvider>(context, listen: false)
                            .clearOrders();
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
}
