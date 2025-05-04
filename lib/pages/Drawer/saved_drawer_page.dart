import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/pages/PostPages/services/reddit_post_service.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/model/reddit_comment.dart';
import 'package:reddit/widgets/post_card.dart';
import 'package:reddit/widgets/shimmer_post_card.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/PostPages/services/firestore_service.dart';

class SavedDrawerPage extends StatefulWidget {
  const SavedDrawerPage({super.key});

  @override
  State<SavedDrawerPage> createState() => _SavedDrawerPageState();
}

class _SavedDrawerPageState extends State<SavedDrawerPage> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final RedditPostService _postService = RedditPostService();
  final FirestoreService _firestoreService = FirestoreService();

  List<RedditPost> _savedPosts = [];
  bool _isLoading = true;
  List<RedditPost> _likedPosts = [];
  bool _isLoadingLiked = true;

  // For comments tab
  List<Map<String, dynamic>> _savedComments = [];
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
    _loadLikedPosts();
    _loadSavedComments();
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<RedditPost> posts = [];

      // For each saved post ID, fetch the post details
      for (String postId in _profileController.savedPosts) {
        try {
          final post = await _postService.fetchPostById(postId);
          if (post != null) {
            posts.add(post);
          }
        } catch (e) {
          print('Error fetching post $postId: $e');
        }
      }

      setState(() {
        _savedPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLikedPosts() async {
    setState(() {
      _isLoadingLiked = true;
    });

    try {
      final List<RedditPost> posts = [];

      // For each liked post ID, fetch the post details
      for (String postId in _profileController.postVotes.entries
          .where((entry) => entry.value == 1)
          .map((entry) => entry.key)
          .toList()) {
        try {
          final post = await _postService.fetchPostById(postId);
          if (post != null) {
            posts.add(post);
          }
        } catch (e) {
          print('Error fetching post $postId: $e');
        }
      }

      setState(() {
        _likedPosts = posts;
        _isLoadingLiked = false;
      });
    } catch (e) {
      print('Error loading liked posts: $e');
      setState(() {
        _isLoadingLiked = false;
      });
    }
  }

  Future<void> _loadSavedComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    try {
      final savedCommentData = <Map<String, dynamic>>[];
      print(
          'Loading saved comments. Total saved comments: ${_profileController.savedComments.length}');

      // Retrieve comment data from FirestoreService
      for (String commentId in _profileController.savedComments) {
        try {
          print('Fetching comment data for ID: $commentId');
          // Get comment data directly from FirestoreService
          final userData = await _firestoreService
              .getUserData(_profileController.userId.value);

          if (userData != null &&
              userData.containsKey('commentData_$commentId')) {
            final commentData =
                userData['commentData_$commentId'] as Map<String, dynamic>;
            print('Found comment data: $commentData');

            // Add additional data for display
            // Get post information if possible
            if (commentData.containsKey('postId')) {
              final postId = commentData['postId'] as String;
              final post = await _postService.fetchPostById(postId);
              if (post != null) {
                commentData['postTitle'] = post.title;
                commentData['subreddit'] = post.subreddit;
                print(
                    'Added post info. Title: ${post.title}, Subreddit: ${post.subreddit}');
              }
            }

            savedCommentData.add(commentData);
          } else {
            print('No comment data found for ID: $commentId');
          }
        } catch (e) {
          print('Error fetching comment data for $commentId: $e');
        }
      }

      print('Loaded ${savedCommentData.length} comments');
      setState(() {
        _savedComments = savedCommentData;
        _isLoadingComments = false;
      });
    } catch (e) {
      print('Error loading saved comments: $e');
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[500],
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'Comments'),
              Tab(text: 'Likes'),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        body: TabBarView(
          children: [
            // Posts Tab
            _isLoading
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerPostCard(),
                  )
                : Obx(() {
                    if (_profileController.savedPosts.isEmpty) {
                      return _buildEmptyView('No saved posts yet');
                    }

                    // If we have saved post IDs but no post data, trigger a refresh
                    if (_savedPosts.isEmpty &&
                        _profileController.savedPosts.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadSavedPosts();
                      });
                    }

                    return RefreshIndicator(
                      onRefresh: _loadSavedPosts,
                      child: ListView.builder(
                        itemCount: _savedPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: _savedPosts[index]);
                        },
                      ),
                    );
                  }),

            // Comments Tab
            _isLoadingComments
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerCommentCard(),
                  )
                : Obx(() {
                    if (_profileController.savedComments.isEmpty) {
                      return _buildEmptyView('No saved comments yet');
                    }

                    // If we have saved comment IDs but no comment data, trigger a refresh
                    if (_savedComments.isEmpty &&
                        _profileController.savedComments.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadSavedComments();
                      });
                    }

                    return Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: _loadSavedComments,
                          child: ListView.builder(
                            itemCount: _savedComments.length,
                            itemBuilder: (context, index) {
                              final comment = _savedComments[index];
                              return _buildSavedCommentCard(context, comment);
                            },
                          ),
                        ),
                        // Manual refresh button
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.refresh),
                            onPressed: () {
                              _loadSavedComments();
                            },
                          ),
                        ),
                      ],
                    );
                  }),

            // Likes Tab - Display Upvoted Posts
            _isLoadingLiked
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerPostCard(),
                  )
                : Obx(() {
                    final likedPostIds = _profileController.postVotes.entries
                        .where((entry) => entry.value == 1)
                        .map((entry) => entry.key)
                        .toList();

                    if (likedPostIds.isEmpty) {
                      return _buildEmptyView('No liked posts yet');
                    }

                    // If we have liked post IDs but no post data, trigger a refresh
                    if (_likedPosts.isEmpty && likedPostIds.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadLikedPosts();
                      });
                    }

                    return RefreshIndicator(
                      onRefresh: _loadLikedPosts,
                      child: ListView.builder(
                        itemCount: _likedPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: _likedPosts[index],
                            onUnliked: () {
                              // Remove the post from the UI list immediately
                              setState(() {
                                _likedPosts.removeAt(index);
                              });
                              // Then reload data from controller to ensure everything is in sync
                              _loadLikedPosts();
                            },
                          );
                        },
                      ),
                    );
                  }),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCommentCard(
      BuildContext context, Map<String, dynamic> comment) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      child: InkWell(
        onTap: () {
          // Navigate to the post with this comment
          if (comment.containsKey('postId')) {
            Get.to(
              () => PostCommentScreen(
                postId: comment['postId'],
                postTitle: comment['postTitle'] ?? 'Post',
              ),
              transition: Transition.downToUp,
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subreddit and post info
              if (comment.containsKey('subreddit'))
                Text(
                  'r/${comment['subreddit']}',
                  style: GoogleFonts.roboto(
                    color: Colors.blue,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              // Post title
              if (comment.containsKey('postTitle'))
                Padding(
                  padding: EdgeInsets.only(
                    top: screenWidth * 0.01,
                    bottom: screenWidth * 0.02,
                  ),
                  child: Text(
                    comment['postTitle'] ?? '',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Divider
              Divider(color: Colors.grey[800]),

              // Comment text
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Text(
                  comment['text'] ?? '',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Additional info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // When saved
                  if (comment.containsKey('savedAt'))
                    Text(
                      'Saved ${_getTimeAgo(comment['savedAt'])}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.03,
                      ),
                    ),

                  // Unsave button
                  TextButton.icon(
                    icon: Icon(Icons.bookmark,
                        color: Colors.white, size: screenWidth * 0.04),
                    label: Text(
                      'Unsave',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenWidth * 0.01,
                      ),
                    ),
                    onPressed: () async {
                      if (comment.containsKey('id')) {
                        await _profileController.unsaveComment(comment['id']);
                        // Refresh the comments list
                        _loadSavedComments();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(int timestamp) {
    final now = DateTime.now();
    final savedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(savedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildEmptyView(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            radius: screenWidth * 0.12,
            child: Icon(Icons.pets,
                size: screenWidth * 0.12, color: Colors.grey[400]),
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: screenWidth * 0.045,
            ),
          ),
        ],
      ),
    );
  }
}
