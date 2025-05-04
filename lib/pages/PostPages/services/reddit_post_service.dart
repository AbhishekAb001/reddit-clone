import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:reddit/model/reddit_comment.dart';
import 'package:reddit/model/reddit_post.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:reddit/utils/config.dart';

class RedditPostService {
  late final CloudinaryPublic cloudinary;
  final CloudinaryConfig cloudinaryConfig = CloudinaryConfig();

  RedditPostService() {
    cloudinary = CloudinaryPublic(
        CloudinaryConfig.cloudName, CloudinaryConfig.uploadPreset,
        cache: false);
  }

  final List<String> _topics = [
    'funny',
    'gaming',
    'news',
    'science',
    'technology',
    'movies',
    'music',
    'aww',
    'food',
    'sports',
    'worldnews',
    'politics',
    'india',
    'world',
    'business',
    'entertainment',
    'health'
  ];

  final int _maxRetries = 3;

  String _getRandomTopic() {
    final random = math.Random();
    return _topics[random.nextInt(_topics.length)];
  }

  String _getUrl(String topic) {
    return 'https://www.reddit.com/r/$topic/hot.json';
  }

  Future<List<Map<String, dynamic>>> fetchHotPosts([String? topic]) async {
    int retryCount = 0;
    String? lastTopic = topic;

    while (retryCount < _maxRetries) {
      try {
        final topicToFetch =
            (lastTopic ?? _getRandomTopic()).toLowerCase().replaceAll(' ', '');

        final response = await http.get(
          Uri.parse(_getUrl(topicToFetch)),
          headers: {
            'User-Agent': 'flutter:reddit_clone:v1.0 (by /u/my_username)',
          },
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final List<dynamic> posts = jsonData['data']['children'];

          if (posts.length >= 3) {
            final processedPosts = posts
                .map((post) => post['data'] as Map<String, dynamic>)
                .toList();
            return processedPosts;
          } else {
            lastTopic = _getRandomTopic();
            retryCount++;
            continue;
          }
        } else if (response.statusCode == 404) {
          lastTopic = _getRandomTopic();
          retryCount++;
          continue;
        } else {
          throw Exception(
              'Failed to load posts for $topicToFetch. Status code: ${response.statusCode}');
        }
      } catch (e) {
        log("Error fetching posts: $e");
        if (retryCount >= _maxRetries - 1) {
          throw Exception(
              'Error fetching Reddit posts after $_maxRetries attempts: $e');
        }
        lastTopic = _getRandomTopic();
        retryCount++;
      }
    }

    throw Exception('Failed to fetch posts after $_maxRetries attempts');
  }

  /// Fetches comments for a post by its ID
  ///
  /// [postId] - The Reddit post ID to fetch comments for
  /// [subreddit] - The subreddit the post belongs to (optional, improves reliability)
  ///
  /// Returns a list of [RedditComment] objects representing the comment tree
  Future<List<RedditComment>> fetchComments(String postId,
      {String? subreddit}) async {
    try {
      // Build the URL - if subreddit is provided, use it for more reliable fetching
      String url;
      if (subreddit != null) {
        // Clean subreddit name if it has 'r/' prefix
        final cleanSubreddit =
            subreddit.startsWith('r/') ? subreddit.substring(2) : subreddit;
        url = 'https://www.reddit.com/r/$cleanSubreddit/comments/$postId.json';
      } else {
        url = 'https://www.reddit.com/comments/$postId.json';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'flutter:reddit_clone:v1.0 (by /u/my_username)',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Reddit returns an array with 2 objects:
        // [0] = Post data
        // [1] = Comments data
        if (jsonData.length < 2) {
          return [];
        }

        final commentsData = jsonData[1]['data']['children'];
        final comments = <RedditComment>[];

        for (var commentData in commentsData) {
          // Skip "more comments" type entries
          if (commentData['kind'] == 't1') {
            comments.add(RedditComment.fromJson(commentData));
          }
        }

        return comments;
      } else {
        throw Exception(
            'Failed to fetch comments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching comments: $e');
      throw Exception('Error fetching comments: $e');
    }
  }

  /// Simulates posting a comment to a Reddit post
  /// In a real app, this would make an authenticated API call to Reddit
  ///
  /// [postId] - The Reddit post ID to comment on
  /// [commentText] - The text content of the comment
  /// [parentId] - Optional parent comment ID if this is a reply
  /// [imageUrl] - Optional image URL to attach to the comment
  /// [isVideo] - Whether the attached media is a video
  ///
  /// Returns the created [RedditComment] if successful
  Future<RedditComment> postComment(String postId, String commentText,
      {String? parentId, String? imageUrl, bool isVideo = false}) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));

      // In a real implementation, this would make an authenticated POST request
      // to Reddit's API to post the comment

      // For demo purposes, return a simulated successful response
      final createdComment = RedditComment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        author: 'YourUsername', // Would come from authenticated user
        body: commentText,
        ups: 1, // Auto-upvote by the poster
        downs: 0,
        createdUtc: DateTime.now(),
        replies: [],
        isSubmitter: true,
        parentId: parentId ?? '',
        depth: parentId != null ? 1 : 0,
        distinguished: '',
        hasImage: imageUrl != null,
        imagePath: imageUrl,
        isVideo: isVideo,
      );

      return createdComment;
    } catch (e) {
      log('Error posting comment: $e');
      throw Exception('Error posting comment: $e');
    }
  }

  /// Fetches a single post by its ID
  ///
  /// [postId] - The Reddit post ID to fetch
  ///
  /// Returns a [RedditPost] object if successful, null otherwise
  Future<RedditPost?> fetchPostById(String postId) async {
    try {
      final url = 'https://www.reddit.com/comments/$postId/.json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'flutter:reddit_clone:v1.0 (by /u/my_username)',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Reddit returns an array with 2 objects:
        // [0] = Post data
        // [1] = Comments data
        if (jsonData.length < 1) {
          return null;
        }

        final postData = jsonData[0]['data']['children'][0]['data'];

        // Handle gallery posts
        List<String>? galleryUrls;
        if (postData['is_gallery'] == true &&
            postData['gallery_data'] != null) {
          final mediaMetadata =
              postData['media_metadata'] as Map<String, dynamic>?;
          if (mediaMetadata != null) {
            galleryUrls = mediaMetadata.values
                .map((item) => item['s']?['u'] as String?)
                .where((url) => url != null)
                .cast<String>()
                .toList();
          }
        }

        // Handle preview images
        String? previewUrl;
        if (postData['preview']?['images'] != null &&
            postData['preview']['images'].isNotEmpty) {
          previewUrl = postData['preview']['images'][0]['source']['url']
              ?.replaceAll(RegExp(r'&amp;'), '&');
        }

        // Create a RedditPost from the JSON data
        return RedditPost(
          id: postData['id'] ?? '',
          title: postData['title'] ?? 'Untitled',
          subreddit: postData['subreddit'] ?? '',
          author: postData['author'] ?? 'unknown',
          ups: postData['ups'] ?? 0,
          numComments: postData['num_comments'] ?? 0,
          thumbnail: postData['thumbnail'] ?? '',
          createdUtc: DateTime.fromMillisecondsSinceEpoch(
            ((postData['created_utc'] ?? 0) * 1000).toInt(),
          ),
          selfText: postData['selftext'] ?? '',
          isSelf: postData['is_self'] ?? false,
          url: postData['url'] ?? '',
          isVideo: postData['is_video'] ?? false,
          isGallery: postData['is_gallery'] ?? false,
          mediaUrl: postData['media']?['reddit_video']?['fallback_url'],
          galleryUrls: galleryUrls,
          previewUrl: previewUrl,
          views: postData['view_count']?.toInt(),
          shares: postData['share_count']?.toInt(),
        );
      } else {
        log('Failed to fetch post. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching post by ID: $e');
      return null;
    }
  }

  /// Searches for posts based on a search query
  ///
  /// [searchQuery] - The text to search for on Reddit
  /// [limit] - Optional parameter to limit the number of results (default: 25)
  /// [sort] - Optional parameter to sort the results (default: 'relevance')
  ///
  /// Returns a list of posts matching the search query
  Future<List<Map<String, dynamic>>> searchPosts(String searchQuery,
      {int limit = 25, String sort = 'relevance'}) async {
    try {
      final encodedQuery = Uri.encodeComponent(searchQuery);
      final url =
          'https://www.reddit.com/search.json?q=$encodedQuery&limit=$limit&sort=$sort';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'flutter:reddit_clone:v1.0 (by /u/my_username)',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> posts = jsonData['data']['children'];

        if (posts.isNotEmpty) {
          final processedPosts = posts
              .map((post) => post['data'] as Map<String, dynamic>)
              .toList();
          return processedPosts;
        } else {
          return [];
        }
      } else {
        throw Exception(
            'Failed to search. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log("Error searching posts: $e");
      throw Exception('Error searching Reddit posts: $e');
    }
  }

  /// Creates a new post
  ///
  /// [title] - Required post title
  /// [subreddit] - Required subreddit to post to
  /// [content] - Optional post body text
  /// [imageFile] - Optional image file to include
  /// [flair] - Optional post flair
  /// [additionalData] - Optional additional data (polls, links, etc.)
  ///
  /// Returns a Map with 'success' boolean and either 'post' data or 'error' message
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String subreddit,
    String? content,
    dynamic imageFile,
    String? flair,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 1200));

      // Generate a random post ID
      final postId =
          'post_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, 'posts/$postId/image');
      }

      // Determine post type
      final bool isPoll =
          additionalData != null && additionalData.containsKey('poll');
      final bool hasLink =
          additionalData != null && additionalData.containsKey('link');
      final bool isSelf = content != null &&
          content.isNotEmpty &&
          imageUrl == null &&
          !isPoll &&
          !hasLink;

      // Create the post object
      final Map<String, dynamic> post = {
        'id': postId,
        'title': title,
        'subreddit': subreddit,
        'subreddit_name_prefixed': 'r/$subreddit',
        'author':
            'YourUsername', // In a real app, this would be the authenticated user
        'selftext': content ?? '',
        'thumbnail': imageUrl,
        'url': hasLink ? additionalData['link'] : imageUrl ?? '',
        'ups': 1, // Auto-upvote by the poster
        'downs': 0,
        'score': 1,
        'num_comments': 0,
        'created_utc': DateTime.now().millisecondsSinceEpoch / 1000,
        'is_self': isSelf,
        'is_video': false,
        'is_poll': isPoll,
        'link_flair_text': flair,
      };

      // Add poll data if provided
      if (isPoll) {
        // additionalData is guaranteed to be non-null if isPoll is true
        post['poll_data'] = additionalData['poll'];
      }

      // In a real app, would make an authenticated POST request to Reddit's API

      return {'success': true, 'post': post};
    } catch (e) {
      log('Error creating post: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

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
}
