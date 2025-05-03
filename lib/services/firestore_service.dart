import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData({
    required String uid,
    required String? email,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        "hasCompletedOnboarding": false,
      }, SetOptions(merge: true));
    } catch (e) {
      log('Error saving user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      log('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // Handle arrays properly by using arrayUnion for arrays
      final Map<String, dynamic> updateData = {};
      data.forEach((key, value) {
        if (value is List) {
          updateData[key] = FieldValue.arrayUnion(value);
        } else {
          updateData[key] = value;
        }
      });

      await _firestore.collection('users').doc(uid).update({
        ...updateData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating user data: $e');
      rethrow;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking username existence: $e');
      rethrow;
    }
  }

  Future<void> saveUserInterests(String uid, List<String> interests) async {
    try {
      //update hasCompletedOnboarding to true
      await _firestore.collection('users').doc(uid).update({
        'hasCompletedOnboarding': true,
      });
      await _firestore.collection('users').doc(uid).update({
        'interests': interests,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error saving user interests: $e');
      rethrow;
    }
  }
}
