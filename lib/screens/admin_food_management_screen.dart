import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:app_do_an_nhanh/models/food_model.dart';
import 'package:app_do_an_nhanh/services/food_service.dart';

class AdminFoodManagementScreen extends StatefulWidget {
  const AdminFoodManagementScreen({super.key});

  @override
  State<AdminFoodManagementScreen> createState() =>
      _AdminFoodManagementScreenState();
}

class _AdminFoodManagementScreenState extends State<AdminFoodManagementScreen> {
  final FoodService _foodService = FoodService();
  final Set<String> _deletingFoodIds = {};

  Future<void> _confirmDelete(Food food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa món ăn'),
          content: Text('Bạn chắc muốn xóa "${food.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _deletingFoodIds.add(food.id));
    try {
      await _foodService.deleteFood(food.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa món ăn.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingFoodIds.remove(food.id));
      }
    }
  }

  Future<void> _showFoodFormDialog({Food? food}) async {
    final isEditing = food != null;
    final formKey = GlobalKey<FormState>();
    final rootContext = context;
    final nameController = TextEditingController(text: food?.name ?? '');
    final imageUrlController =
        TextEditingController(text: food?.imageUrl ?? '');
    final priceController =
        TextEditingController(text: food?.price.toString() ?? '');
    final descriptionController =
        TextEditingController(text: food?.description ?? '');
    final ratingController =
        TextEditingController(text: food?.rating.toString() ?? '5');

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> handleSave() async {
              if (!formKey.currentState!.validate()) return;

              final priceText = priceController.text.trim();
              final ratingText = ratingController.text.trim();
              final parsedPrice =
                  double.tryParse(priceText.replaceAll(',', '.'));
              final parsedRating =
                  double.tryParse(ratingText.replaceAll(',', '.')) ?? 5.0;

              if (parsedPrice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giá không hợp lệ.')),
                );
                return;
              }

              setDialogState(() => isSaving = true);
              try {
                if (isEditing) {
                  await _foodService.updateFood(
                    id: food!.id,
                    name: nameController.text.trim(),
                    imageUrl: imageUrlController.text.trim(),
                    price: parsedPrice,
                    description: descriptionController.text.trim(),
                    rating: parsedRating,
                  );
                } else {
                  await _foodService.addFood(
                    name: nameController.text.trim(),
                    imageUrl: imageUrlController.text.trim(),
                    price: parsedPrice,
                    description: descriptionController.text.trim(),
                    rating: parsedRating,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing ? 'Đã cập nhật món ăn.' : 'Đã thêm món ăn.',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(content: Text('Lỗi lưu: $e')),
                );
              } finally {
                if (mounted) {
                  setDialogState(() => isSaving = false);
                }
              }
            }

            return AlertDialog(
              title: Text(isEditing ? 'Sửa món ăn' : 'Thêm món ăn'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Tên món'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập tên món.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: imageUrlController,
                        decoration:
                            const InputDecoration(labelText: 'Link hình ảnh'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập link hình ảnh.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Giá'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập giá.';
                          }
                          final parsed = double.tryParse(
                            value.trim().replaceAll(',', '.'),
                          );
                          if (parsed == null || parsed <= 0) {
                            return 'Giá không hợp lệ.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: ratingController,
                        decoration: const InputDecoration(
                          labelText: 'Đánh giá (0-5)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final parsed = double.tryParse(
                            value?.trim().replaceAll(',', '.') ?? '',
                          );
                          if (parsed == null || parsed < 0 || parsed > 5) {
                            return 'Nhập đánh giá 0-5.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Mô tả'),
                        minLines: 2,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập mô tả.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : handleSave,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Lưu' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Quản lý món ăn',
        centerTitle: true,
      ),
      body: StreamBuilder<List<Food>>(
        stream: _foodService.getFoodsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Không tải được dữ liệu',
              message: 'Kiểm tra kết nối rồi thử lại sau.',
            );
          }

          final foods = snapshot.data ?? [];
          if (foods.isEmpty) {
            return const _StateMessage(
              icon: Icons.fastfood_outlined,
              title: 'Chưa có món ăn',
              message: 'Thêm món mới để bắt đầu bán hàng.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: foods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final food = foods[index];
              final isDeleting = _deletingFoodIds.contains(food.id);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        food.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            food.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${food.price.toInt()} đ',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.star,
                                  size: 14, color: Colors.orange.shade400),
                              const SizedBox(width: 4),
                              Text(
                                food.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.primary,
                          onPressed: () => _showFoodFormDialog(food: food),
                        ),
                        isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _confirmDelete(food),
                              ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFoodFormDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
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
            Icon(icon, size: 88, color: Colors.grey.shade400),
            const SizedBox(height: 12),
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
