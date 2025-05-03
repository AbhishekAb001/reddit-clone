import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:reddit/model/reddit_comment.dart';

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
  bool _isLoading = false;
  List<RedditComment> _comments = [];
  bool _showCommentBox = false;
  String? _replyingToAuthor;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // Mock comments for demonstration
  void _loadMockComments() {
    _comments = [
      RedditComment(
        id: '1',
        author: 'Select-Bread2173',
        body: '2025 and we still figuring out roads',
        ups: 118,
        downs: 0,
        createdUtc: DateTime.now().subtract(Duration(hours: 8)),
        replies: [],
        isSubmitter: false,
        parentId: '',
        depth: 0,
        distinguished: '',
      ),
      RedditComment(
        id: '2',
        author: 'hahahadev',
        body:
            'I no longer consider our road makers legitimate, we should outsource to other countries who have better roads than us despite being poorer or smaller than us.',
        ups: 51,
        downs: 0,
        createdUtc: DateTime.now().subtract(Duration(hours: 7)),
        replies: [],
        isSubmitter: false,
        parentId: '',
        depth: 0,
        distinguished: '',
      ),
      RedditComment(
        id: '3',
        author: 'ImprefectKnight',
        body:
            'Wait until they set up for commencing in English instead of Hindi, then you\'ll see some real progress!',
        ups: 24,
        downs: 0,
        createdUtc: DateTime.now().subtract(Duration(hours: 1)),
        replies: [],
        isSubmitter: false,
        parentId: '',
        depth: 0,
        distinguished: '',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadMockComments();
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
              : _buildPostWithComments(context),
        ),
        _buildCommentBar(context),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      color: Colors.black,
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
            onPressed: () {},
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
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
    final isSmallScreen = screenWidth < 600;
    final textScaleFactor = isSmallScreen ? 1.0 : 1.2;

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
                radius: isSmallScreen ? 12 : 15,
                backgroundColor: Colors.grey[800],
                child: Text(
                  'r',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'r/${widget.subreddit ?? 'mumbai'}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '• u/GL4389 • 9h',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
              Text(
                ' • indianexpress.com',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Post title
          Text(
            widget.postTitle ??
                '15 years on, BMC to use its engineer\'s UTWT method to concretise up to 200km of city road; set to save around Rs 3,000 crore',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 16 : 20,
            ),
          ),
          SizedBox(height: 12),

          // Post image if available
          if (widget.postThumbnail != null &&
              widget.postThumbnail != 'self' &&
              widget.postThumbnail != '')
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: mediaQuery.size.height * 0.3,
                ),
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.postThumbnail!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    height: 200,
                    child: Center(
                      child:
                          Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/placeholder.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),

          SizedBox(height: 12),

          // Post stats
          Container(
            height: isSmallScreen ? 40 : 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Upvote/downvote
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward,
                          color: Colors.grey, size: isSmallScreen ? 20 : 24),
                      SizedBox(width: 8),
                      Text(
                        '158',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_downward,
                          color: Colors.grey, size: isSmallScreen ? 20 : 24),
                    ],
                  ),
                ),

                // Comments
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: Colors.grey, size: isSmallScreen ? 18 : 22),
                      SizedBox(width: 8),
                      Text(
                        '14',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Share button
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.ios_share,
                          color: Colors.grey, size: isSmallScreen ? 18 : 22),
                      SizedBox(width: 8),
                      Text(
                        '14',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // General tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'General',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 12 : 14,
              ),
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
    final isSmallScreen = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment header with username, flair, time
              Row(
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 12 : 15,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: NetworkImage(
                      comment.author == 'YourUsername'
                          ? 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_0.png'
                          : 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    comment.author,
                    style: GoogleFonts.inter(
                      color: comment.isSubmitter ? Colors.blue : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  if (comment.author == 'Select-Bread2173')
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Top 1% Commenter',
                        style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (comment.isSubmitter)
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'OP',
                        style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(width: 4),
                  Text(
                    ' • ${comment.timeAgo}',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Comment body
              Text(
                comment.body,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: 12),

              // Comment actions
              Row(
                children: [
                  // Upvote/downvote
                  GestureDetector(
                    onTap: () {
                      // Upvote logic
                      setState(() {
                        _comments = _comments.map((c) {
                          if (c.id == comment.id) {
                            return RedditComment(
                              id: c.id,
                              author: c.author,
                              body: c.body,
                              ups: c.ups + 1,
                              downs: c.downs,
                              createdUtc: c.createdUtc,
                              replies: c.replies,
                              isSubmitter: c.isSubmitter,
                              parentId: c.parentId,
                              depth: c.depth,
                              distinguished: c.distinguished,
                            );
                          }
                          return c;
                        }).toList();
                      });
                    },
                    child: Icon(Icons.arrow_upward,
                        color: Colors.grey, size: isSmallScreen ? 18 : 20),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${comment.ups}',
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  SizedBox(width: 2),
                  GestureDetector(
                    onTap: () {
                      // Downvote logic
                      setState(() {
                        _comments = _comments.map((c) {
                          if (c.id == comment.id) {
                            return RedditComment(
                              id: c.id,
                              author: c.author,
                              body: c.body,
                              ups: c.ups > 0 ? c.ups - 1 : 0,
                              downs: c.downs + 1,
                              createdUtc: c.createdUtc,
                              replies: c.replies,
                              isSubmitter: c.isSubmitter,
                              parentId: c.parentId,
                              depth: c.depth,
                              distinguished: c.distinguished,
                            );
                          }
                          return c;
                        }).toList();
                      });
                    },
                    child: Icon(Icons.arrow_downward,
                        color: Colors.grey, size: isSmallScreen ? 18 : 20),
                  ),
                  SizedBox(width: 12),

                  // Reply
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCommentBox = true;
                        _replyingToAuthor = comment.author;
                      });

                      // Focus the comment field
                      Future.delayed(Duration(milliseconds: 100), () {
                        _commentFocusNode.requestFocus();
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.reply,
                            color: Colors.grey, size: isSmallScreen ? 16 : 18),
                        SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // More options
                  GestureDetector(
                    onTap: () {
                      _showCommentOptions(context, comment);
                    },
                    child: Icon(Icons.more_horiz,
                        color: Colors.grey, size: isSmallScreen ? 18 : 20),
                  ),
                ],
              ),

              SizedBox(height: 4),
              Divider(color: Colors.grey[900], height: 1),
            ],
          ),
        ),

        // Display replies if any
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.06),
            child: Column(
              children: comment.replies.map((reply) {
                return _buildReplyItem(context, reply);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyItem(BuildContext context, RedditComment reply) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left border to indicate nested reply
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 2,
                height: screenWidth * 0.2,
                color: Colors.grey[800],
                margin: EdgeInsets.only(right: 10),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 10 : 12,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: NetworkImage(
                            reply.author == 'YourUsername'
                                ? 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_0.png'
                                : 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png',
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          reply.author,
                          style: GoogleFonts.inter(
                            color:
                                reply.isSubmitter ? Colors.blue : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        if (reply.isSubmitter)
                          Container(
                            margin: EdgeInsets.only(left: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'OP',
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontSize: isSmallScreen ? 8 : 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        SizedBox(width: 4),
                        Text(
                          ' • ${reply.timeAgo}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),

                    // Reply body
                    Text(
                      reply.body,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 13 : 15,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Reply actions
                    Row(
                      children: [
                        // Upvote/downvote
                        Icon(Icons.arrow_upward,
                            color: Colors.grey, size: isSmallScreen ? 16 : 18),
                        SizedBox(width: 2),
                        Text(
                          '${reply.ups}',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_downward,
                            color: Colors.grey, size: isSmallScreen ? 16 : 18),
                        SizedBox(width: 10),

                        // Reply
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCommentBox = true;
                              _replyingToAuthor = reply.author;
                            });

                            Future.delayed(Duration(milliseconds: 100), () {
                              _commentFocusNode.requestFocus();
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.reply,
                                  color: Colors.grey,
                                  size: isSmallScreen ? 14 : 16),
                              SizedBox(width: 3),
                              Text(
                                'Reply',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: isSmallScreen ? 11 : 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        // More options
                        Icon(Icons.more_horiz,
                            color: Colors.grey, size: isSmallScreen ? 16 : 18),
                      ],
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey[900], height: 1),
        ],
      ),
    );
  }

  void _showCommentOptions(BuildContext context, RedditComment comment) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCommentOption(
              icon: Icons.bookmark_border,
              label: 'Save',
              onTap: () => Navigator.pop(context),
              isSmallScreen: isSmallScreen,
            ),
            _buildCommentOption(
              icon: Icons.ios_share,
              label: 'Share',
              onTap: () => Navigator.pop(context),
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
    final isSmallScreen = screenWidth < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showCommentBox)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 12,
            ),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_replyingToAuthor != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'Replying to ${_replyingToAuthor}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _replyingToAuthor = null;
                            });
                          },
                          child: Icon(Icons.close,
                              color: Colors.grey[400], size: 16),
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
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[500]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate_outlined,
                              color: Colors.grey[400]),
                          onPressed: () {},
                          iconSize: isSmallScreen ? 20 : 24,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.link, color: Colors.grey[400]),
                          onPressed: () {},
                          iconSize: isSmallScreen ? 20 : 24,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
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
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[400],
                          ),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _addComment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: Text('Comment'),
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
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.grey[900]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 15 : 18,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: NetworkImage(
                    'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_0.png',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCommentBox = true;
                        _replyingToAuthor = null;
                      });

                      // Focus the comment field
                      Future.delayed(Duration(milliseconds: 100), () {
                        _commentFocusNode.requestFocus();
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Join the conversation',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey[400],
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      final newComment = RedditComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'YourUsername',
        body: _commentController.text.trim(),
        ups: 1,
        downs: 0,
        createdUtc: DateTime.now(),
        replies: [],
        isSubmitter: true,
        parentId: _replyingToAuthor != null ? _getParentCommentId() : '',
        depth: _replyingToAuthor != null ? 1 : 0,
        distinguished: '',
      );

      // If replying to a comment, add it as a reply to that comment
      if (_replyingToAuthor != null) {
        _addReplyToComment(newComment);
      } else {
        // Otherwise add it as a top-level comment
        _comments.insert(0, newComment);
      }

      _commentController.clear();
      _showCommentBox = false;
      _replyingToAuthor = null;
    });
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
        ));
      } else {
        updatedComments.add(comment);
      }
    }

    _comments = updatedComments;
  }
}
