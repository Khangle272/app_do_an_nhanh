import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class FoodService {
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('Foods');

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
