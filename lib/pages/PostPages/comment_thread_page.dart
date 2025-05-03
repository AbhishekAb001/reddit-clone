import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reddit/model/reddit_comment.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/services/reddit_post_service.dart';

class CommentThreadPage extends StatefulWidget {
  final String postId;
  final String? subreddit;
  final String? postTitle;
  final String? postUrl;
  final String? postThumbnail;

  const CommentThreadPage({
    Key? key,
    required this.postId,
    this.subreddit,
    this.postTitle,
    this.postUrl,
    this.postThumbnail,
  }) : super(key: key);

  @override
  State<CommentThreadPage> createState() => _CommentThreadPageState();
}

class _CommentThreadPageState extends State<CommentThreadPage> {
  final RedditPostService _redditService = RedditPostService();
  List<RedditComment> _comments = [];
  RedditPost? _postDetails;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedSortOption = 0;
  final List<String> _sortOptions = [
    'Best',
    'Top',
    'New',
    'Controversial',
    'Old',
    'Q&A'
  ];

  // Controller for the comment text field
  final TextEditingController _commentController = TextEditingController();

  // Focus node to manage keyboard focus
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final comments = await _redditService.fetchComments(
        widget.postId,
        subreddit: widget.subreddit,
      );

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      log('Error fetching comments: $e');
      setState(() {
        _errorMessage = 'Failed to load comments. Please try again.';
        _isLoading = false;
      });
    }
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
              : _errorMessage != null
                  ? _buildErrorMessage(context)
                  : _buildCommentsList(context),
        ),
        _buildBottomCommentBar(context),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      color: Colors.grey[900],
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.01),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.subreddit != null ? 'r/${widget.subreddit}' : 'Comments',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 16 : 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.sort,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
            onPressed: () => _showSortOptions(context),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Text(
                  'Sort comments by',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...List.generate(
                _sortOptions.length,
                (index) => ListTile(
                  leading: Radio<int>(
                    value: index,
                    groupValue: _selectedSortOption,
                    activeColor: Colors.orangeAccent,
                    onChanged: (value) {
                      setState(() => _selectedSortOption = value!);
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    _sortOptions[index],
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedSortOption = index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentSheet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag indicator
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Post info at the top
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.orangeAccent,
                            child: Icon(
                              Icons.reddit,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'r/${widget.subreddit ?? 'reddit'}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Commenting as',
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'YourUsername',
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Post title
                      Text(
                        widget.postTitle ??
                            '15 years on, BMC to use its engineer\'s UTWT method...',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Divider(height: 0, thickness: 1, color: Colors.grey[900]),

                // Comment input area
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        autofocus: true,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 5,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add a comment',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Formatting options
                      Row(
                        children: [
                          _buildFormatButton(
                              context, Icons.format_bold, 'Bold'),
                          _buildFormatButton(
                              context, Icons.format_italic, 'Italic'),
                          _buildFormatButton(context, Icons.link, 'Link'),
                          _buildFormatButton(
                              context, Icons.format_strikethrough, 'Strike'),
                          _buildFormatButton(context, Icons.code, 'Code'),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              // TODO: Submit comment
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Post',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Clear the text when the sheet is closed
      _commentController.clear();
    });
  }

  Widget _buildFormatButton(
      BuildContext context, IconData icon, String tooltip) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: Implement text formatting
        },
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icon,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: isSmallScreen ? 48 : 56,
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          ElevatedButton(
            onPressed: _fetchComments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.015,
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Post content at the top
        SliverToBoxAdapter(
          child: _buildPostHeader(context),
        ),

        // Comments list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (_comments.isEmpty) {
                return _buildEmptyComments(context);
              }
              return _buildCommentItem(context, _comments[index], 0);
            },
            childCount: _comments.isEmpty ? 1 : _comments.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    return Container(
      color: Colors.grey[900],
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subreddit and post info
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.orangeAccent,
                child: Icon(
                  Icons.reddit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'r/${widget.subreddit ?? 'reddit'}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '• 9h • indianexpress.com',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Post title
          Text(
            widget.postTitle ??
                '15 years on, BMC to use its engineer\'s UTWT method to concretise up to 200km of city road; set to save around Rs 3,000 crore',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          SizedBox(height: 12),

          // Post image if available
          if (widget.postThumbnail != null && widget.postThumbnail!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.postThumbnail!,
                placeholder: (context, url) => Container(
                  height: screenHeight * 0.2,
                  color: Colors.grey[800],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: screenHeight * 0.2,
                  color: Colors.grey[800],
                  child: Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 12),

          // Category tag
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'General',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          SizedBox(height: 12),

          // Post stats (upvotes, comments)
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 20, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                '158',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
              Spacer(),
              Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                '14',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          Divider(color: Colors.grey[800], thickness: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyComments(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              color: Colors.grey,
              size: isSmallScreen ? 48 : 56,
            ),
            SizedBox(height: 16),
            Text(
              'No comments yet',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts!',
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(
      BuildContext context, RedditComment comment, int depth) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    // Create avatar with first letter of username
    final String avatarText =
        comment.author.isNotEmpty ? comment.author[0].toUpperCase() : 'R';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.black,
          padding: EdgeInsets.only(
            left: 16 + (depth * 8.0),
            right: 16,
            top: 8,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment header with avatar, username and time
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        avatarText,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  // Username
                  Text(
                    comment.author,
                    style: GoogleFonts.inter(
                      color: comment.isSubmitter ? Colors.blue : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),

                  SizedBox(width: 4),

                  // Badge if commenter has one (e.g. "Top 1% Commenter")
                  if (comment.authorFlairText != null &&
                      comment.authorFlairText!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        comment.authorFlairText!,
                        style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  SizedBox(width: 4),

                  // Timestamp
                  Text(
                    comment.timeAgo,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 12 : 13,
                    ),
                  ),

                  Spacer(),

                  // More options
                  Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),

              // Comment content
              Padding(
                padding: EdgeInsets.only(left: 40, top: 4, bottom: 4),
                child: Text(
                  comment.body,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),

              // Comment actions
              Padding(
                padding: EdgeInsets.only(left: 40),
                child: Row(
                  children: [
                    // Upvote
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      comment.ups.toString(),
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    // Downvote
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: Colors.grey,
                    ),

                    // Reply button
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showCommentSheet(context),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 14,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Reply',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
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
        ),

        Divider(color: Colors.grey[900], height: 0, thickness: 1),

        // Recursive display of replies
        if (comment.replies.isNotEmpty)
          ...comment.replies
              .map((reply) => _buildCommentItem(context, reply, depth + 1))
              .toList(),
      ],
    );
  }

  Widget _buildBottomCommentBar(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    return GestureDetector(
      onTap: () => _showCommentSheet(context),
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Text(
                  'Join the conversation',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.image_outlined,
              color: Colors.blue,
              size: 24,
            ),
            SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
