import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<DocumentSnapshot> getCurrentUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('Users').doc(user.uid).snapshots();
    }
    throw Exception('No user logged in');
  }

  Future<void> updateUserInfo(String name, String phone, String address) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        'name': name,
        'phone': phone,
        'address': address,
      });
    }
  }

  Future<void> updateAvatar(File imageFile) async {
    final user = _auth.currentUser;
    if (user != null) {
      final ref = _storage.ref().child('avatars/${user.uid}.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      await _firestore.collection('Users').doc(user.uid).update({
        'avatarUrl': downloadUrl,
      });
    }
  }
}
