import 'package:get/get.dart';
import 'package:reddit/model/Community.dart';
import 'package:reddit/services/community_service.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityController extends GetxController {
  final CommunityService _communityService = CommunityService();
  final ProfileController _profileController = Get.find<ProfileController>();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Observable variables
  RxList<Community> get communities => _communityService.communities;
  RxList<Community> get userCommunities => _communityService.userCommunities;
  RxList<Community> get createdCommunities =>
      _communityService.createdCommunities;
  RxBool get isLoading => _communityService.isLoading;

  // Recently visited communities
  final RxList<String> _recentlyVisitedCommunities = <String>[].obs;
  RxList<String> get recentlyVisitedCommunities => _recentlyVisitedCommunities;

  @override
  void onInit() {
    super.onInit();
    fetchUserCommunities();
    fetchCreatedCommunities();
    // Load recently visited communities from storage
    _loadRecentlyVisited();
  }

  // Load recently visited communities from storage
  Future<void> _loadRecentlyVisited() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList('recently_visited_communities');
      if (savedList != null) {
        _recentlyVisitedCommunities.value = savedList;
      }
    } catch (e) {
      print('Error loading recently visited communities: $e');
    }
  }

  // Save recently visited communities to storage
  Future<void> _saveRecentlyVisited() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'recently_visited_communities', _recentlyVisitedCommunities);
    } catch (e) {
      print('Error saving recently visited communities: $e');
    }
  }

  // Visit a community
  void visitCommunity(String communityName) {
    log('Visiting community: $communityName');
    log('Current recently visited: ${_recentlyVisitedCommunities}');

    // Create a new list to trigger the observable update
    final updatedList = List<String>.from(_recentlyVisitedCommunities);

    // Remove if already exists to avoid duplicates
    updatedList.remove(communityName);

    // Add to the beginning of the list
    updatedList.insert(0, communityName);

    // Keep only the last 10 visited communities
    if (updatedList.length > 10) {
      updatedList.removeLast();
    }

    log('Updated list: $updatedList');

    // Update the observable list
    _recentlyVisitedCommunities.value = updatedList;

    // Save to storage
    _saveRecentlyVisited();

    log('Recently visited after update: ${_recentlyVisitedCommunities}');
  }

  // Add a community to recently visited (legacy method, use visitCommunity instead)
  void addToRecentlyVisited(String communityName) {
    visitCommunity(communityName);
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(dynamic imageFile, String path) async {
    try {
      if (imageFile is File) {
        log('Starting file upload for: ${imageFile.path}');

        // Check if file exists
        if (!await imageFile.exists()) {
          log('File does not exist: ${imageFile.path}');
          return null;
        }

        // Get file size
        final fileSize = await imageFile.length();
        log('File size: ${fileSize} bytes');

        // Create storage reference
        final storageRef = _storage.ref().child(path);
        log('Storage reference created: $path');

        // Upload file with metadata
        log('Starting upload task...');
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': imageFile.path},
        );

        try {
          final uploadTask = storageRef.putFile(imageFile, metadata);

          // Monitor upload progress
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            log('Upload progress: ${progress.toStringAsFixed(2)}%');
          });

          // Wait for upload to complete
          final snapshot = await uploadTask;
          log('Upload task completed');

          // Get download URL
          log('Getting download URL...');
          final downloadUrl = await snapshot.ref.getDownloadURL();
          log('Download URL obtained: $downloadUrl');

          return downloadUrl;
        } catch (uploadError) {
          log('Error during upload: $uploadError');
          // Try to delete the failed upload
          try {
            await storageRef.delete();
          } catch (deleteError) {
            log('Error deleting failed upload: $deleteError');
          }
          rethrow;
        }
      } else if (imageFile is String && imageFile.startsWith('http')) {
        log('Using existing URL: $imageFile');
        return imageFile;
      }
      log('No valid image file provided');
      return null;
    } catch (e, stackTrace) {
      log('Error uploading image: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> createCommunity({
    required String name,
    required String description,
    required String type,
    required bool isMature,
    required List<String> topics,
    dynamic bannerImage,
    dynamic avatarImage,
  }) async {
    try {
      isLoading.value = true;
      log('Starting community creation for: $name');

      // Generate ID
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      log('Generated community ID: $id');

      // Handle images
      String? bannerUrl;
      String? avatarUrl;

      if (bannerImage != null) {
        log('Processing banner image...');
        try {
          bannerUrl =
              await _uploadImage(bannerImage, 'communities/$id/banner.jpg');
          log('Banner upload result: ${bannerUrl ?? "Failed"}');
        } catch (e) {
          log('Error uploading banner: $e');
          // Continue with community creation even if banner upload fails
        }
      }

      if (avatarImage != null) {
        log('Processing avatar image...');
        try {
          avatarUrl =
              await _uploadImage(avatarImage, 'communities/$id/avatar.jpg');
          log('Avatar upload result: ${avatarUrl ?? "Failed"}');
        } catch (e) {
          log('Error uploading avatar: $e');
          // Continue with community creation even if avatar upload fails
        }
      }

      // Create community object
      log('Creating community object...');
      final community = Community(
        id: id,
        name: name,
        title: name,
        description: description,
        publicDescription: description,
        memberCount: 1,
        onlineCount: 1,
        createdAt: DateTime.now(),
        type: type,
        isMature: isMature,
        createdBy: _profileController.userId.value,
        topics: topics,
        over18: isMature,
        subredditType: type,
        bannerImg: bannerUrl,
        iconImg: avatarUrl,
      );

      log('Saving community to Firebase...');
      await _communityService.createCommunity(community);
      log('Community saved successfully');

      // Add to recently visited and refresh
      addToRecentlyVisited(name);
      await fetchCreatedCommunities();

      Get.snackbar(
        'Success',
        'Community created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      log('Error creating community: $e');
      log('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to create community: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserCommunities() async {
    if (_profileController.userId.value.isNotEmpty) {
      await _communityService
          .fetchUserCommunities(_profileController.userId.value);
    }
  }

  Future<void> fetchCreatedCommunities() async {
    if (_profileController.userId.value.isNotEmpty) {
      await _communityService
          .fetchCreatedCommunities(_profileController.userId.value);
    }
  }

  Future<Community?> fetchCommunityInfo(String communityName) async {
    return await _communityService.fetchCommunityInfo(communityName);
  }

  void refreshCommunities() {
    fetchUserCommunities();
    fetchCreatedCommunities();
  }
}
