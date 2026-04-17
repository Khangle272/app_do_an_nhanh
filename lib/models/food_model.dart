class Food {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;

  Food({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
  });
}

List<Food> popularFoods = [
  Food(
    id: '1',
    name: 'Burger Phô mai Đặc biệt',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
    price: 45000,
    description:
        'Burger bò nướng hảo hạng với phô mai cheddar chảy, xà lách, cà chua tươi và nước sốt đặc biệt.',
  ),
  Food(
    id: '2',
    name: 'Gà rán giòn cay',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/1046/1046786.png',
    price: 35000,
    description:
        'Đùi gà chiên giòn rụm với công thức gia vị cay nồng đặc biệt, ăn kèm tương ớt.',
  ),
  Food(
    id: '3',
    name: 'Khoai tây chiên phô mai',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/114/114995.png',
    price: 25000,
    description: 'Khoai tây cắt sợi chiên giòn rắc bột phô mai thơm lừng.',
  ),
];
