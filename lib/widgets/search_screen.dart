import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/services/reddit_post_service.dart';
import 'package:reddit/pages/CommunityPages/details_screen_new.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/controller/search_history_controller.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  final RedditPostService _redditPostService = RedditPostService();
  final ProfileController _profileController = Get.find<ProfileController>();
  final SearchHistoryController _searchHistoryController =
      Get.find<SearchHistoryController>();

  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _searchError = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onClose() {
    _animationController.reverse().then((_) {
      Get.back();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    try {
      final results = await _redditPostService.searchPosts(query);

      // Save search query to history
      if (query.trim().isNotEmpty) {
        _searchHistoryController.addSearchQuery(query);
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Failed to perform search. Please try again.';
        _isSearching = false;
      });
    }
  }

  void _saveToHistory(Map<String, dynamic> post) {
    _searchHistoryController.addToSearchHistory(post);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(_animation),
            child: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.white, size: screenWidth * 0.06),
                onPressed: _onClose,
              ),
              title: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Reddit',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.grey[600], size: screenWidth * 0.05),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.01,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey[600],
                                size: screenWidth * 0.04),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _performSearch(_searchController.text);
                  },
                  child: Text(
                    'Search',
                    style: GoogleFonts.inter(
                      color: Colors.blue,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(_animation),
          child: _isSearching
              ? _buildLoadingView(screenWidth, screenHeight)
              : _searchResults.isNotEmpty
                  ? _buildSearchResults(screenWidth, screenHeight)
                  : _searchError.isNotEmpty
                      ? _buildErrorView(screenWidth, screenHeight)
                      : _buildRecentSearches(screenWidth, screenHeight),
        ),
      ),
    );
  }

  Widget _buildLoadingView(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Searching...',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[800]!,
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    height: screenHeight * 0.1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: screenWidth * 0.15,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            _searchError,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.03),
          ElevatedButton(
            onPressed: () {
              _performSearch(_searchController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final post = _searchResults[index];
                final subreddit =
                    post['subreddit_name_prefixed'] ?? 'r/${post['subreddit']}';

                return InkWell(
                  onTap: () {
                    // Save to history first
                    _saveToHistory(post);

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
                      // Navigate to subreddit
                      final cleanSubreddit = subreddit.startsWith('r/')
                          ? subreddit.substring(2)
                          : subreddit;

                      Get.to(
                        () => DetailsScreen(communityName: cleanSubreddit),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              color: Colors.grey[600],
                              size: screenWidth * 0.04,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              subreddit,
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatUpvotes(post['ups'] ?? 0),
                              style: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Icon(
                              Icons.arrow_upward,
                              color: Colors.grey[400],
                              size: screenWidth * 0.03,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          post['title'] ?? 'No title',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        if (post['thumbnail'] != null &&
                            post['thumbnail'] != 'self' &&
                            post['thumbnail'] != 'default' &&
                            post['thumbnail'] != '')
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.01),
                            child: Image.network(
                              post['thumbnail'],
                              height: screenHeight * 0.1,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: screenHeight * 0.1,
                                  width: double.infinity,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                      size: screenWidth * 0.08,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_searchHistoryController.searchQueries.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _searchHistoryController.clearSearchQueries();
                    setState(() {});
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
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: Obx(() {
              final queries = _searchHistoryController.searchQueries;
              if (queries.isEmpty) {
                return Center(
                  child: Text(
                    'No recent searches',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: queries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.history,
                        color: Colors.grey[600], size: screenWidth * 0.05),
                    title: Text(
                      queries[index],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    onTap: () {
                      _searchController.text = queries[index];
                      _performSearch(queries[index]);
                    },
                    trailing: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: screenWidth * 0.04,
                      ),
                      onPressed: () {
                        _searchHistoryController.removeSearchQuery(index);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
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
