import 'dart:developer';

import 'package:get/get.dart';
import 'package:reddit/model/Community.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final RxList<Community> _communities = <Community>[].obs;
  final RxList<Community> _userCommunities = <Community>[].obs;
  final RxList<Community> _createdCommunities = <Community>[].obs;
  final RxBool _isLoading = false.obs;

  // Getters
  RxList<Community> get communities => _communities;
  RxList<Community> get userCommunities => _userCommunities;
  RxList<Community> get createdCommunities => _createdCommunities;
  RxBool get isLoading => _isLoading;

  final String _redditApiBaseUrl = 'https://www.reddit.com/r/';

  Future<void> createCommunity(Community community) async {
    try {
      log('Starting community creation in service...');
      log('Community data: ${community.toJson()}');
      log('Community ID: ${community.id}');
      log('Community name: ${community.name}');
      log('Created by: ${community.createdBy}');
      log('Community images - Banner: ${community.bannerImg}, Avatar: ${community.iconImg}');

      // Convert community to JSON and add required fields
      final Map<String, dynamic> communityData = {
        ...community.toJson(),
        'members': [community.createdBy],
        'moderators': [community.createdBy],
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      log('Community data prepared: $communityData');

      try {
        log('Checking if user document exists...');
        final userDoc =
            await _firestore.collection('users').doc(community.createdBy).get();
        if (!userDoc.exists) {
          log('User document does not exist, will need to create it');
        } else {
          log('User document exists: ${userDoc.data()}');
        }
      } catch (e) {
        log('Error checking user document: $e');
      }

      // Create batch
      log('Creating batch operation...');
      final batch = _firestore.batch();

      // Add community document
      final communityRef =
          _firestore.collection('communities').doc(community.id);
      log('Setting community document at communities/${community.id}');
      batch.set(communityRef, communityData);

      // Update user document
      final userRef = _firestore.collection('users').doc(community.createdBy);
      log('Updating user document at users/${community.createdBy}');

      try {
        // First check if user document exists
        final userDoc = await userRef.get();
        if (!userDoc.exists) {
          log('User document does not exist, creating it first');
          // Create user document first
          batch.set(userRef, {
            'communities': [community.id],
            'created_communities': [community.id],
            'userId': community.createdBy,
            'created_at': FieldValue.serverTimestamp(),
          });
        } else {
          // Update existing user document
          log('Updating existing user document');
          batch.update(userRef, {
            'communities': FieldValue.arrayUnion([community.id]),
            'created_communities': FieldValue.arrayUnion([community.id]),
          });
        }
      } catch (e) {
        log('Error handling user document: $e');
        throw e;
      }

      // Commit changes
      log('Committing batch operations...');
      await batch.commit();
      log('Community created successfully in Firebase');

      // Update local list
      log('Updating local list with new community');
      _createdCommunities.add(community);
      log('Added community to local list, current count: ${_createdCommunities.length}');
    } catch (e, stackTrace) {
      log('Error in community service: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> fetchUserCommunities(String userId) async {
    try {
      _isLoading.value = true;

      // Get user document to get their communities
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null && userData['communities'] != null) {
        final List<String> communityIds =
            List<String>.from(userData['communities']);

        // Fetch all communities where user is a member
        final snapshot = await _firestore
            .collection('communities')
            .where('members', arrayContains: userId)
            .get();

        _userCommunities.value =
            snapshot.docs.map((doc) => Community.fromJson(doc.data())).toList();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchCreatedCommunities(String userId) async {
    try {
      _isLoading.value = true;

      // Get user document to get their created communities
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null && userData['created_communities'] != null) {
        final List<String> communityIds =
            List<String>.from(userData['created_communities']);

        // Fetch all communities created by the user
        final snapshot = await _firestore
            .collection('communities')
            .where('createdBy', isEqualTo: userId)
            .get();

        _createdCommunities.value =
            snapshot.docs.map((doc) => Community.fromJson(doc.data())).toList();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Community?> fetchCommunityInfo(String communityName) async {
    try {
      // Remove 'r/' prefix if it exists
      String cleanName = communityName.startsWith('r/')
          ? communityName.substring(2)
          : communityName;

      // First try to fetch from Reddit API
      final response = await http.get(
        Uri.parse('https://www.reddit.com/r/$cleanName/about.json'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['data'] == null) {
          return null;
        }

        final communityData = jsonData['data'];

        // Handle empty or null values
        final String id = communityData['id']?.toString() ?? '';
        final String title = communityData['title']?.toString() ?? cleanName;
        final String description =
            communityData['description']?.toString() ?? '';
        final String publicDescription =
            communityData['public_description']?.toString() ?? '';
        final int memberCount = communityData['subscribers'] is int
            ? communityData['subscribers']
            : 0;
        final int onlineCount = communityData['active_user_count'] is int
            ? communityData['active_user_count']
            : 0;
        final int createdUtc = communityData['created_utc'] is int
            ? communityData['created_utc']
            : 0;
        final String type =
            communityData['subreddit_type']?.toString() ?? 'public';
        final bool isMature =
            communityData['over18'] is bool ? communityData['over18'] : false;
        final String createdBy = communityData['created_by']?.toString() ?? '';
        final List<String> topics = communityData['topics'] is List
            ? List<String>.from(
                communityData['topics'].map((topic) => topic.toString()))
            : [];
        final String subredditType =
            communityData['subreddit_type']?.toString() ?? 'public';
        final String? iconImg = communityData['icon_img']?.toString();
        final String? headerImg = communityData['header_img']?.toString();
        final String? bannerImg = communityData['banner_img']?.toString();

        return Community(
          id: id,
          name: cleanName,
          title: title,
          description: description,
          publicDescription: publicDescription,
          memberCount: memberCount,
          onlineCount: onlineCount,
          createdAt: DateTime.fromMillisecondsSinceEpoch(createdUtc * 1000),
          type: type,
          isMature: isMature,
          createdBy: createdBy,
          topics: topics,
          over18: isMature,
          subredditType: subredditType,
          iconImg: iconImg,
          headerImg: headerImg,
          bannerImg: bannerImg,
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        // Fall back to Firebase
        return _fetchFromFirebase(cleanName);
      }
    } catch (e, stackTrace) {
      log('Error fetching community info: $e');
      log('Stack trace: $stackTrace');
      // Fall back to Firebase on any error
      return _fetchFromFirebase(communityName);
    }
  }

  Future<Community?> _fetchFromFirebase(String communityName) async {
    try {
      final snapshot = await _firestore
          .collection('communities')
          .where('name', isEqualTo: communityName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Community.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      log('Error fetching from Firebase: $e');
      return null;
    }
  }
}
