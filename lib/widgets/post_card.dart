import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/CommunityPages/details_screen_new.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';
import 'package:reddit/widgets/post_options_bottom_sheet.dart';
import 'package:reddit/widgets/post_menu_bottom_sheet.dart';
import 'package:reddit/pages/Drawer/saved_drawer_page.dart';

class PostCard extends StatefulWidget {
  final RedditPost post;
  final VoidCallback? onTap;
  final VoidCallback? onUnliked;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onUnliked,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final ProfileController _profileController = Get.find<ProfileController>();
  late final ValueNotifier<int> _voteCount;
  // Track the UI vote status separately from the controller
  late int _localVoteStatus;

  @override
  void initState() {
    super.initState();
    // Initialize with the post's original vote count
    _voteCount = ValueNotifier<int>(widget.post.ups);
    // Get the initial vote status from the controller
    _localVoteStatus = _profileController.getPostVoteStatus(widget.post.id);

    // Adjust initial vote count to remove duplicated vote effect
    if (_localVoteStatus != 0) {
      _voteCount.value = widget.post.ups - _localVoteStatus;
    }
  }

  @override
  void dispose() {
    _voteCount.dispose();
    super.dispose();
  }

  void _handleUpvote() {
    // Get current vote status before changing it
    final currentVoteStatus = _localVoteStatus;

    // Update UI immediately based on current local vote status
    if (_localVoteStatus == 1) {
      // Canceling upvote
      _voteCount.value--;
      _localVoteStatus = 0;

      // If this post was previously liked and we have an onUnliked callback,
      // call it to notify the parent to update the UI
      if (widget.onUnliked != null) {
        // Use a post frame callback to ensure UI has updated first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onUnliked!();
        });
      }
    } else if (_localVoteStatus == -1) {
      // Changing from downvote to upvote
      _voteCount.value += 2;
      _localVoteStatus = 1;
    } else {
      // New upvote
      _voteCount.value++;
      _localVoteStatus = 1;
    }

    // Update controller afterward
    _profileController.upvotePost(widget.post.id);
  }

  void _handleDownvote() {
    // Update UI immediately based on current local vote status
    if (_localVoteStatus == -1) {
      // Canceling downvote
      _voteCount.value++;
      _localVoteStatus = 0;
    } else if (_localVoteStatus == 1) {
      // Changing from upvote to downvote
      _voteCount.value -= 2;
      _localVoteStatus = -1;
    } else {
      // New downvote
      _voteCount.value--;
      _localVoteStatus = -1;
    }

    // Update controller afterward
    _profileController.downvotePost(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subreddit header
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
            child: Row(
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.04,
                  backgroundColor: Colors.grey[800],
                  child: Icon(
                    Icons.reddit,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                GestureDetector(
                  onTap: () {
                    final communityController = Get.find<CommunityController>();
                    communityController
                        .visitCommunity('r/${widget.post.subreddit}');
                    Get.to(
                      () => DetailsScreen(
                        communityName: 'r/${widget.post.subreddit}',
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: Text(
                    'r/${widget.post.subreddit}',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                Text(
                  '• ${widget.post.timeAgo} • ${widget.post.viewCount}',
                  style: GoogleFonts.roboto(
                    color: Colors.grey,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final isJoined = _profileController
                      .isCommunityJoined(widget.post.subreddit);
                  return TextButton(
                    onPressed: () async {
                      await _profileController
                          .toggleCommunityJoinStatus(widget.post.subreddit);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          isJoined ? Colors.grey[800] : Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.05),
                      ),
                    ),
                    child: Text(
                      isJoined ? 'Joined' : 'Join',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                  onPressed: () {
                    showPostMenuBottomSheet(
                      context,
                      postId: widget.post.id,
                      postDetails: widget.post,
                      postTitle: widget.post.title,
                      postUrl: widget.post.url,
                      postThumbnail: widget.post.previewUrl,
                      subreddit: widget.post.subreddit,
                    );
                  },
                ),
              ],
            ),
          ),

          // Post title
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03,
            ),
            child: Text(
              widget.post.title,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Post image/content
          if (widget.post.previewUrl != null || widget.post.mediaUrl != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.post.previewUrl ?? widget.post.mediaUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      size: MediaQuery.of(context).size.width * 0.1,
                    ),
                  ),
                ),
              ),
            ),

          // Post actions
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
            child: Row(
              children: [
                // Like/Dislike container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color.fromARGB(146, 224, 224, 224),
                        width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.025,
                          vertical: MediaQuery.of(context).size.height * 0.008,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _handleUpvote,
                              child: Icon(
                                Icons.arrow_upward,
                                color: _localVoteStatus == 1
                                    ? Colors.orange
                                    : const Color.fromARGB(255, 255, 252, 252),
                                size: MediaQuery.of(context).size.width * 0.055,
                              ),
                            ),
                            SizedBox(width: 4),
                            ValueListenableBuilder<int>(
                              valueListenable: _voteCount,
                              builder: (context, value, child) {
                                return Text(
                                  _formatNumber(value),
                                  style: GoogleFonts.roboto(
                                    color: _localVoteStatus == 1
                                        ? Colors.orange
                                        : _localVoteStatus == -1
                                            ? Colors.blue
                                            : const Color.fromARGB(
                                                255, 255, 252, 252),
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.035,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.025,
                          vertical: MediaQuery.of(context).size.height * 0.008,
                        ),
                        child: GestureDetector(
                          onTap: _handleDownvote,
                          child: Icon(
                            Icons.arrow_downward,
                            color: _localVoteStatus == -1
                                ? Colors.blue
                                : const Color.fromARGB(255, 255, 254, 254),
                            size: MediaQuery.of(context).size.width * 0.055,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.025),

                // Comment button
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => PostCommentScreen(
                        postId: widget.post.id,
                        postDetails: widget.post,
                        postTitle: widget.post.title,
                        postUrl: widget.post.url,
                        postThumbnail: widget.post.previewUrl,
                        subreddit: widget.post.subreddit,
                      ),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color.fromARGB(146, 224, 224, 224)!,
                          width: 1.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.025,
                        vertical: MediaQuery.of(context).size.height * 0.008,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mode_comment_outlined,
                              color: const Color.fromARGB(255, 255, 252, 252),
                              size: MediaQuery.of(context).size.width * 0.055),
                          SizedBox(width: 4),
                          Text(
                            _formatNumber(widget.post.numComments),
                            style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Award button (example icon)

                const Spacer(),

                // Share button
                GestureDetector(
                  onTap: () {
                    showPostOptionsBottomSheet(context,
                        postUrl: widget.post.url);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color.fromARGB(146, 224, 224, 224)!,
                          width: 1.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.025,
                        vertical: MediaQuery.of(context).size.height * 0.008,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined,
                              color: const Color.fromARGB(255, 255, 253, 253),
                              size: MediaQuery.of(context).size.width * 0.055),
                          SizedBox(width: 4),
                          Text(
                            widget.post.shares != null
                                ? _formatNumber(widget.post.shares!)
                                : '2.8k',
                            style: GoogleFonts.roboto(
                              color: const Color.fromARGB(255, 255, 253, 253),
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
