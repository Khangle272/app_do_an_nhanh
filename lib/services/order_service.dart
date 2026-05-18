import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }
    return user.uid;
  }

  // 1. Tạo đơn hàng mới và trả về DocumentReference để lấy id
  Future<DocumentReference> createOrder(Map<String, dynamic> cartData) async {
    final userId = _requireUserId();

    return await _firestore.collection('orders').add({
      'userId': userId,
      'items': cartData['items'], // danh sách món từ CartProvider
      'totalPrice': cartData['totalPrice'],
      'status': 'Đang chuẩn bị', // trạng thái mặc định
      'createdAt': FieldValue.serverTimestamp(),
      'name': cartData['name'],
      'phone': cartData['phone'],
      'address': cartData['address'],
      'paymentMethod': cartData['paymentMethod'],
    });
  }

  // 2. Lấy lịch sử đơn hàng của user hiện tại
  Stream<QuerySnapshot> getOrderHistory() {
    final userId = _requireUserId();
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // 2b. Lấy toàn bộ đơn hàng cho admin
  Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 2c. Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. Lắng nghe trạng thái đơn hàng theo thời gian thực
  Stream<DocumentSnapshot> listenOrderStatus(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }
}
