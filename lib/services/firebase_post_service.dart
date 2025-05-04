import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:get/get.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/utils/config.dart';
import 'dart:io';

class FirebasePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName, CloudinaryConfig.uploadPreset,
      cache: false);
  final ProfileController _profileController = Get.find<ProfileController>();

  /// Creates a new post in Firebase Firestore
  ///
  /// [title] - Required post title
  /// [subreddit] - Required subreddit to post to
  /// [content] - Optional post body text
  /// [imageFile] - Optional image file to include
  /// [videoFile] - Optional video file to include
  /// [flair] - Optional post flair
  /// [additionalData] - Optional additional data (polls, links, etc.)
  ///
  /// Returns a Map with 'success' boolean and either 'post' data or 'error' message
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String subreddit,
    String? content,
    File? imageFile,
    File? videoFile,
    String? flair,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      log('Starting createPost with title: $title, subreddit: $subreddit');

      // Get user ID from profile controller
      final String userId = _profileController.userId.value;
      final String username = _profileController.username.value.isNotEmpty
          ? _profileController.username.value
          : 'Anonymous';
      log('Creating post as user: $username (ID: $userId)');

      // Generate a post ID
      final String postId = 'post_${DateTime.now().millisecondsSinceEpoch}';
      log('Generated post ID: $postId');

      // Upload media files if provided
      String? imageUrl;
      String? videoUrl;

      if (imageFile != null) {
        try {
          log('Uploading image file: ${imageFile.path}');
          if (!await imageFile.exists()) {
            throw Exception('Image file does not exist');
          }
          imageUrl = await _uploadFile(imageFile, 'posts/$postId/image');
          if (imageUrl == null) {
            throw Exception('Failed to get download URL for image');
          }
          log('Image uploaded successfully. URL: $imageUrl');
        } catch (e) {
          log('Error uploading image: $e');
          // Continue without image if upload fails
        }
      }

      if (videoFile != null) {
        try {
          log('Uploading video file: ${videoFile.path}');
          if (!await videoFile.exists()) {
            throw Exception('Video file does not exist');
          }
          videoUrl = await _uploadFile(videoFile, 'posts/$postId/video');
          if (videoUrl == null) {
            throw Exception('Failed to get download URL for video');
          }
          log('Video uploaded successfully. URL: $videoUrl');
        } catch (e) {
          log('Error uploading video: $e');
          // Continue without video if upload fails
        }
      }

      // Determine post type
      final bool isPoll = additionalData?.containsKey('poll') ?? false;
      final bool hasLink = additionalData?.containsKey('link') ?? false;
      final bool isImage = imageUrl != null;
      final bool isVideo = videoUrl != null;
      final bool isSelf = content != null &&
          content.isNotEmpty &&
          !isImage &&
          !isVideo &&
          !isPoll &&
          !hasLink;

      log('Post type details - isPoll: $isPoll, hasLink: $hasLink, isImage: $isImage, isVideo: $isVideo, isSelf: $isSelf');

      // Create post data
      final Map<String, dynamic> postData = {
        'id': postId,
        'title': title,
        'subreddit': subreddit,
        'subreddit_name_prefixed': subreddit,
        'author': username,
        'author_id': userId,
        'selftext': content ?? '',
        'thumbnail': imageUrl,
        'image_url': imageUrl,
        'video_url': videoUrl,
        'url': hasLink && additionalData != null ? additionalData['link'] : (imageUrl ?? videoUrl ?? ''),
        'ups': 1, // Auto-upvote by the poster
        'upvoted_by': [userId],
        'downs': 0,
        'score': 1,
        'num_comments': 0,
        'created_utc': FieldValue.serverTimestamp(),
        'is_self': isSelf,
        'is_image': isImage,
        'is_video': isVideo,
        'is_poll': isPoll,
        'is_link': hasLink,
        'link_flair_text': flair,
      };

      log('Created post data structure: ${postData.toString()}');

      if (isPoll && additionalData != null) {
        postData['poll_data'] = additionalData['poll'];
        log('Added poll data: ${additionalData['poll']}');
      }

      if (hasLink && additionalData != null) {
        postData['link'] = additionalData['link'];
        log('Added link data: ${additionalData['link']}');
      }

      try {
        log('Searching for community: $subreddit');
        String? communityDocId = await _findCommunityDocumentId(subreddit);
        log('Found community document ID: $communityDocId');

        if (communityDocId == null) {
          log('Warning: Community document ID is null for subreddit: $subreddit');
        }

        await _firestore
            .collection('communities')
            .doc(communityDocId)
            .collection('posts')
            .doc(postId)
            .set(postData);

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('posts')
            .doc(postId)
            .set(postData);
        log('Successfully saved post to community collection');
      } catch (e) {
        log('Error saving post to community: $e');
        log('Stack trace: ${StackTrace.current}');
      }

      // Create RedditPost object to return
      final post = RedditPost(
        id: postId,
        title: title,
        subreddit: subreddit,
        author: username,
        ups: 1,
        numComments: 0,
        thumbnail: imageUrl ?? '',
        createdUtc: DateTime.now(),
        selfText: content ?? '',
        isSelf: isSelf,
        url: hasLink && additionalData != null ? additionalData['link'] : (imageUrl ?? videoUrl ?? ''),
        isVideo: isVideo,
        isGallery: false,
        mediaUrl: videoUrl,
        previewUrl: imageUrl,
      );

      log('Successfully created RedditPost object: ${post.toString()}');
      return {'success': true, 'post': post};
    } catch (e) {
      log('Error creating post in Firebase: $e');
      log('Stack trace: ${StackTrace.current}');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Finds the document ID of a community by its name
  Future<String?> _findCommunityDocumentId(String communityName) async {
    try {
      // Clean community name
      final String cleanName = communityName.startsWith('r/')
          ? communityName.substring(2)
          : communityName;
      log('Finding community document ID for: $cleanName');
      // Query Firestore to find the community document ID
      final querySnapshot = await _firestore
          .collection('communities')
          .where('name', isEqualTo: "r/$cleanName")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        log('Community not found: $communityName');
        return null;
      }
    } catch (e) {
      log('Error finding community document ID: $e');
      return null;
    }
  }

  /// Uploads a file to Cloudinary and returns the download URL
  Future<String?> _uploadFile(File file, String folder) async {
    try {
      // Upload the file to Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      log('File uploaded successfully to Cloudinary: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      log('Error uploading file to Cloudinary: $e');
      return null;
    }
  }

  /// Fetches posts for a specific community
  Future<List<RedditPost>> fetchCommunityPosts(String communityName,
      {int limit = 10}) async {
    try {
      final String cleanName = communityName.startsWith('r/')
          ? communityName.substring(2)
          : communityName;

      String? communityDocId = await _findCommunityDocumentId(cleanName);

      if (communityDocId == null) {
        log('Could not find community: $cleanName');
        return [];
      }

      // Query Firestore using the found document ID
      final snapshot = await _firestore
          .collection('communities')
          .doc(communityDocId)
          .collection('posts')
          .orderBy('created_utc', descending: true)
          .limit(limit)
          .get();

      // Convert to RedditPost objects
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _convertToRedditPost(data);
      }).toList();
    } catch (e) {
      log('Error fetching community posts: $e');
      return [];
    }
  }

  /// Fetches posts created by a specific user
  Future<List<RedditPost>> fetchUserPosts(String userId,
      {int limit = 10}) async {
    try {
      log('Fetching posts for user: $userId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .orderBy('created_utc', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        log('No posts found for user: $userId');
        return [];
      }

      // Convert to RedditPost objects
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _convertToRedditPost(data);
      }).toList();
    } catch (e) {
      log('Error fetching user posts: $e');
      return [];
    }
  }

  /// Converts a Firestore document to a RedditPost object
  RedditPost _convertToRedditPost(Map<String, dynamic> data) {
    // Handle timestamp conversion
    DateTime createdUtc;
    if (data['created_utc'] is Timestamp) {
      createdUtc = (data['created_utc'] as Timestamp).toDate();
    } else if (data['created_utc'] is int) {
      createdUtc = DateTime.fromMillisecondsSinceEpoch(data['created_utc'] * 1000);
    } else if (data['created_utc'] is double) {
      createdUtc = DateTime.fromMillisecondsSinceEpoch((data['created_utc'] * 1000).toInt());
    } else {
      createdUtc = DateTime.now();
    }

    return RedditPost(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subreddit: data['subreddit'] ?? '',
      author: data['author'] ?? 'Anonymous',
      ups: data['ups'] ?? 0,
      numComments: data['num_comments'] ?? 0,
      thumbnail: data['thumbnail'] ?? '',
      createdUtc: createdUtc,
      selfText: data['selftext'] ?? '',
      isSelf: data['is_self'] ?? false,
      url: data['url'] ?? '',
      isVideo: data['is_video'] ?? false,
      isGallery: false,
      mediaUrl: data['video_url'],
      previewUrl: data['image_url'],
    );
  }

  /// Check if a community exists and get its information
  Future<Map<String, dynamic>?> getCommunityInfo(String communityName) async {
    try {
      // Find community document ID first
      String? communityDocId = await _findCommunityDocumentId(communityName);

      if (communityDocId == null) {
        return null;
      }

      final communityDoc =
          await _firestore.collection('communities').doc(communityDocId).get();

      if (communityDoc.exists) {
        return communityDoc.data() as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      log('Error fetching community info: $e');
      return null;
    }
  }

  /// Create a new community
  Future<bool> createCommunity(String communityName, String userId) async {
    try {
      // Generate a document ID for the community
      final String docId = 'community_${DateTime.now().millisecondsSinceEpoch}';

      final communityRef = _firestore.collection('communities').doc(docId);

      await communityRef.set({
        'id': docId,
        'name': communityName,
        'title': communityName,
        'description': 'Community for ${communityName}',
        'publicDescription': 'Community for ${communityName}',
        'memberCount': 1,
        'onlineCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'public',
        'isMature': false,
        'createdBy': userId,
        'topics': [],
        'over18': false,
        'subredditType': 'public',
      });

      // Add user as a member of this community
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('joined_communities')
          .doc(communityName)
          .set({
        'name': communityName,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      log('Created new community: $communityName with doc ID: $docId');
      return true;
    } catch (e) {
      log('Error creating community: $e');
      return false;
    }
  }

  /// Save a post to a user-created community
  Future<bool> savePostToUserCreatedCommunity(
      String communityDocId, Map<String, dynamic> postData) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityDocId)
          .collection('posts')
          .doc(postData['id'])
          .set(postData);

      log('Post saved to user-created community with doc ID: $communityDocId');
      return true;
    } catch (e) {
      log('Error saving post to user-created community: $e');
      return false;
    }
  }

  /// Save a post to an existing community (not created by the user)
  Future<bool> savePostToExistingCommunity(
      String communityDocId, Map<String, dynamic> postData) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityDocId)
          .collection('posts')
          .doc(postData['id'])
          .set(postData);

      log('Post saved to existing community with doc ID: $communityDocId');
      return true;
    } catch (e) {
      log('Error saving post to existing community: $e');
      return false;
    }
  }

  /// Save a post to a new community that doesn't exist yet
  Future<bool> savePostToNewCommunity(String communityName, String userId,
      Map<String, dynamic> postData) async {
    try {
      bool communityCreated = await createCommunity(communityName, userId);

      if (communityCreated) {
        // Find the community document ID we just created
        String? communityDocId = await _findCommunityDocumentId(communityName);

        if (communityDocId == null) {
          log('Failed to find newly created community');
          return false;
        }

        // Then save the post to the new community
        await _firestore
            .collection('communities')
            .doc(communityDocId)
            .collection('posts')
            .doc(postData['id'])
            .set(postData);

        log('Post saved to newly created community: $communityName');
        return true;
      } else {
        log('Failed to create community for post');
        return false;
      }
    } catch (e) {
      log('Error saving post to new community: $e');
      return false;
    }
  }

  /// Save a post to the global feed
  Future<bool> savePostToGlobalFeed(Map<String, dynamic> postData) async {
    try {
      await _firestore
          .collection('all_posts')
          .doc(postData['id'])
          .set(postData);

      log('Post saved to global feed');
      return true;
    } catch (e) {
      log('Error saving post to global feed: $e');
      return false;
    }
  }

  /// Save a post to the user's profile
  Future<bool> savePostToUserProfile(
      String userId, Map<String, dynamic> postData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postData['id'])
          .set(postData);

      log('Post saved to user profile');
      return true;
    } catch (e) {
      log('Error saving post to user profile: $e');
      return false;
    }
  }

  /// Main method to save a post to Firebase
  /// This handles all the logic for where to save the post based on the community
  Future<bool> savePost(Map<String, dynamic> postData, String communityName,
      String userId) async {
    try {
      // Always save to user profile and global feed
      await savePostToUserProfile(userId, postData);
      await savePostToGlobalFeed(postData);

      // Find community document ID by name
      String? communityDocId = await _findCommunityDocumentId(communityName);

      // Check if community exists
      if (communityDocId != null) {
        // Community exists - get its info
        DocumentSnapshot communityDoc = await _firestore
            .collection('communities')
            .doc(communityDocId)
            .get();

        Map<String, dynamic>? communityInfo = communityDoc.exists
            ? communityDoc.data() as Map<String, dynamic>
            : null;

        if (communityInfo != null) {
          // Check if user created this community
          if (communityInfo['createdBy'] == userId) {
            // User created community
            await savePostToUserCreatedCommunity(communityDocId, postData);
          } else {
            // Existing community not created by user
            await savePostToExistingCommunity(communityDocId, postData);
          }
        }
      } else {
        // Community doesn't exist yet - create it
        await savePostToNewCommunity(communityName, userId, postData);
      }

      log('Post successfully saved to Firebase: ${postData['id']}');
      return true;
    } catch (e) {
      log('Error saving post to Firebase: $e');
      return false;
    }
  }
}
