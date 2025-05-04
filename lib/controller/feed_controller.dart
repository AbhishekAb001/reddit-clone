import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:reddit/services/reddit_post_service.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/model/reddit_post.dart';

class FeedController extends GetxController {
  final RedditPostService _redditService = RedditPostService();
  final ProfileController _profileController = Get.find<ProfileController>();

  // Observable variables
  final RxList<RedditPost> allPosts = <RedditPost>[].obs;
  final RxBool isLoading = false.obs;

  // Stream controller for posts
  late final StreamController<List<RedditPost>> _postsController;
  Stream<List<RedditPost>> get postsStream => _postsController.stream;

  @override
  void onInit() {
    super.onInit();
    _postsController = StreamController<List<RedditPost>>.broadcast();
    if (allPosts.isEmpty) {
      fetchPostsFromInterests();
    } else {
      // If posts exist, emit them immediately
      _postsController.add(allPosts);
    }
  }

  @override
  void onClose() {
    _postsController.close();
    super.onClose();
  }

  Future<bool> fetchPostsFromInterests() async {
    try {
      isLoading.value = true;
      final interests = _profileController.interests;

      // If no interests, fetch default content
      if (interests.isEmpty) {
        final defaultPosts = await _redditService.fetchHotPosts('all');

        final redditPosts =
            defaultPosts.map((post) => RedditPost.fromJson(post)).toList();
        allPosts.value = redditPosts.take(20).toList();
        _postsController.add(allPosts);
        return true;
      }

      final List<RedditPost> fetchedPosts = [];

      for (final topic in interests) {
        try {
          final posts = await _redditService.fetchHotPosts(topic);

          final redditPosts =
              posts.map((post) => RedditPost.fromJson(post)).toList();

          if (redditPosts.length > 20) {
            fetchedPosts.addAll(redditPosts.take(20));
          } else {
            fetchedPosts.addAll(redditPosts);
          }
        } catch (e) {
          log('Error fetching posts for topic $topic: $e');
          continue;
        }
      }

      fetchedPosts.shuffle();
      allPosts.value = fetchedPosts;
      _postsController.add(fetchedPosts); // Emit posts through the stream
      return true;
    } catch (e) {
      log('Error in fetchPostsFromInterests: $e');
      // Handle error but don't clear existing posts
      if (allPosts.isNotEmpty) {
        _postsController.add(allPosts);
      }
    } finally {
      isLoading.value = false;
    }
    return false; // Ensure a boolean is always returned
  }

  Future<void> refreshFeed() async {
    allPosts.clear(); // Only clear posts when explicitly refreshing
    await fetchPostsFromInterests();
  }
}
