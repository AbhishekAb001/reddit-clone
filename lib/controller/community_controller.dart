import 'package:get/get.dart';
import 'package:reddit/model/Community.dart';
import 'package:reddit/services/community_service.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:reddit/utils/config.dart';
import 'dart:io';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityController extends GetxController {
  final CommunityService _communityService = CommunityService();
  final ProfileController _profileController = Get.find<ProfileController>();
  final cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName, CloudinaryConfig.uploadPreset,
      cache: false);

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
      final List<String>? recentList = prefs.getStringList('recentCommunities');
      if (recentList != null) {
        _recentlyVisitedCommunities.value = recentList;
      }
    } catch (e) {
      log('Error loading recently visited communities: $e');
    }
  }

  // Save recently visited communities to storage
  Future<void> _saveRecentlyVisited() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'recentCommunities', _recentlyVisitedCommunities.toList());
    } catch (e) {
      log('Error saving recently visited communities: $e');
    }
  }

  // Visit a community
  void visitCommunity(String communityName) {
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

    // Update the observable list
    _recentlyVisitedCommunities.value = updatedList;

    // Save to storage
    _saveRecentlyVisited();
  }

  // Add a community to recently visited (legacy method, use visitCommunity instead)
  void addToRecentlyVisited(String communityName) {
    visitCommunity(communityName);
  }

  // Upload image to Cloudinary
  Future<String?> _uploadImage(dynamic imageFile, String path) async {
    try {
      if (imageFile is File) {
        // Check if file exists
        if (!await imageFile.exists()) {
          return null;
        }

        try {
          // Upload file to Cloudinary
          final response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              imageFile.path,
              folder: path,
              resourceType: CloudinaryResourceType.Image,
            ),
          );

          return response.secureUrl;
        } catch (uploadError) {
          log('Error during upload to Cloudinary: $uploadError');
          rethrow;
        }
      } else if (imageFile is String && imageFile.startsWith('http')) {
        return imageFile;
      }
      return null;
    } catch (e) {
      log('Error in _uploadImage: $e');
      return null;
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
      log('======= Starting Community Creation in Controller =======');
      log('Name: $name');
      log('Description: $description');
      log('Type: $type');
      log('Mature: $isMature');
      log('Topics: $topics');
      log('Banner image: ${bannerImage != null ? 'provided' : 'null'}');
      log('Avatar image: ${avatarImage != null ? 'provided' : 'null'}');
      log('Current user ID: ${_profileController.userId.value}');

      // Set loading flag
      log('Setting isLoading to true');
      isLoading.value = true;

      // Generate ID
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      log('Generated community ID: $id');

      // Handle images
      String? bannerUrl;
      String? avatarUrl;

      if (bannerImage != null) {
        try {
          log('Uploading banner image...');
          bannerUrl = await _uploadImage(bannerImage, 'communities/$id/banner');
          log('Banner uploaded successfully: $bannerUrl');
        } catch (e) {
          log('Error uploading banner: $e');
          // Continue with community creation even if banner upload fails
        }
      }

      if (avatarImage != null) {
        try {
          log('Uploading avatar image...');
          avatarUrl = await _uploadImage(avatarImage, 'communities/$id/avatar');
          log('Avatar uploaded successfully: $avatarUrl');
        } catch (e) {
          log('Error uploading avatar: $e');
          // Continue with community creation even if avatar upload fails
        }
      }

      // Create community object
      log('Creating community object with ID: $id');
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
      log('Community object created: ${community.toJson()}');

      log('Calling community service to save community to Firebase...');
      await _communityService.createCommunity(community);
      log('Community successfully saved to Firebase');

      // Add to recently visited and refresh
      log('Adding to recently visited communities...');
      addToRecentlyVisited(name);
      log('Fetching created communities for refresh...');
      await fetchCreatedCommunities();
      log('Communities refreshed successfully');

      log('Showing success message');
      Get.snackbar(
        'Success',
        'Community created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      log('======= Community Creation Completed Successfully =======');
    } catch (e, stackTrace) {
      log('======= Error Creating Community =======');
      log('Error details: $e');
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
      log('Setting isLoading to false');
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
