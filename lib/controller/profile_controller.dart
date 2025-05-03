import 'package:get/get.dart';
import 'package:reddit/services/firestore_service.dart';
import 'package:reddit/services/shared_preferences_service.dart';

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
  final RxString photoUrl = ''.obs;

  // Observable for controlling navigation and app bar visibility
  final RxBool showNavigationBar = true.obs;
  final RxBool showAppBar = true.obs;
  double _lastScrollPosition = 0;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
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
          photoUrl.value = userData['photoUrl'] ?? '';

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

  Future<void> updatePhotoUrl(String newPhotoUrl) async {
    try {
      await _firestoreService.updateUserData(userId.value, {
        'photoUrl': newPhotoUrl,
      });
      photoUrl.value = newPhotoUrl;
    } catch (e) {
      print('Error updating photoUrl: $e');
      rethrow;
    }
  }

  // Method to handle scroll events
  void handleScroll(double scrollPosition) {
    // If scrolling down, hide the bars
    if (scrollPosition > _lastScrollPosition && scrollPosition > 20) {
      if (showNavigationBar.value || showAppBar.value) {
        showNavigationBar.value = false;
        showAppBar.value = false;
      }
    }
    // If scrolling up, show the bars
    else if (scrollPosition < _lastScrollPosition) {
      if (!showNavigationBar.value || !showAppBar.value) {
        showNavigationBar.value = true;
        showAppBar.value = true;
      }
    }
    _lastScrollPosition = scrollPosition;
  }

  // Method to update navigation bar and app bar visibility
  void updateBarsVisibility(bool show) {
    showNavigationBar.value = show;
    showAppBar.value = show;
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
    photoUrl.value = '';
  }
}
