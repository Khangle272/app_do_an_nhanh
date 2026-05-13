class Food {
  final String id;
  final String name;
  final String nameLowercase; // Dùng để search không phân biệt hoa thường
  final String imageUrl;
  final double price;
  final String description;
  final double rating;

  Food({
    required this.id,
    required this.name,
    required this.nameLowercase,
    required this.imageUrl,
    required this.price,
    required this.description,
    this.rating = 5.0,
  });

  // Chuyển dữ liệu từ Firestore thành Đối tượng Food
  factory Food.fromMap(Map<String, dynamic> map, String documentId) {
    return Food(
      id: documentId,
      name: map['name'] ?? '',
      nameLowercase: map['nameLowercase'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
    );
  }

  // Chuyển Đối tượng Food thành JSON để đẩy lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameLowercase': name.toLowerCase(),
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'rating': rating,
    };
  }
}

// Dữ liệu mẫu đã được đổi tên thành popularFoodsMock
List<Food> popularFoods = [
  Food(
    id: '1',
    name: 'Burger Phô mai Đặc biệt',
    nameLowercase: 'burger phô mai đặc biệt',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
    price: 45000,
    description:
        'Burger bò nướng hảo hạng với phô mai cheddar chảy, xà lách, cà chua tươi và nước sốt đặc biệt.',
    rating: 4.8,
  ),
  Food(
    id: '2',
    name: 'Gà rán giòn cay',
    nameLowercase: 'gà rán giòn cay',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/1046/1046786.png',
    price: 35000,
    description:
        'Đùi gà chiên giòn rụm với công thức gia vị cay nồng đặc biệt, ăn kèm tương ớt.',
    rating: 4.5,
  ),
  Food(
    id: '3',
    name: 'Khoai tây chiên phô mai',
    nameLowercase: 'khoai tây chiên phô mai',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/114/114995.png',
    price: 25000,
    description: 'Khoai tây cắt sợi chiên giòn rắc bột phô mai thơm lừng.',
    rating: 4.2,
  ),
];
