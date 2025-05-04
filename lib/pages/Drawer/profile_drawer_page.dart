import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';
import 'package:reddit/widgets/shimmer_post_card.dart';
import 'package:reddit/widgets/post_card.dart';

class ProfileDrawerPage extends StatelessWidget {
  const ProfileDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController _profileController = Get.find<ProfileController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.22,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A237E), Colors.black],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      bottom: 0,
                      child: Obx(() => AvatarPlus(
                            _profileController.photoUrl.value.isNotEmpty
                                ? _profileController.photoUrl.value
                                : (_profileController.username.value.isNotEmpty
                                    ? _profileController.username.value
                                    : 'Redditor'),
                            height: screenWidth * 0.22,
                            width: screenWidth * 0.22,
                          )),
                    ),
                    Positioned(
                      left: 24 + screenWidth * 0.16,
                      bottom: screenWidth * 0.04,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                        ),
                        onPressed: () {},
                        child: const Text('Edit',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 16, right: 24),
                child: Obx(() => Text(
                      _profileController.username.value,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 8, right: 24),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events,
                        color: Colors.amberAccent, size: 22),
                    SizedBox(width: 6),
                    Text('5 achievements',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 8, right: 24),
                child: Obx(() => Text(
                      'u/${_profileController.username.value} • ${_profileController.karma.value} karma • ${DateTime.now().year} Gold',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 15),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 4, right: 24),
                child: Text('0 Gold',
                    style:
                        GoogleFonts.inter(color: Colors.white70, fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 12, right: 24),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add social link',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.orange,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Comments'),
                  Tab(text: 'About'),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.45,
                child: TabBarView(
                  children: [
                    UserPostsTab(),
                    UserCommentsTab(),
                    Center(
                        child: Text('No About Info',
                            style: TextStyle(color: Colors.white54))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCommentsTab extends StatelessWidget {
  const UserCommentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final comments = profileController.userComments;

      // Check if data is still loading
      if (profileController.isLoadingUserData.value) {
        return ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCommentCard(),
        );
      }

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.comment_outlined, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your comments will appear here',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await profileController.loadUserData();
        },
        child: ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentCard(context, comment);
          },
        ),
      );
    });
  }

  Widget _buildCommentCard(BuildContext context, Map<String, dynamic> comment) {
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
                subreddit: comment['subreddit'],
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
                  // When commented
                  if (comment.containsKey('createdAt'))
                    Text(
                      'Posted ${_getTimeAgo(comment['createdAt'])}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.03,
                      ),
                    ),

                  // Go to post icon
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                    size: screenWidth * 0.04,
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
    final commentedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(commentedAt);

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
}

class UserPostsTab extends StatelessWidget {
  const UserPostsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return FutureBuilder<List<RedditPost>>(
      future: profileController.getUserPosts(),
      builder: (context, snapshot) {
        // Check if data is still loading
        if (profileController.isLoadingUserData.value || !snapshot.hasData) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerPostCard(),
          );
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add_outlined,
                    size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your posts will appear here',
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await profileController.loadUserData();
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          ),
        );
      },
    );
  }
}
