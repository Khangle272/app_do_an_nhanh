import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/models/food_model.dart';
import 'package:app_do_an_nhanh/models/review_model.dart';
import 'package:app_do_an_nhanh/services/food_service.dart';
import 'package:provider/provider.dart';
import 'package:app_do_an_nhanh/providers/cart_provider.dart';
import 'package:app_do_an_nhanh/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final Food food;
  const ProductDetailScreen({super.key, required this.food});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedSize = 'M';
  final List<String> _selectedToppings = [];
  final FoodService _foodService = FoodService();

  final List<String> _sizes = ['S', 'M', 'L'];
  final List<Map<String, dynamic>> _toppings = [
    {'name': 'Phô mai thêm', 'price': 10000},
    {'name': 'Sốt cay', 'price': 5000},
    {'name': 'Khoai tây chiên', 'price': 15000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chi tiết món ăn',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'food_image_${widget.food.id}',
                child: Image.network(
                  widget.food.imageUrl,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.fastfood, size: 100, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.food.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        // Cập nhật: toInt() để xóa số .0 ở đuôi
                        '${widget.food.price.toInt()} đ',
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.food.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade200, thickness: 8),
            _buildReviewSection(),
            Divider(color: Colors.grey.shade200, thickness: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Size',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade200, thickness: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thêm Topping',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _toppings.map((topping) {
                      final isSelected = _selectedToppings.contains(
                        topping['name'],
                      );
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        title: Text(topping['name']),
                        subtitle: Text(
                          '+${topping['price']} đ',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedToppings.add(topping['name']);
                            } else {
                              _selectedToppings.remove(topping['name']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomAddToCart(),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: StreamBuilder<List<FoodReview>>(
        stream: _foodService.getReviewsStream(widget.food.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data ?? [];
          final average = reviews.isEmpty
              ? 0.0
              : reviews.map((review) => review.rating).reduce((a, b) => a + b) /
                  reviews.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đánh giá',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildStarRow(average, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              average.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${reviews.length})',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _onReviewTap,
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Viết đánh giá'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (snapshot.hasError)
                Text(
                  'Không tải được đánh giá.',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else if (reviews.isEmpty)
                Text(
                  'Chưa có đánh giá. Hãy là người đầu tiên!',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  review.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (review.createdAt != null)
                                Text(
                                  _formatReviewDate(review.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildStarRow(review.rating, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                review.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (review.comment.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onReviewTap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá.')),
      );
      return;
    }

    FoodReview? existingReview;
    try {
      existingReview =
          await _foodService.getUserReview(widget.food.id, user.uid);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tải được đánh giá của bạn.')),
      );
      return;
    }

    if (!mounted) return;
    await _showReviewDialog(
      userId: user.uid,
      userEmail: user.email,
      existingReview: existingReview,
    );
  }

  Future<void> _showReviewDialog({
    required String userId,
    required String? userEmail,
    FoodReview? existingReview,
  }) async {
    final isEditing = existingReview != null;
    final formKey = GlobalKey<FormState>();
    final commentController =
        TextEditingController(text: existingReview?.comment ?? '');
    double selectedRating = existingReview?.rating ?? 5.0;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> handleSave() async {
              if (!formKey.currentState!.validate()) return;

              setDialogState(() => isSaving = true);
              try {
                final userName =
                    await _resolveUserName(userId, fallbackEmail: userEmail);
                await _foodService.addOrUpdateReview(
                  foodId: widget.food.id,
                  userId: userId,
                  userName: userName,
                  rating: selectedRating,
                  comment: commentController.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing ? 'Đã cập nhật đánh giá.' : 'Đã gửi đánh giá.',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Lỗi lưu đánh giá: $e')),
                );
              } finally {
                if (mounted) {
                  setDialogState(() => isSaving = false);
                }
              }
            }

            return AlertDialog(
              title: Text(isEditing ? 'Sửa đánh giá' : 'Đánh giá món ăn'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chọn số sao'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: selectedRating,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: selectedRating.toStringAsFixed(1),
                            onChanged: (value) {
                              setDialogState(() => selectedRating = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Nhận xét',
                        hintText: 'Chia sẻ trải nghiệm của bạn...',
                      ),
                      minLines: 2,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập nhận xét.';
                        }
                        return null;
                      },
                    ),
                  ],
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
                      : Text(isEditing ? 'Lưu' : 'Gửi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _resolveUserName(String userId,
      {required String? fallbackEmail}) async {
    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      final name = data?['name']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }
    if (fallbackEmail != null && fallbackEmail.trim().isNotEmpty) {
      return fallbackEmail.trim();
    }
    return 'Người dùng';
  }

  Widget _buildStarRow(double rating, {double size = 16}) {
    final filledStars = rating.floor();
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < filledStars ? Icons.star : Icons.star_border,
          size: size,
          color: Colors.orange.shade400,
        );
      }),
    );
  }

  String _formatReviewDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  Widget _buildBottomAddToCart() {
    // 1. Tính giá 1 đơn vị gồm topping
    double pricePerUnit = widget.food.price;
    for (var topping in _toppings) {
      if (_selectedToppings.contains(topping['name'])) {
        pricePerUnit += (topping['price'] as int);
      }
    }

    // 2. Tổng tiền (giá 1 đơn vị * số lượng)
    double finalTotal = pricePerUnit * _quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final cart =
                        Provider.of<CartProvider>(context, listen: false);

                    // Thêm số lượng tương ứng vào giỏ hàng
                    for (int i = 0; i < _quantity; i++) {
                      cart.addItem(
                          widget.food.id,
                          "${widget.food.name} ($_selectedSize)",
                          pricePerUnit.toInt());
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Đã thêm $_quantity ${widget.food.name} vào giỏ hàng!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 1),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: Text(
                    'Thêm • ${finalTotal.toInt()} đ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
