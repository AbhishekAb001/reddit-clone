import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddit/controller/feed_controller.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/widgets/post_card.dart';
import 'package:reddit/widgets/shimmer_post_card.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/pages/CommunityPages/details_screen_new.dart';
import 'package:reddit/pages/CommunityPages/user_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<bool> showBarsNotifier;

  const HomeScreen({
    super.key,
    required this.showBarsNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final FeedController _feedController = Get.find<FeedController>();
  final CommunityController _communityController =
      Get.find<CommunityController>();
  final ScrollController _scrollController = ScrollController();
  double _lastScrollPosition = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    const threshold = 5.0; // More sensitive threshold
    final currentPosition = _scrollController.position.pixels;

    // Show bars when at the top of the scroll
    if (currentPosition <= 0) {
      widget.showBarsNotifier.value = true;
      return;
    }

    // Only trigger hide/show if scroll difference exceeds threshold
    final difference = currentPosition - _lastScrollPosition;
    if (difference.abs() > threshold) {
      widget.showBarsNotifier.value =
          difference < 0; // Show when scrolling up, hide when scrolling down
      _lastScrollPosition = currentPosition;
    }
  }

  void _handlePostTap(RedditPost post) {
    // Format community name to include 'r/' prefix if not present
    final communityName = post.subreddit.startsWith('r/')
        ? post.subreddit
        : 'r/${post.subreddit}';

    // Visit the community before navigating
    _communityController.visitCommunity(communityName);

    // Check if this is a user-created community
    final isUserCreated = _communityController.userCommunities
        .any((community) => community.name == post.subreddit);

    // Navigate to appropriate screen
    if (isUserCreated) {
      Get.to(
        () => UserDetailScreen(communityName: post.subreddit),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      Get.to(
        () => DetailsScreen(communityName: post.subreddit),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => _feedController.refreshFeed(),
        child: Obx(() {
          if (_feedController.isLoading.value) {
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerPostCard(),
            );
          }

          if (_feedController.allPosts.isEmpty) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.reddit,
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.width * 0.15,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = _feedController.allPosts[index];
                      return Column(
                        children: [
                          PostCard(
                            post: post,
                            onTap: () => _handlePostTap(post),
                          ),
                          if (index < _feedController.allPosts.length - 1)
                            Divider(
                              color: Colors.grey[800],
                              thickness: 1,
                              height: 1,
                            ),
                        ],
                      );
                    },
                    childCount: _feedController.allPosts.length,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
