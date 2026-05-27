import 'package:cloud_firestore/cloud_firestore.dart';

class FoodReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  FoodReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory FoodReview.fromMap(Map<String, dynamic> map, String documentId) {
    final createdAt = map['createdAt'];
    DateTime? createdDate;
    if (createdAt is Timestamp) {
      createdDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      createdDate = createdAt;
    }

    return FoodReview(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Nguoi dung',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment']?.toString() ?? '',
      createdAt: createdDate,
    );
  }
}
