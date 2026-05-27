import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';
import '../models/review_model.dart';

class FoodService {
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('Foods');

  CollectionReference _reviewCollection(String foodId) {
    return _foodCollection.doc(foodId).collection('Reviews');
  }

  // Hàm đẩy dữ liệu mẫu lên (Admin dùng)
  Future<void> uploadMockDataToFirestore() async {
    for (var food in popularFoods) {
      await _foodCollection.doc(food.id).set(food.toMap());
    }
  }

  // Lấy danh sách Real-time cho Trang chủ
  Stream<List<Food>> getPopularFoodsStream() {
    return _foodCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Food.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Lấy danh sách Real-time cho Admin
  Stream<List<Food>> getFoodsStream() {
    return _foodCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Food.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Thêm món ăn
  Future<void> addFood({
    required String name,
    required String imageUrl,
    required double price,
    required String description,
    double rating = 5.0,
  }) async {
    await _foodCollection.add({
      'name': name,
      'nameLowercase': name.toLowerCase(),
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sửa món ăn
  Future<void> updateFood({
    required String id,
    required String name,
    required String imageUrl,
    required double price,
    required String description,
    required double rating,
  }) async {
    await _foodCollection.doc(id).update({
      'name': name,
      'nameLowercase': name.toLowerCase(),
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Xoa mon an
  Future<void> deleteFood(String id) async {
    await _foodCollection.doc(id).delete();
  }

  // Lấy danh sách đánh giá theo thời gian thực
  Stream<List<FoodReview>> getReviewsStream(String foodId) {
    return _reviewCollection(foodId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodReview.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Lấy đánh giá của một user cho món ăn
  Future<FoodReview?> getUserReview(String foodId, String userId) async {
    final doc = await _reviewCollection(foodId).doc(userId).get();
    if (!doc.exists) return null;
    return FoodReview.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Thêm hoặc cập nhật đánh giá
  Future<void> addOrUpdateReview({
    required String foodId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    await _reviewCollection(foodId).doc(userId).set({
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _recalculateRating(foodId);
  }

  Future<void> _recalculateRating(String foodId) async {
    final snapshot = await _reviewCollection(foodId).get();
    if (snapshot.docs.isEmpty) {
      await _foodCollection.doc(foodId).update({
        'rating': 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['rating'] ?? 0).toDouble();
    }
    final average = total / snapshot.docs.length;

    await _foodCollection.doc(foodId).update({
      'rating': average,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Tìm kiếm và Lọc
  Future<List<Food>> searchAndFilterFoods(
      {String query = '', double? maxPrice, double? minRating}) async {
    Query firestoreQuery = _foodCollection;

    if (maxPrice != null) {
      firestoreQuery =
          firestoreQuery.where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (minRating != null) {
      firestoreQuery =
          firestoreQuery.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    final querySnapshot = await firestoreQuery.get();
    List<Food> results = querySnapshot.docs.map((doc) {
      return Food.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    if (query.isNotEmpty) {
      String searchKeyword = query.toLowerCase();
      results = results
          .where((food) => food.nameLowercase.contains(searchKeyword))
          .toList();
    }
    return results;
  }
}
