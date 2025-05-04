import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/services/firebase_post_service.dart';
import 'package:reddit/services/firestore_service.dart';
import 'package:reddit/services/shared_preferences_service.dart';

class ProfileController extends GetxController {
  final _prefs = SharedPreferencesService();
  final _firestoreService = FirestoreService();

  // Observable variables for user data
  final RxString username = ''.obs;
  final RxString gender = ''.obs;
  final RxList<String> interests = <String>[].obs;
  final RxString userId = ''.obs;
  final RxBool hasCompletedOnboarding = false.obs;
  final RxInt karma = 0.obs;
  final RxString redditAge = ''.obs;
  final RxString photoUrl = ''.obs;

  // Track joined communities and posts
  final RxList<String> joinedCommunities = <String>[].obs;
  final RxList<String> joinedPosts = <String>[].obs;

  // Track liked and disliked posts
  final RxMap<String, int> postVotes =
      <String, int>{}.obs; // 1 for upvote, -1 for downvote, 0 for no vote

  // Track saved posts
  final RxList<String> savedPosts = <String>[].obs;

  // Track saved comments
  final RxList<String> savedComments = <String>[].obs;

  // Track user comments
  final RxList<Map<String, dynamic>> userComments =
      <Map<String, dynamic>>[].obs;

  // Track post view history
  final RxList<Map<String, dynamic>> postViewHistory =
      <Map<String, dynamic>>[].obs;

  // Observable for controlling navigation and app bar visibility
  final RxBool showNavigationBar = true.obs;
  final RxBool showAppBar = true.obs;
  double _lastScrollPosition = 0;

  // Loading state
  final RxBool isLoadingUserData = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoadingUserData.value = true;

      final userId = _prefs.getUserId();
      if (userId != null) {
        this.userId.value = userId;
        final userData = await _firestoreService.getUserData(userId);

        if (userData != null) {
          username.value = (userData['username'] as String?) ?? '';
          gender.value = (userData['gender'] as String?) ?? '';
          interests.value = (userData['interests'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          hasCompletedOnboarding.value =
              (userData['hasCompletedOnboarding'] as bool?) ?? false;
          karma.value = (userData['karma'] as num?)?.toInt() ?? 0;
          photoUrl.value = (userData['photoUrl'] as String?) ?? '';

          // Load joined communities and posts
          joinedCommunities.value = (userData['joinedCommunities'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          joinedPosts.value = (userData['joinedPosts'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          // Load post votes
          if (userData.containsKey('postVotes') &&
              userData['postVotes'] is Map) {
            final Map<String, dynamic> votes =
                userData['postVotes'] as Map<String, dynamic>;
            final Map<String, int> votesMap = {};
            votes.forEach((key, value) {
              if (value is num) {
                votesMap[key] = value.toInt();
              }
            });
            postVotes.value = votesMap;
          }

          // Load saved posts
          savedPosts.value = (userData['savedPosts'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          // Load saved comments
          savedComments.value = (userData['savedComments'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          // Load user comments
          if (userData.containsKey('userComments') &&
              userData['userComments'] is List) {
            final List<dynamic> comments =
                userData['userComments'] as List<dynamic>;
            userComments.value = comments.map((comment) {
              if (comment is Map) {
                return Map<String, dynamic>.from(comment);
              }
              return <String, dynamic>{};
            }).toList();
          }

          // Load post view history
          if (userData.containsKey('postViewHistory') &&
              userData['postViewHistory'] is List) {
            final List<dynamic> history =
                userData['postViewHistory'] as List<dynamic>;
            postViewHistory.value = history.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }).toList();
          }

          // Calculate Reddit age
          if (userData.containsKey('createdAt') &&
              userData['createdAt'] is Map) {
            final Map<String, dynamic> timestamp =
                userData['createdAt'] as Map<String, dynamic>;
            if (timestamp.containsKey('_seconds')) {
              final createdAt = DateTime.fromMillisecondsSinceEpoch(
                  (timestamp['_seconds'] as num).toInt() * 1000);
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
      }
    } catch (e) {
      log('Error loading user data: $e');
    } finally {
      isLoadingUserData.value = false;
    }
  }

  // Check if a post is saved
  bool isPostSaved(String postId) {
    return savedPosts.contains(postId);
  }

  // Save a post
  Future<void> savePost(String postId) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      if (!savedPosts.contains(postId)) {
        savedPosts.add(postId);
        await _firestoreService.updateUserData(userId.value, {
          'savedPosts': savedPosts,
        });
      }
    } catch (e) {
      log('Error saving post: $e');
      rethrow;
    }
  }

  // Unsave a post
  Future<void> unsavePost(String postId) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      if (savedPosts.contains(postId)) {
        savedPosts.remove(postId);
        await _firestoreService.updateUserData(userId.value, {
          'savedPosts': savedPosts,
        });
      }
    } catch (e) {
      log('Error unsaving post: $e');
      rethrow;
    }
  }

  // Toggle save status for a post
  Future<void> toggleSavePost(String postId) async {
    try {
      if (isPostSaved(postId)) {
        await unsavePost(postId);
      } else {
        await savePost(postId);
      }
    } catch (e) {
      log('Error toggling post save status: $e');
      rethrow;
    }
  }

  // Check if a comment is saved
  bool isCommentSaved(String commentId) {
    return savedComments.contains(commentId);
  }

  // Save a comment
  Future<void> saveComment(
      String commentId, String postId, String commentText) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      if (!savedComments.contains(commentId)) {
        savedComments.add(commentId);

        // Store comment data in a structured way to retrieve later
        final commentData = {
          'id': commentId,
          'postId': postId,
          'text': commentText,
          'savedAt': DateTime.now().millisecondsSinceEpoch,
        };

        await _firestoreService.updateUserData(userId.value, {
          'savedComments': savedComments,
          'commentData_$commentId': commentData,
        });
      }
    } catch (e) {
      log('Error saving comment: $e');
      rethrow;
    }
  }

  // Unsave a comment
  Future<void> unsaveComment(String commentId) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      if (savedComments.contains(commentId)) {
        // Remove from local state
        savedComments.remove(commentId);

        // Create a map with the updated savedComments list
        final Map<String, dynamic> updates = {
          'savedComments': savedComments,
        };

        // The literal string "null" will be treated as a special case by
        // Firestore to delete the field entirely
        updates['commentData_$commentId'] = null;

        await _firestoreService.updateUserData(userId.value, updates);
      }
    } catch (e) {
      log('Error unsaving comment: $e');
      rethrow;
    }
  }

  // Toggle save status for a comment
  Future<void> toggleSaveComment(
      String commentId, String postId, String commentText) async {
    try {
      if (isCommentSaved(commentId)) {
        await unsaveComment(commentId);
      } else {
        await saveComment(commentId, postId, commentText);
      }
    } catch (e) {
      log('Error toggling comment save status: $e');
      rethrow;
    }
  }

  // Check if a post is upvoted by the user
  bool isPostUpvoted(String postId) {
    return postVotes[postId] == 1;
  }

  // Check if a post is downvoted by the user
  bool isPostDownvoted(String postId) {
    return postVotes[postId] == -1;
  }

  // Get the vote status for a post
  int getPostVoteStatus(String postId) {
    return postVotes[postId] ?? 0;
  }

  // Upvote a post
  Future<void> upvotePost(String postId) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      final currentVote = postVotes[postId] ?? 0;
      int newVote;

      // If already upvoted, remove the upvote
      if (currentVote == 1) {
        newVote = 0;
      } else {
        newVote = 1;
      }

      // Update local state
      postVotes[postId] = newVote;

      // Update in Firebase
      await _firestoreService.updateUserData(userId.value, {
        'postVotes': postVotes,
      });
    } catch (e) {
      log('Error upvoting post: $e');
      rethrow;
    }
  }

  // Downvote a post
  Future<void> downvotePost(String postId) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      final currentVote = postVotes[postId] ?? 0;
      int newVote;

      // If already downvoted, remove the downvote
      if (currentVote == -1) {
        newVote = 0;
      } else {
        newVote = -1;
      }

      // Update local state
      postVotes[postId] = newVote;

      // Update in Firebase
      await _firestoreService.updateUserData(userId.value, {
        'postVotes': postVotes,
      });
    } catch (e) {
      log('Error downvoting post: $e');
      rethrow;
    }
  }

  // Check if a community is joined
  bool isCommunityJoined(String communityName) {
    return joinedCommunities.contains(communityName);
  }

  // Check if a post is joined
  bool isPostJoined(String postId) {
    return joinedPosts.contains(postId);
  }

  // Join a community
  Future<void> joinCommunity(String communityName) async {
    try {
      if (!joinedCommunities.contains(communityName)) {
        joinedCommunities.add(communityName);
        await _firestoreService.updateUserData(userId.value, {
          'joinedCommunities': joinedCommunities,
        });
      }
    } catch (e) {
      log('Error joining community: $e');
      rethrow;
    }
  }

  // Leave a community
  Future<void> leaveCommunity(String communityName) async {
    try {
      if (joinedCommunities.contains(communityName)) {
        joinedCommunities.remove(communityName);
        await _firestoreService.updateUserData(userId.value, {
          'joinedCommunities': joinedCommunities,
        });
      }
    } catch (e) {
      log('Error leaving community: $e');
      rethrow;
    }
  }

  // Join a post
  Future<void> joinPost(String postId) async {
    try {
      if (!joinedPosts.contains(postId)) {
        joinedPosts.add(postId);
        await _firestoreService.updateUserData(userId.value, {
          'joinedPosts': joinedPosts,
        });
      }
    } catch (e) {
      log('Error joining post: $e');
      rethrow;
    }
  }

  // Leave a post
  Future<void> leavePost(String postId) async {
    try {
      if (joinedPosts.contains(postId)) {
        joinedPosts.remove(postId);
        await _firestoreService.updateUserData(userId.value, {
          'joinedPosts': joinedPosts,
        });
      }
    } catch (e) {
      log('Error leaving post: $e');
      rethrow;
    }
  }

  // Toggle join status for a post
  Future<void> togglePostJoinStatus(String postId) async {
    try {
      if (isPostJoined(postId)) {
        await leavePost(postId);
      } else {
        await joinPost(postId);
      }
    } catch (e) {
      log('Error toggling post join status: $e');
      rethrow;
    }
  }

  // Toggle join status for a community
  Future<void> toggleCommunityJoinStatus(String communityName) async {
    try {
      if (isCommunityJoined(communityName)) {
        await leaveCommunity(communityName);
      } else {
        await joinCommunity(communityName);
      }
    } catch (e) {
      log('Error toggling community join status: $e');
      rethrow;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      await _firestoreService.updateUserData(userId.value, {
        'username': newUsername,
      });
      username.value = newUsername;
    } catch (e) {
      log('Error updating username: $e');
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
      log('Error updating gender: $e');
      rethrow;
    }
  }

  Future<void> updateInterests(List<String> newInterests) async {
    try {
      await _firestoreService.saveUserInterests(userId.value, newInterests);
      interests.value = newInterests;
    } catch (e) {
      log('Error updating interests: $e');
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
      log('Error incrementing karma: $e');
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
      log('Error updating photoUrl: $e');
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

  // Add user comment
  Future<void> saveUserComment(String postId, String postTitle,
      String commentText, String subreddit) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      // Create comment data
      final commentData = {
        'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
        'postId': postId,
        'postTitle': postTitle,
        'text': commentText,
        'subreddit': subreddit,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'username': username.value,
      };

      // Add to local state first
      final updatedComments = List<Map<String, dynamic>>.from(userComments);
      updatedComments.add(commentData);
      userComments.value = updatedComments;

      // Get the current user data
      final userData = await _firestoreService.getUserData(userId.value);
      List<Map<String, dynamic>> existingComments = [];

      if (userData != null && userData['userComments'] != null) {
        existingComments =
            List<Map<String, dynamic>>.from(userData['userComments']);
      }

      // Add the new comment
      existingComments.add(commentData);

      // Save to Firebase
      await _firestoreService.updateUserData(userId.value, {
        'userComments': existingComments,
      });

      // Increment karma for posting a comment
      await incrementKarma();
    } catch (e) {
      log('Error saving user comment: $e');
      rethrow;
    }
  }

  // Add post to view history
  Future<void> addToViewHistory(
      String postId, String postTitle, String subreddit,
      {String? postThumbnail}) async {
    try {
      if (userId.value.isEmpty) {
        return; // Don't proceed if user is not logged in
      }

      // Create history data
      final historyData = {
        'id': postId,
        'postTitle': postTitle,
        'subreddit': subreddit,
        'viewedAt': DateTime.now().millisecondsSinceEpoch,
        'thumbnail': postThumbnail,
      };

      // Check if post is already in history
      final existingIndex =
          postViewHistory.indexWhere((item) => item['id'] == postId);

      // If exists, update the viewedAt time and move to front
      if (existingIndex != -1) {
        postViewHistory.removeAt(existingIndex);
      }

      // Add new entry at the beginning (most recent)
      final updatedHistory = [historyData, ...postViewHistory];

      // Limit history to 100 items to prevent excessive storage
      if (updatedHistory.length > 100) {
        updatedHistory.removeLast();
      }

      // Update local state
      postViewHistory.value = updatedHistory;

      // Save to Firebase
      await _firestoreService.updateUserData(userId.value, {
        'postViewHistory': updatedHistory,
      });
    } catch (e) {
      log('Error adding to view history: $e');
    }
  }

  // Clear post view history
  Future<void> clearViewHistory() async {
    try {
      if (userId.value.isEmpty) return;

      // Clear local state
      postViewHistory.clear();

      // Update in Firebase
      await _firestoreService.updateUserData(userId.value, {
        'postViewHistory': [],
      });

      Get.snackbar(
        'History Cleared',
        'Your browsing history has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      log('Error clearing view history: $e');
      Get.snackbar(
        'Error',
        'Failed to clear history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Get user comments
  List<Map<String, dynamic>> getUserComments() {
    return userComments.toList();
  }

  // Get user posts
  Future<List<RedditPost>> getUserPosts() async {
    try {
      if (userId.value.isEmpty) return [];

      // Convert Firebase post data to RedditPost objects
      final posts = await FirebasePostService().fetchUserPosts(userId.value);
      return posts;
    } catch (e) {
      log('Error getting user posts: $e');
      return [];
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
    photoUrl.value = '';
    joinedCommunities.clear();
    joinedPosts.clear();
    postVotes.clear();
    savedPosts.clear();
    savedComments.clear();
    userComments.clear();
    postViewHistory.clear();
  }
}
