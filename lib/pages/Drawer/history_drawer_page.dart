import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/controller/search_history_controller.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';
import 'package:reddit/widgets/shimmer_post_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryDrawerPage extends StatefulWidget {
  const HistoryDrawerPage({super.key});

  @override
  State<HistoryDrawerPage> createState() => _HistoryDrawerPageState();
}

class _HistoryDrawerPageState extends State<HistoryDrawerPage> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final SearchHistoryController _searchHistoryController =
      Get.find<SearchHistoryController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'History',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: screenWidth * 0.06),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Recent',
                icon: Icon(Icons.history, size: screenWidth * 0.05),
              ),
              Tab(
                text: 'Search History',
                icon: Icon(Icons.search, size: screenWidth * 0.05),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecentHistory(screenWidth, screenHeight),
            _buildSearchHistory(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(double screenWidth, double screenHeight) {
    return Obx(() {
      final history = _profileController.postViewHistory;

      if (history.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: screenWidth * 0.15,
                color: Colors.grey[700],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'No history yet',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Posts you view will appear here',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Viewed',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: Text(
                          'Clear History',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        content: Text(
                          'Are you sure you want to clear your viewing history?',
                          style: GoogleFonts.inter(color: Colors.grey[300]),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(color: Colors.grey[300]),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _profileController.clearViewHistory();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Clear',
                              style: GoogleFonts.inter(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      color: Colors.blue,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryItem(context, item);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchHistory(double screenWidth, double screenHeight) {
    return Obx(() {
      final searchHistory = _searchHistoryController.searchHistory;

      if (searchHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: screenWidth * 0.15,
                color: Colors.grey[700],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'No search history yet',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Posts you view from search will appear here',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search History',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: Text(
                          'Clear Search History',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        content: Text(
                          'Are you sure you want to clear your search history?',
                          style: GoogleFonts.inter(color: Colors.grey[300]),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(color: Colors.grey[300]),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _searchHistoryController.clearSearchHistory();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Clear',
                              style: GoogleFonts.inter(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      color: Colors.blue,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                final post = searchHistory[index];
                return _buildSearchHistoryItem(context, post);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final timestamp = item['viewedAt'] ?? DateTime.now().millisecondsSinceEpoch;

    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      child: InkWell(
        onTap: () {
          // Navigate to post
          Get.to(
            () => PostCommentScreen(
              postId: item['id'],
              postTitle: item['postTitle'],
              subreddit: item['subreddit'],
              postThumbnail: item['thumbnail'],
            ),
            transition: Transition.rightToLeft,
          );
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: screenWidth * 0.04,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(timestamp),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.02),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['thumbnail'] != null &&
                      item['thumbnail'] != 'self' &&
                      item['thumbnail'] != 'default' &&
                      item['thumbnail'].toString().startsWith('http'))
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(item['thumbnail']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(right: screenWidth * 0.03),
                    )
                  else
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.only(right: screenWidth * 0.03),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: screenWidth * 0.08,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'r/${item['subreddit']}',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.035,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          item['postTitle'] ?? 'Post title',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistoryItem(
      BuildContext context, Map<String, dynamic> post) {
    final screenWidth = MediaQuery.of(context).size.width;
    final subreddit =
        post['subreddit_name_prefixed'] ?? 'r/${post['subreddit']}';

    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      child: InkWell(
        onTap: () {
          if (post['is_self'] == true) {
            // Navigate to post comments
            Get.to(
              () => PostCommentScreen(
                postId: post['id'],
                postTitle: post['title'],
                subreddit: subreddit,
                postThumbnail: post['thumbnail'],
                postUrl: post['url'],
              ),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          } else {
            // Navigate to post comments anyway for search history
            Get.to(
              () => PostCommentScreen(
                postId: post['id'],
                postTitle: post['title'],
                subreddit: subreddit,
                postThumbnail: post['thumbnail'],
                postUrl: post['url'],
              ),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search,
                    size: screenWidth * 0.04,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    subreddit,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatUpvotes(post['ups'] ?? 0),
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.grey[400],
                    size: screenWidth * 0.035,
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.02),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post['thumbnail'] != null &&
                      post['thumbnail'] != 'self' &&
                      post['thumbnail'] != 'default' &&
                      post['thumbnail'] != '')
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post['thumbnail']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(right: screenWidth * 0.03),
                    )
                  else
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.only(right: screenWidth * 0.03),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: screenWidth * 0.08,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'] ?? 'Post title',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              color: Colors.grey[500],
                              size: screenWidth * 0.04,
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              '${post['num_comments'] ?? 0} comments',
                              style: GoogleFonts.inter(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUpvotes(int upvotes) {
    if (upvotes >= 1000000) {
      return '${(upvotes / 1000000).toStringAsFixed(1)}M';
    } else if (upvotes >= 1000) {
      return '${(upvotes / 1000).toStringAsFixed(1)}K';
    }
    return upvotes.toString();
  }
}
