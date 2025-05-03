import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:reddit/model/reddit_comment.dart';

class RedditPostService {
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
    //add new topics here
    'india',
    'world',
    'business',
    'entertainment',
    'health',
    'science',
    'technology',
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
        log("Fetching posts for topic: $topicToFetch");
        log("URL: ${_getUrl(topicToFetch)}");

        final response = await http.get(
          Uri.parse(_getUrl(topicToFetch)),
          headers: {
            'User-Agent': 'flutter:reddit_clone:v1.0 (by /u/your_username)',
          },
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final List<dynamic> posts = jsonData['data']['children'];

          if (posts.length >= 3) {
            log("Fetched ${posts.length} posts for topic $topicToFetch");
            final processedPosts = posts
                .map((post) => post['data'] as Map<String, dynamic>)
                .toList();
            log("First post data: ${processedPosts.first}");
            return processedPosts;
          } else {
            log("Too few posts (${posts.length}) for topic $topicToFetch, trying another topic");
            lastTopic = _getRandomTopic();
            retryCount++;
            continue;
          }
        } else if (response.statusCode == 404) {
          log("Topic $topicToFetch not found (404), trying another topic");
          lastTopic = _getRandomTopic();
          retryCount++;
          continue;
        } else {
          log("Failed to load posts for $topicToFetch. Status code: ${response.statusCode}");
          log("Response body: ${response.body}");
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
      log('Fetching comments for post: $postId');

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

      log('Comments URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'flutter:reddit_clone:v1.0 (by /u/your_username)',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Reddit returns an array with 2 objects:
        // [0] = Post data
        // [1] = Comments data
        if (jsonData.length < 2) {
          log('Unexpected Reddit API response format for comments');
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

        log('Fetched ${comments.length} top-level comments');
        return comments;
      } else {
        log('Failed to fetch comments. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        throw Exception(
            'Failed to fetch comments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching comments: $e');
      throw Exception('Error fetching comments: $e');
    }
  }
}
