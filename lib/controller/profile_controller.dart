import 'package:get/get.dart';
import 'package:reddit/service/firestore_service.dart';
import 'package:reddit/service/shared_preferences_service.dart';

class ProfileController extends GetxController {
  final _firestoreService = FirestoreService();
  final _prefs = SharedPreferencesService();

  // Observable variables for user data
  final RxString username = ''.obs;
  final RxString gender = ''.obs;
  final RxList<String> interests = <String>[].obs;
  final RxString userId = ''.obs;
  final RxBool hasCompletedOnboarding = false.obs;
  final RxInt karma = 0.obs;
  final RxString redditAge = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _prefs.getUserId();
      if (userId != null) {
        this.userId.value = userId;
        final userData = await _firestoreService.getUserData(userId);

        if (userData != null) {
          username.value = userData['username'] ?? '';
          gender.value = userData['gender'] ?? '';
          interests.value = List<String>.from(userData['interests'] ?? []);
          hasCompletedOnboarding.value =
              userData['hasCompletedOnboarding'] ?? false;
          karma.value = userData['karma'] ?? 0;

          // Calculate Reddit age
          if (userData['createdAt'] != null) {
            final createdAt = userData['createdAt'].toDate();
            final now = DateTime.now();
            final difference = now.difference(createdAt);

            if (difference.inDays < 30) {
              redditAge.value = '${difference.inDays}d';
            } else if (difference.inDays < 365) {
              redditAge.value = '${(difference.inDays / 30).floor()}mo';
            } else {
              redditAge.value = '${(difference.inDays / 365).floor()}y';
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      await _firestoreService.updateUserData(userId.value, {
        'username': newUsername,
      });
      username.value = newUsername;
    } catch (e) {
      print('Error updating username: $e');
      rethrow;
    }
  }

  Future<void> updateGender(String newGender) async {
    try {
      await _firestoreService.updateUserData(userId.value, {
        'gender': newGender,
        'hasCompletedOnboarding': true,
      });
      gender.value = newGender;
      hasCompletedOnboarding.value = true;
    } catch (e) {
      print('Error updating gender: $e');
      rethrow;
    }
  }

  Future<void> updateInterests(List<String> newInterests) async {
    try {
      await _firestoreService.saveUserInterests(userId.value, newInterests);
      interests.value = newInterests;
    } catch (e) {
      print('Error updating interests: $e');
      rethrow;
    }
  }

  Future<void> incrementKarma() async {
    try {
      final newKarma = karma.value + 1;
      await _firestoreService.updateUserData(userId.value, {
        'karma': newKarma,
      });
      karma.value = newKarma;
    } catch (e) {
      print('Error incrementing karma: $e');
      rethrow;
    }
  }

  // Clear all user data when logging out
  Future<void> clearUserData() async {
    await _prefs.clearUserData();
    username.value = '';
    gender.value = '';
    interests.clear();
    userId.value = '';
    hasCompletedOnboarding.value = false;
    karma.value = 0;
    redditAge.value = '';
  }
}
