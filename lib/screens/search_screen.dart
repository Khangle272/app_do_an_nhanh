import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';

import 'package:app_do_an_nhanh/models/food_model.dart';
import 'package:app_do_an_nhanh/services/food_service.dart';
import 'package:app_do_an_nhanh/screens/home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Biến lưu kết quả tìm kiếm từ Firebase
  Future<List<Food>>? _searchResults;

  final List<String> _suggestedKeywords = [
    'Gà rán KFC',
    'Trà sữa',
    'Burger bò',
    'Pizza',
    'Mì cay',
  ];

  // Hàm gọi Firebase để tìm kiếm
  void _performSearch({double? maxPrice, double? minRating}) {
    // Ẩn bàn phím khi bấm tìm kiếm
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _searchResults = FoodService().searchAndFilterFoods(
        query: _searchController.text.trim(),
        maxPrice: maxPrice,
        minRating: minRating,
      );
    });
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(
              context), // Sửa thành pop() để quay lại đúng trang trước đó
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm món ăn, nhà hàng...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
          ),
          onSubmitted: (_) =>
              _performSearch(), // Gọi hàm tìm kiếm khi ấn Enter trên bàn phím
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchResults = null; // Trở về màn hình gợi ý ban đầu
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),

      // CHUYỂN ĐỔI UI: NẾU CHƯA TÌM KIẾM THÌ HIỆN GỢI Ý, TÌM RỒI THÌ HIỆN KẾT QUẢ
      body: _searchResults == null
          ? _buildDefaultView()
          : _buildSearchResultsView(),
    );
  }

  // UI 1: Giao diện Gợi ý tìm kiếm ban đầu
  Widget _buildDefaultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade200, height: 1),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gợi ý tìm kiếm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _suggestedKeywords.map((keyword) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _searchController.text = keyword);
                      _performSearch(); // Tự động tìm luôn khi bấm gợi ý
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(keyword),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UI 2: Giao diện kết quả tìm kiếm từ Firebase
  Widget _buildSearchResultsView() {
    return FutureBuilder<List<Food>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text('Có lỗi xảy ra trong quá trình tìm kiếm.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Không tìm thấy món "${_searchController.text}"',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }

        final foods = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            return PopularFoodCard(
                food: foods[index]); // Tái sử dụng thẻ món ăn bên Trang chủ
          },
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    int selectedPriceOpt = 0;
    int selectedRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Lọc kết quả',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Theo giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip(
                        'Dưới 50k',
                        selectedPriceOpt == 1,
                        () => setModalState(() => selectedPriceOpt = 1),
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        'Dưới 100k', // Đổi text nhẹ cho khớp logic Firebase dễ dàng hơn
                        selectedPriceOpt == 2,
                        () => setModalState(() => selectedPriceOpt = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Đánh giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip(
                        '5 Sao',
                        selectedRating == 5,
                        () => setModalState(() => selectedRating = 5),
                        icon: Icons.star,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        'Từ 4 Sao',
                        selectedRating == 4,
                        () => setModalState(() => selectedRating = 4),
                        icon: Icons.star,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // LOGIC KHI BẤM ÁP DỤNG BỘ LỌC
                        Navigator.pop(context); // Đóng BottomSheet

                        double? mappedMaxPrice;
                        if (selectedPriceOpt == 1) mappedMaxPrice = 50000;
                        if (selectedPriceOpt == 2) mappedMaxPrice = 100000;

                        double? mappedMinRating;
                        if (selectedRating == 5) mappedMinRating = 5.0;
                        if (selectedRating == 4) mappedMinRating = 4.0;

                        // Thực hiện query
                        _performSearch(
                            maxPrice: mappedMaxPrice,
                            minRating: mappedMinRating);
                      },
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
