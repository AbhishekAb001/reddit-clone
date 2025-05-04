import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/model/reddit_comment.dart';
import 'package:reddit/services/reddit_post_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/widgets/post_menu_bottom_sheet.dart';
import 'dart:io';

class PostCommentScreen extends StatefulWidget {
  final RedditPost? postDetails;
  final String? postId;
  final String? subreddit;
  final String? postTitle;
  final String? postUrl;
  final String? postThumbnail;

  const PostCommentScreen({
    Key? key,
    this.postDetails,
    this.postId,
    this.subreddit,
    this.postTitle,
    this.postUrl,
    this.postThumbnail,
  }) : super(key: key);

  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isLoading = true;
  List<RedditComment> _comments = [];
  bool _showCommentBox = false;
  String? _replyingToAuthor;
  String? _selectedImagePath;
  File? _selectedImageFile;
  bool _isVideoComment = false;
  final RedditPostService _redditPostService = RedditPostService();
  final ImagePicker _imagePicker = ImagePicker();
  final ProfileController _profileController = Get.find<ProfileController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool _sortByBest = true;
  bool _isImageUploading = false;
  // Map to store user votes on comments
  Map<String, int> _userVotes = {};

  // Variables for post voting
  int _postUpvotes = 0;
  bool _postUpvoted = false;
  bool _postDownvoted = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // Fetch comments from Reddit API
  Future<void> _fetchComments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if we have a post ID from widget
      final postId = widget.postId ?? (widget.postDetails?.id);
      final subreddit = widget.subreddit ?? (widget.postDetails?.subreddit);

      if (postId != null) {
        // Fetch real comments
        final comments = await _redditPostService.fetchComments(postId,
            subreddit: subreddit);
        log('comments: $comments');
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      } else {
        // Fallback to mock data if no post ID is available
        _loadMockComments();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
      // Fallback to mock data on error
      _loadMockComments();
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mock comments for demonstration when API fails or for testing
  void _loadMockComments() {
    _comments = [
      RedditComment(
        id: '1',
        author: 'Select-Bread2173',
        body: '2025 and we still figuring out roads',
        ups: 118,
        downs: 0,
        createdUtc: DateTime.now().subtract(const Duration(hours: 8)),
        replies: [],
        isSubmitter: false,
        parentId: '',
        depth: 0,
        distinguished: '',
        hasImage: true,
        imagePath: 'https://picsum.photos/id/237/800/400',
        isVideo: false,
      ),
      RedditComment(
        id: '2',
        author: 'hahahadev',
        body:
            'I no longer consider our road makers legitimate, we should outsource to other countries who have better roads than us despite being poorer or smaller than us.',
        ups: 51,
        downs: 0,
        createdUtc: DateTime.now().subtract(const Duration(hours: 7)),
        replies: [],
        isSubmitter: false,
        parentId: '',
        depth: 0,
        distinguished: '',
        hasImage: false,
      ),
      RedditComment(
        id: '3',
        author: 'ImprefectKnight',
        body:
            'Wait until they set up for commencing in English instead of Hindi, then you\'ll see some real progress!',
        ups: 24,
        downs: 0,
        createdUtc: DateTime.now().subtract(const Duration(hours: 1)),
        replies: [
          RedditComment(
            id: '4',
            author: 'YourUsername',
            body: 'Look at this pothole I found yesterday!',
            ups: 5,
            downs: 0,
            createdUtc: DateTime.now().subtract(const Duration(minutes: 30)),
            replies: [],
            isSubmitter: true,
            parentId: '3',
            depth: 1,
            distinguished: '',
            hasImage: true,
            imagePath: 'https://picsum.photos/id/58/800/600',
            isVideo: false,
          )
        ],
        isSubmitter: false,
        parentId: '',
        depth: 0,
        distinguished: '',
        hasImage: false,
      ),
    ];

    // Initialize expanded state for comments with replies
    for (var comment in _comments) {
      if (comment.replies.isNotEmpty) {
        _userVotes['expanded_${comment.id}'] = 1; // Start with replies visible
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch real comments
    _fetchComments();
    // Sort comments on initial load
    Future.delayed(const Duration(milliseconds: 100), _sortComments);

    // Initialize post upvotes from the post details if available
    if (widget.postDetails != null) {
      _postUpvotes = widget.postDetails!.ups;
    }

    // Check if the user has already voted on this post
    final postId = widget.postId ?? (widget.postDetails?.id);
    if (postId != null) {
      final voteStatus = _profileController.getPostVoteStatus(postId);
      if (voteStatus == 1) {
        _postUpvoted = true;
      } else if (voteStatus == -1) {
        _postDownvoted = true;
      }

      // Add post to view history
      _addToViewHistory(postId);
    }
  }

  void _addToViewHistory(String postId) {
    // Add a small delay to avoid blocking UI
    Future.delayed(Duration.zero, () {
      _profileController.addToViewHistory(
        postId,
        widget.postTitle ?? widget.postDetails?.title ?? 'Post',
        widget.subreddit ?? widget.postDetails?.subreddit ?? 'subreddit',
        postThumbnail: widget.postThumbnail ?? widget.postDetails?.thumbnail,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: _isLoading
              ? _buildLoadingIndicator()
              : _comments.isEmpty
                  ? _buildEmptyCommentsView(context)
                  : RefreshIndicator(
                      onRefresh: _fetchComments,
                      color: Colors.orangeAccent,
                      child: _buildPostWithComments(context),
                    ),
        ),
        _buildCommentBar(context),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;
    final postId = widget.postId ?? (widget.postDetails?.id);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
                color: Colors.white,
                size: isSmallScreen ? screenWidth * 0.06 : screenWidth * 0.05),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.subreddit != null
                          ? 'r/${widget.subreddit}'
                          : widget.postDetails?.subreddit != null
                              ? 'r/${widget.postDetails!.subreddit}'
                              : 'r/Post',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isSmallScreen
                            ? screenWidth * 0.035
                            : screenWidth * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'u/${_comments.isNotEmpty ? _comments[0].author : 'unknown'}',
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: isSmallScreen
                            ? screenWidth * 0.035
                            : screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.1),
                  child: Text(
                    widget.postTitle ??
                        widget.postDetails?.title ??
                        'Loading post...',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: isSmallScreen
                          ? screenWidth * 0.04
                          : screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Add bookmark button
          if (postId != null)
            Obx(() {
              final isSaved = _profileController.isPostSaved(postId);
              return IconButton(
                onPressed: () {
                  _profileController.toggleSavePost(postId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSaved ? 'Post unsaved' : 'Post saved'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                  color: Colors.white,
                  size: isSmallScreen ? screenWidth * 0.06 : screenWidth * 0.05,
                ),
              );
            }),
          IconButton(
            onPressed: () {
              if (widget.postUrl != null) {
                // Show share bottom sheet
                showShareBottomSheet(
                  context,
                  postUrl: widget.postUrl,
                  postTitle: widget.postTitle,
                  postDetails: widget.postDetails,
                );
              }
            },
            icon: Icon(Icons.ios_share_outlined,
                color: Colors.white,
                size: isSmallScreen ? screenWidth * 0.06 : screenWidth * 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: _buildCommentShimmer(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentShimmer(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info shimmer
          Row(
            children: [
              Container(
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Container(
                width: screenWidth * 0.4,
                height: screenHeight * 0.018,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Comment body shimmer
          Container(
            width: double.infinity,
            height: screenHeight * 0.018,
            color: Colors.white,
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.018,
            color: Colors.white,
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.018,
            color: Colors.white,
          ),
          SizedBox(height: screenHeight * 0.02),

          // Comment actions shimmer
          Row(
            children: [
              Container(
                width: screenWidth * 0.2,
                height: screenHeight * 0.03,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Container(
                width: screenWidth * 0.2,
                height: screenHeight * 0.03,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCommentsView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPostHeader(context),
          _buildDivider(),
          Container(
            height: screenHeight * 0.3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: screenWidth * 0.15,
                    color: Colors.grey[700],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'No comments yet',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Be the first to add a comment',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: _fetchComments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Refresh',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostWithComments(BuildContext context) {
    return ListView(
      children: [
        _buildPostHeader(context),
        _buildDivider(),
        ..._comments
            .map((comment) => _buildCommentItem(context, comment))
            .toList(),
      ],
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    final subreddit =
        widget.subreddit ?? (widget.postDetails?.subreddit ?? 'subreddit');
    final postId = widget.postId ?? (widget.postDetails?.id);

    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subreddit and user info
          Row(
            children: [
              CircleAvatar(
                radius:
                    isSmallScreen ? screenWidth * 0.03 : screenWidth * 0.035,
                backgroundColor: Colors.grey[800],
                child: Text(
                  'r',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen
                        ? screenWidth * 0.03
                        : screenWidth * 0.035,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'r/$subreddit',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize:
                      isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.04,
                ),
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                '• u/user • 9h',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize:
                      isSmallScreen ? screenWidth * 0.03 : screenWidth * 0.035,
                ),
              ),
              const Spacer(),

              // Join button
              Obx(() {
                final isJoined =
                    _profileController.isCommunityJoined(subreddit);
                return OutlinedButton(
                  onPressed: () {
                    _profileController.toggleCommunityJoinStatus(subreddit);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isJoined ? Colors.transparent : Colors.blue,
                    side: BorderSide(
                        color: isJoined ? Colors.white : Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(screenWidth * 0.18, screenWidth * 0.08),
                  ),
                  child: Text(
                    isJoined ? 'Joined' : 'Join',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Post title
          Text(
            widget.postTitle ?? 'Post title',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize:
                  isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          // Post image if available
          if (widget.postThumbnail != null &&
              widget.postThumbnail != 'self' &&
              widget.postThumbnail != '')
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.3,
                ),
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.postThumbnail!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[900]!,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      color: Colors.white,
                      height: screenHeight * 0.2,
                      width: double.infinity,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    height: screenHeight * 0.2,
                    child: Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey, size: screenWidth * 0.08),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              height: screenHeight * 0.2,
              width: double.infinity,
              child: Center(
                child: Icon(Icons.image_not_supported,
                    color: Colors.grey, size: screenWidth * 0.08),
              ),
            ),

          SizedBox(height: screenHeight * 0.015),

          // Post stats
          Container(
            height: isSmallScreen ? screenHeight * 0.05 : screenHeight * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Upvote/downvote
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.005),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  child: Row(
                    children: [
                      Obx(() {
                        final isUpvoted = postId != null
                            ? _profileController.isPostUpvoted(postId)
                            : false;
                        return GestureDetector(
                          onTap: () async {
                            if (postId != null) {
                              await _profileController.upvotePost(postId);
                              setState(() {
                                _postUpvoted =
                                    _profileController.isPostUpvoted(postId);
                                _postDownvoted =
                                    _profileController.isPostDownvoted(postId);
                                // Update the upvote count accordingly
                                if (_postUpvoted) {
                                  _postUpvotes = widget.postDetails != null
                                      ? widget.postDetails!.ups + 1
                                      : 1;
                                } else {
                                  _postUpvotes = widget.postDetails != null
                                      ? widget.postDetails!.ups
                                      : 0;
                                }
                                if (_postDownvoted) {
                                  _postUpvotes--;
                                }
                              });
                            }
                          },
                          child: Icon(
                            Icons.arrow_upward,
                            color: isUpvoted ? Colors.orange : Colors.grey,
                            size: isSmallScreen
                                ? screenWidth * 0.05
                                : screenWidth * 0.055,
                          ),
                        );
                      }),
                      SizedBox(width: screenWidth * 0.02),
                      Obx(() {
                        final isUpvoted = postId != null
                            ? _profileController.isPostUpvoted(postId)
                            : false;
                        final isDownvoted = postId != null
                            ? _profileController.isPostDownvoted(postId)
                            : false;
                        return Text(
                          '$_postUpvotes',
                          style: GoogleFonts.inter(
                            color: isUpvoted
                                ? Colors.orange
                                : (isDownvoted ? Colors.blue : Colors.white),
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen
                                ? screenWidth * 0.035
                                : screenWidth * 0.04,
                          ),
                        );
                      }),
                      SizedBox(width: screenWidth * 0.02),
                      Obx(() {
                        final isDownvoted = postId != null
                            ? _profileController.isPostDownvoted(postId)
                            : false;
                        return GestureDetector(
                          onTap: () async {
                            if (postId != null) {
                              await _profileController.downvotePost(postId);
                              setState(() {
                                _postUpvoted =
                                    _profileController.isPostUpvoted(postId);
                                _postDownvoted =
                                    _profileController.isPostDownvoted(postId);
                                // Update the upvote count accordingly
                                if (_postDownvoted) {
                                  _postUpvotes = widget.postDetails != null
                                      ? widget.postDetails!.ups - 1
                                      : -1;
                                } else {
                                  _postUpvotes = widget.postDetails != null
                                      ? widget.postDetails!.ups
                                      : 0;
                                }
                                if (_postUpvoted) {
                                  _postUpvotes++;
                                }
                              });
                            }
                          },
                          child: Icon(
                            Icons.arrow_downward,
                            color: isDownvoted ? Colors.blue : Colors.grey,
                            size: isSmallScreen
                                ? screenWidth * 0.05
                                : screenWidth * 0.055,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Comments count
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.005),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: Colors.grey,
                          size: isSmallScreen
                              ? screenWidth * 0.045
                              : screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        '${_comments.length}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen
                              ? screenWidth * 0.035
                              : screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),

                // Share button
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.005),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.ios_share,
                          color: Colors.grey,
                          size: isSmallScreen
                              ? screenWidth * 0.045
                              : screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Share',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen
                              ? screenWidth * 0.035
                              : screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      color: Colors.grey[900],
    );
  }

  Widget _buildCommentItem(BuildContext context, RedditComment comment) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    // Get user's vote for this comment (default: 0 - no vote)
    final userVote = _userVotes[comment.id] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar column on the left
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                top: screenWidth * 0.03,
                right: screenWidth * 0.01,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isSmallScreen
                        ? screenWidth * 0.035
                        : screenWidth * 0.04,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: NetworkImage(
                      comment.author == 'YourUsername'
                          ? 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_0.png'
                          : 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png',
                    ),
                  ),
                  // Vertical line connecting to replies
                  if (comment.replies.isNotEmpty &&
                      _userVotes.containsKey('expanded_${comment.id}'))
                    Container(
                      width: 2,
                      height: comment.hasImage
                          ? screenHeight * 0.4
                          : screenHeight * 0.1,
                      color: Colors.grey[800],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                ],
              ),
            ),
            // Comment content
            Expanded(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment header with username, flair, time
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: GoogleFonts.inter(
                            color: comment.isSubmitter
                                ? Colors.blue
                                : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen
                                ? screenWidth * 0.035
                                : screenWidth * 0.04,
                          ),
                        ),
                        if (comment.isSubmitter)
                          Container(
                            margin: EdgeInsets.only(left: screenWidth * 0.01),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.01,
                                vertical: screenHeight * 0.003),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.01),
                            ),
                            child: Text(
                              'OP',
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontSize: isSmallScreen
                                    ? screenWidth * 0.025
                                    : screenWidth * 0.03,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          ' • ${comment.timeAgo}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen
                                ? screenWidth * 0.03
                                : screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Comment body
                    Text(
                      comment.body,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isSmallScreen
                            ? screenWidth * 0.035
                            : screenWidth * 0.04,
                      ),
                    ),

                    // Comment image if available
                    if (comment.hasImage && comment.imagePath != null)
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          child: comment.isVideo
                              ? GestureDetector(
                                  onTap: () {
                                    // Play video logic here
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Video playback would start here'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: screenHeight * 0.2,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(
                                          comment.imagePath!,
                                          fit: BoxFit.cover,
                                          height: screenHeight * 0.2,
                                          width: double.infinity,
                                        ),
                                        Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white.withOpacity(0.8),
                                          size: screenWidth * 0.12,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    // Show image in full screen
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding:
                                            EdgeInsets.all(screenWidth * 0.02),
                                        child: Stack(
                                          children: [
                                            InteractiveViewer(
                                              panEnabled: true,
                                              minScale: 0.5,
                                              maxScale: 4,
                                              child: Image.network(
                                                comment.imagePath!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(Icons.close,
                                                    color: Colors.white,
                                                    size: screenWidth * 0.06),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    comment.imagePath!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[900]!,
                                        highlightColor: Colors.grey[800]!,
                                        child: Container(
                                          height: screenHeight * 0.2,
                                          width: double.infinity,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: screenHeight * 0.2,
                                      width: double.infinity,
                                      color: Colors.grey[900],
                                      child: Center(
                                        child: Icon(Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: screenWidth * 0.08),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.015),

                    // Comment actions
                    Row(
                      children: [
                        // Upvote with improved visual feedback
                        GestureDetector(
                          onTap: () =>
                              _handleVote(comment.id, userVote == 1 ? 0 : 1),
                          child: Icon(
                            Icons.arrow_upward,
                            color: userVote == 1 ? Colors.orange : Colors.grey,
                            size: isSmallScreen
                                ? screenWidth * 0.045
                                : screenWidth * 0.05,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${comment.ups - comment.downs}',
                          style: GoogleFonts.inter(
                            color: userVote != 0
                                ? (userVote == 1 ? Colors.orange : Colors.blue)
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen
                                ? screenWidth * 0.03
                                : screenWidth * 0.035,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        GestureDetector(
                          onTap: () =>
                              _handleVote(comment.id, userVote == -1 ? 0 : -1),
                          child: Icon(
                            Icons.arrow_downward,
                            color: userVote == -1 ? Colors.blue : Colors.grey,
                            size: isSmallScreen
                                ? screenWidth * 0.045
                                : screenWidth * 0.05,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),

                        // Reply
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCommentBox = true;
                              _replyingToAuthor = comment.author;
                            });

                            // Focus the comment field
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _commentFocusNode.requestFocus();
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.reply,
                                  color: Colors.grey,
                                  size: isSmallScreen
                                      ? screenWidth * 0.04
                                      : screenWidth * 0.045),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                'Reply',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: isSmallScreen
                                      ? screenWidth * 0.03
                                      : screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Show/hide replies toggle if comment has replies
                        if (comment.replies.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.03),
                            child: GestureDetector(
                              onTap: () {
                                // Toggle visibility of this comment's replies
                                setState(() {
                                  // We'll use a set to track expanded/collapsed comments
                                  if (_userVotes
                                      .containsKey('expanded_${comment.id}')) {
                                    _userVotes.remove('expanded_${comment.id}');
                                  } else {
                                    _userVotes['expanded_${comment.id}'] = 1;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    _userVotes.containsKey(
                                            'expanded_${comment.id}')
                                        ? Icons.expand_more
                                        : Icons.expand_less,
                                    color: Colors.grey,
                                    size: isSmallScreen
                                        ? screenWidth * 0.04
                                        : screenWidth * 0.045,
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    _userVotes.containsKey(
                                            'expanded_${comment.id}')
                                        ? 'Hide replies'
                                        : 'Show replies (${comment.replies.length})',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey,
                                      fontSize: isSmallScreen
                                          ? screenWidth * 0.03
                                          : screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const Spacer(),

                        // More options
                        GestureDetector(
                          onTap: () {
                            _showCommentOptions(context, comment);
                          },
                          child: Icon(Icons.more_horiz,
                              color: Colors.grey,
                              size: isSmallScreen
                                  ? screenWidth * 0.045
                                  : screenWidth * 0.05),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.005),
                    Divider(color: Colors.grey[900], height: 1),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Display replies if any and if not collapsed
        if (comment.replies.isNotEmpty &&
            _userVotes.containsKey('expanded_${comment.id}'))
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.06),
            child: Column(
              children: comment.replies.map((reply) {
                return _buildReplyItem(context, reply, comment.id);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyItem(
      BuildContext context, RedditComment reply, String parentId) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    // Get user's vote for this reply
    final userVote = _userVotes[reply.id] ?? 0;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        right: screenWidth * 0.03,
        top: screenWidth * 0.02,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar column
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.01,
              top: screenWidth * 0.01,
              right: screenWidth * 0.005,
            ),
            child: CircleAvatar(
              radius: isSmallScreen ? screenWidth * 0.025 : screenWidth * 0.03,
              backgroundColor: Colors.grey[800],
              backgroundImage: NetworkImage(
                reply.author == 'YourUsername'
                    ? 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_0.png'
                    : 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png',
              ),
            ),
          ),

          // Left border to indicate nested reply
          Container(
            width: screenWidth * 0.005,
            height: reply.hasImage ? screenWidth * 0.5 : screenWidth * 0.2,
            color: Colors.grey[800],
            margin: EdgeInsets.only(right: screenWidth * 0.01),
          ),

          // Reply content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reply header
                Row(
                  children: [
                    Text(
                      reply.author,
                      style: GoogleFonts.inter(
                        color: reply.isSubmitter ? Colors.blue : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen
                            ? screenWidth * 0.03
                            : screenWidth * 0.035,
                      ),
                    ),
                    if (reply.isSubmitter)
                      Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.01),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01,
                            vertical: screenHeight * 0.002),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.008),
                        ),
                        child: Text(
                          'OP',
                          style: GoogleFonts.inter(
                            color: Colors.blue,
                            fontSize: isSmallScreen
                                ? screenWidth * 0.02
                                : screenWidth * 0.025,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      ' • ${reply.timeAgo}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: isSmallScreen
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.008),

                // Reply body
                Text(
                  reply.body,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallScreen
                        ? screenWidth * 0.0325
                        : screenWidth * 0.0375,
                  ),
                ),

                // Reply image if available
                if (reply.hasImage && reply.imagePath != null)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(screenWidth * 0.02),
                              child: Stack(
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Image.network(
                                      reply.imagePath!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.close,
                                          color: Colors.white,
                                          size: screenWidth * 0.06),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          reply.imagePath!,
                          fit: BoxFit.cover,
                          height: screenHeight * 0.15,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: screenHeight * 0.01),

                // Reply actions
                Row(
                  children: [
                    // Upvote with visual feedback
                    GestureDetector(
                      onTap: () => _handleVote(reply.id, userVote == 1 ? 0 : 1),
                      child: Icon(Icons.arrow_upward,
                          color: userVote == 1 ? Colors.orange : Colors.grey,
                          size: isSmallScreen
                              ? screenWidth * 0.04
                              : screenWidth * 0.045),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '${reply.ups - reply.downs}',
                      style: GoogleFonts.inter(
                        color: userVote != 0
                            ? (userVote == 1 ? Colors.orange : Colors.blue)
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen
                            ? screenWidth * 0.0275
                            : screenWidth * 0.0325,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    GestureDetector(
                      onTap: () =>
                          _handleVote(reply.id, userVote == -1 ? 0 : -1),
                      child: Icon(Icons.arrow_downward,
                          color: userVote == -1 ? Colors.blue : Colors.grey,
                          size: isSmallScreen
                              ? screenWidth * 0.04
                              : screenWidth * 0.045),
                    ),
                    SizedBox(width: screenWidth * 0.025),

                    // Reply to reply
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showCommentBox = true;
                          _replyingToAuthor = reply.author;
                        });

                        Future.delayed(const Duration(milliseconds: 100), () {
                          _commentFocusNode.requestFocus();
                        });
                      },
                      child: Row(
                        children: [
                          Icon(Icons.reply,
                              color: Colors.grey,
                              size: isSmallScreen
                                  ? screenWidth * 0.035
                                  : screenWidth * 0.04),
                          SizedBox(width: screenWidth * 0.0075),
                          Text(
                            'Reply',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: isSmallScreen
                                  ? screenWidth * 0.0275
                                  : screenWidth * 0.0325,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // More options for reply
                    GestureDetector(
                      onTap: () {
                        _showCommentOptions(context, reply);
                      },
                      child: Icon(Icons.more_horiz,
                          color: Colors.grey,
                          size: isSmallScreen
                              ? screenWidth * 0.04
                              : screenWidth * 0.045),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Divider(color: Colors.grey[900], height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentOptions(BuildContext context, RedditComment comment) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final postId = widget.postId ?? (widget.postDetails?.id);
    final isSaved = _profileController.isCommentSaved(comment.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCommentOption(
              icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
              label: isSaved ? 'Unsave' : 'Save',
              onTap: () {
                Navigator.pop(context);
                if (postId != null) {
                  _profileController.toggleSaveComment(
                      comment.id, postId, comment.body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(isSaved ? 'Comment unsaved' : 'Comment saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              isSmallScreen: isSmallScreen,
            ),
            _buildCommentOption(
              icon: Icons.ios_share,
              label: 'Share',
              onTap: () {
                Navigator.pop(context);
                _shareComment(comment);
              },
              isSmallScreen: isSmallScreen,
            ),
            _buildCommentOption(
              icon: Icons.report_outlined,
              label: 'Report',
              onTap: () => Navigator.pop(context),
              isSmallScreen: isSmallScreen,
            ),
            _buildCommentOption(
              icon: Icons.block,
              label: 'Block Account',
              onTap: () => Navigator.pop(context),
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: isSmallScreen ? 22 : 24),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildCommentBar(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showCommentBox = true;
              _replyingToAuthor = null;
            });
            _commentFocusNode.requestFocus();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            minimumSize: Size(screenWidth * 0.3, screenHeight * 0.05),
          ),
          child: Text(
            'Reply',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize:
                  isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.04,
            ),
          ),
        ),
        if (_showCommentBox)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
            ),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_replyingToAuthor != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                    child: Row(
                      children: [
                        Text(
                          'Replying to ${_replyingToAuthor}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen
                                ? screenWidth * 0.03
                                : screenWidth * 0.035,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _replyingToAuthor = null;
                            });
                          },
                          child: Icon(Icons.close,
                              color: Colors.grey[400],
                              size: screenWidth * 0.04),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  autofocus: true,
                  maxLines: 5,
                  minLines: 3,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallScreen
                        ? screenWidth * 0.035
                        : screenWidth * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen
                          ? screenWidth * 0.035
                          : screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide(color: Colors.grey[500]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                    contentPadding: EdgeInsets.all(screenWidth * 0.03),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Selected image preview
                if (_selectedImagePath != null)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          child: _isVideoComment
                              ? Container(
                                  height: screenHeight * 0.15,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.02),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      _selectedImageFile != null
                                          ? Image.file(
                                              _selectedImageFile!,
                                              fit: BoxFit.cover,
                                              height: screenHeight * 0.15,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              color: Colors.grey[800],
                                              height: screenHeight * 0.15,
                                              width: double.infinity,
                                            ),
                                      Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white.withOpacity(0.8),
                                        size: screenWidth * 0.12,
                                      ),
                                    ],
                                  ),
                                )
                              : _selectedImageFile != null
                                  ? Image.file(
                                      _selectedImageFile!,
                                      fit: BoxFit.cover,
                                      height: screenHeight * 0.15,
                                    )
                                  : Container(
                                      color: Colors.grey[800],
                                      height: screenHeight * 0.15,
                                      width: double.infinity,
                                    ),
                        ),
                        Positioned(
                          top: screenWidth * 0.0125,
                          right: screenWidth * 0.0125,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImagePath = null;
                                _selectedImageFile = null;
                                _isVideoComment = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate_outlined,
                              color: Colors.grey[400],
                              size: screenWidth * 0.05),
                          onPressed: () {
                            _selectImage(false);
                          },
                          iconSize: screenWidth * 0.05,
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.video_library_outlined,
                              color: Colors.grey[400],
                              size: screenWidth * 0.05),
                          onPressed: () {
                            _selectImage(true);
                          },
                          iconSize: screenWidth * 0.05,
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.link,
                              color: Colors.grey[400],
                              size: screenWidth * 0.05),
                          onPressed: () {},
                          iconSize: screenWidth * 0.05,
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showCommentBox = false;
                              _replyingToAuthor = null;
                              _commentController.clear();
                              _selectedImagePath = null;
                              _selectedImageFile = null;
                              _isVideoComment = false;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[400],
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.01),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen
                                  ? screenWidth * 0.035
                                  : screenWidth * 0.04,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            _addComment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          child: Text(
                            'Comment',
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen
                                  ? screenWidth * 0.035
                                  : screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (!_showCommentBox)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.grey[900]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                      radius: isSmallScreen
                          ? screenWidth * 0.0375
                          : screenWidth * 0.045,
                      backgroundColor: Colors.grey[800],
                      backgroundImage:
                          _profileController.photoUrl.value.isNotEmpty
                              ? NetworkImage(_profileController.photoUrl.value)
                              : const NetworkImage(
                                  'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_0.png',
                                ),
                    )),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCommentBox = true;
                        _replyingToAuthor = null;
                      });

                      // Focus the comment field
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _commentFocusNode.requestFocus();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.0125),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        'Join the conversation',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: isSmallScreen
                              ? screenWidth * 0.035
                              : screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size:
                        isSmallScreen ? screenWidth * 0.05 : screenWidth * 0.06,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey[400],
                    size:
                        isSmallScreen ? screenWidth * 0.05 : screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty && _selectedImagePath == null)
      return;

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Get post ID
      final postId = widget.postId ?? (widget.postDetails?.id);

      if (postId == null) {
        throw Exception('Post ID is required');
      }

      // Call the service to post the comment
      final parentId = _replyingToAuthor != null ? _getParentCommentId() : null;

      final newComment = await _redditPostService.postComment(
        postId,
        _commentController.text.trim(),
        parentId: parentId,
        imageUrl: _selectedImagePath,
        isVideo: _isVideoComment,
      );

      // Create a new comment with the user's actual username from ProfileController
      final userComment = RedditComment(
        id: newComment.id,
        author: _profileController.username.value.isNotEmpty
            ? _profileController.username.value
            : 'Anonymous',
        body: newComment.body,
        ups: newComment.ups,
        downs: newComment.downs,
        createdUtc: newComment.createdUtc,
        replies: newComment.replies,
        isSubmitter: true,
        parentId: newComment.parentId,
        depth: newComment.depth,
        distinguished: newComment.distinguished,
        authorFlairText: newComment.authorFlairText,
        hasImage: newComment.hasImage,
        imagePath: newComment.imagePath,
        isVideo: newComment.isVideo,
      );

      // Save comment to user's profile in Firebase
      await _profileController.saveUserComment(
        postId,
        widget.postTitle ?? 'Post',
        _commentController.text.trim(),
        widget.subreddit ?? 'unknown',
      );

      setState(() {
        // If replying to a comment, add it as a reply to that comment
        if (_replyingToAuthor != null) {
          _addReplyToComment(userComment);
        } else {
          // Otherwise add it as a top-level comment
          _comments.insert(0, userComment);
        }

        _commentController.clear();
        _selectedImagePath = null;
        _selectedImageFile = null;
        _isVideoComment = false;
        _showCommentBox = false;
        _replyingToAuthor = null;
        _isLoading = false;
      });

      // Show a success snackbar
      Get.snackbar(
        'Comment Posted',
        'Your comment has been added',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to post comment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  // Find the parent comment ID based on the author we're replying to
  String _getParentCommentId() {
    for (var comment in _comments) {
      if (comment.author == _replyingToAuthor) {
        return comment.id;
      }
    }
    return '';
  }

  // Add a reply to the appropriate parent comment
  void _addReplyToComment(RedditComment reply) {
    List<RedditComment> updatedComments = [];

    for (var comment in _comments) {
      if (comment.author == _replyingToAuthor) {
        // Create a new comment with the reply added
        List<RedditComment> updatedReplies = List.from(comment.replies)
          ..add(reply);

        updatedComments.add(RedditComment(
          id: comment.id,
          author: comment.author,
          body: comment.body,
          ups: comment.ups,
          downs: comment.downs,
          createdUtc: comment.createdUtc,
          replies: updatedReplies,
          isSubmitter: comment.isSubmitter,
          parentId: comment.parentId,
          depth: comment.depth,
          distinguished: comment.distinguished,
          authorFlairText: comment.authorFlairText,
          hasImage: comment.hasImage,
          imagePath: comment.imagePath,
          isVideo: comment.isVideo,
        ));
      } else {
        updatedComments.add(comment);
      }
    }

    _comments = updatedComments;
  }

  // Enhanced sort functionality
  void _sortComments() {
    setState(() {
      _comments.sort((a, b) => (b.ups - b.downs).compareTo(a.ups - a.downs));
    });
  }

  // Show sort options modal
  void _showSortOptionsModal(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(screenWidth * 0.04)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01),
              child: Text(
                'Sort Comments By',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(color: Colors.grey[800]),
            ListTile(
              leading: Icon(
                Icons.trending_up,
                color: _sortByBest ? Colors.blue : Colors.grey[400],
                size: screenWidth * 0.06,
              ),
              title: Text(
                'Best',
                style: GoogleFonts.inter(
                  color: _sortByBest ? Colors.blue : Colors.white,
                  fontSize: screenWidth * 0.035,
                  fontWeight: _sortByBest ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  _sortByBest = true;
                });
                _sortComments();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.arrow_upward,
                color: !_sortByBest ? Colors.blue : Colors.grey[400],
                size: screenWidth * 0.06,
              ),
              title: Text(
                'Top',
                style: GoogleFonts.inter(
                  color: !_sortByBest ? Colors.blue : Colors.white,
                  fontSize: screenWidth * 0.035,
                  fontWeight:
                      !_sortByBest ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  _sortByBest = false;
                });
                _sortComments();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Get appropriate icon for each sort option
  IconData _getSortIcon(int sortType) {
    switch (sortType) {
      case 0:
        return Icons.trending_up; // Best
      case 1:
        return Icons.arrow_upward; // Top
      default:
        return Icons.sort;
    }
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog(bool isVideo) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isVideo ? 'Select Video Source' : 'Select Image Source',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromSource(isVideo, ImageSource.gallery);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromSource(isVideo, ImageSource.camera);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: screenWidth * 0.07,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  // Pick image from selected source
  Future<void> _pickFromSource(bool isVideo, ImageSource source) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _imagePicker.pickVideo(source: source)
          : await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImagePath = pickedFile.path;
          _isVideoComment = isVideo;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to pick ${isVideo ? 'video' : 'image'}. Please try again.'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to select an image for comment (now shows source dialog)
  Future<void> _selectImage(bool isVideo) async {
    _showImageSourceDialog(isVideo);
  }

  // Simplified vote handling method
  void _handleVote(String commentId, int newVote) {
    setState(() {
      final currentVote = _userVotes[commentId] ?? 0;

      // Find the comment in the list (can be top-level or reply)
      for (int i = 0; i < _comments.length; i++) {
        if (_comments[i].id == commentId) {
          // It's a top-level comment
          var comment = _comments[i];
          int updatedUps = comment.ups;
          int updatedDowns = comment.downs;

          // Remove previous vote if any
          if (currentVote == 1) updatedUps--;
          if (currentVote == -1) updatedDowns--;

          // Add new vote if not canceling
          if (newVote == 1) updatedUps++;
          if (newVote == -1) updatedDowns++;

          // Update the comment
          _comments[i] = RedditComment(
            id: comment.id,
            author: comment.author,
            body: comment.body,
            ups: updatedUps,
            downs: updatedDowns,
            createdUtc: comment.createdUtc,
            replies: comment.replies,
            isSubmitter: comment.isSubmitter,
            parentId: comment.parentId,
            depth: comment.depth,
            distinguished: comment.distinguished,
            authorFlairText: comment.authorFlairText,
            hasImage: comment.hasImage,
            imagePath: comment.imagePath,
            isVideo: comment.isVideo,
          );

          _userVotes[commentId] = newVote;

          // Store vote in Firebase for the user
          if (comment.id.isNotEmpty) {
            _saveCommentVote(comment.id, newVote);
          }

          return;
        }

        // Check if it's a reply to this comment
        var comment = _comments[i];
        for (int j = 0; j < comment.replies.length; j++) {
          if (comment.replies[j].id == commentId) {
            var reply = comment.replies[j];
            int updatedUps = reply.ups;
            int updatedDowns = reply.downs;

            // Remove previous vote if any
            if (currentVote == 1) updatedUps--;
            if (currentVote == -1) updatedDowns--;

            // Add new vote if not canceling
            if (newVote == 1) updatedUps++;
            if (newVote == -1) updatedDowns++;

            // Create updated reply
            var updatedReply = RedditComment(
              id: reply.id,
              author: reply.author,
              body: reply.body,
              ups: updatedUps,
              downs: updatedDowns,
              createdUtc: reply.createdUtc,
              replies: reply.replies,
              isSubmitter: reply.isSubmitter,
              parentId: reply.parentId,
              depth: reply.depth,
              distinguished: reply.distinguished,
              authorFlairText: reply.authorFlairText,
              hasImage: reply.hasImage,
              imagePath: reply.imagePath,
              isVideo: reply.isVideo,
            );

            // Create new replies list
            List<RedditComment> updatedReplies = List.from(comment.replies);
            updatedReplies[j] = updatedReply;

            // Update the parent comment with new replies
            _comments[i] = RedditComment(
              id: comment.id,
              author: comment.author,
              body: comment.body,
              ups: comment.ups,
              downs: comment.downs,
              createdUtc: comment.createdUtc,
              replies: updatedReplies,
              isSubmitter: comment.isSubmitter,
              parentId: comment.parentId,
              depth: comment.depth,
              distinguished: comment.distinguished,
              authorFlairText: comment.authorFlairText,
              hasImage: comment.hasImage,
              imagePath: comment.imagePath,
              isVideo: comment.isVideo,
            );

            _userVotes[commentId] = newVote;

            // Store vote in Firebase for the user
            if (reply.id.isNotEmpty) {
              _saveCommentVote(reply.id, newVote);
            }

            return;
          }
        }
      }
    });
  }

  // Save comment vote to Firebase
  Future<void> _saveCommentVote(String commentId, int voteValue) async {
    try {
      // Add this method to ProfileController if you want to track comment votes persistently
      // For now, we'll only store the local state in _userVotes

      // Example implementation would be:
      // await _profileController.saveCommentVote(commentId, voteValue);
    } catch (e) {
      print('Error saving comment vote: $e');
    }
  }

  // Method to share a comment
  Future<void> _shareComment(RedditComment comment) async {
    try {
      final postTitle = widget.postTitle ?? 'Reddit Post';
      String shareText =
          'Comment by u/${comment.author} on "$postTitle":\n\n${comment.body}';

      if (widget.postUrl != null) {
        shareText += '\n\nOriginal post: ${widget.postUrl}';
      }

      await Share.share(shareText);
    } catch (e) {
      print('Error sharing comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to share comment. Please try again.'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
