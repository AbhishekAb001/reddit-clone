import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/model/reddit_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/CommunityPages/details_screen_new.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/pages/PostPages/comment_thread_page.dart';
import 'package:reddit/widgets/post_options_bottom_sheet.dart';
import 'package:reddit/widgets/post_menu_bottom_sheet.dart';

class PostCard extends StatelessWidget {
  final RedditPost post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

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
                    communityController.visitCommunity('r/${post.subreddit}');
                    Get.to(
                      () => DetailsScreen(
                        communityName: 'r/${post.subreddit}',
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: Text(
                    'r/${post.subreddit}',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                Text(
                  '• ${post.timeAgo} • ${post.viewCount}',
                  style: GoogleFonts.roboto(
                    color: Colors.grey,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
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
                    'Join',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                  onPressed: () {
                    showPostMenuBottomSheet(
                      context,
                      postUrl: post.url,
                      postId: post.id,
                      subreddit: post.subreddit,
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
              post.title,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Post image/content
          if (post.previewUrl != null || post.mediaUrl != null)
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
                    imageUrl: post.previewUrl ?? post.mediaUrl!,
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
                            Icon(Icons.arrow_upward,
                                color: const Color.fromARGB(255, 255, 252, 252),
                                size:
                                    MediaQuery.of(context).size.width * 0.055),
                            SizedBox(width: 4),
                            Text(
                              _formatNumber(post.ups),
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 255, 252, 252),
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                              ),
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
                        child: Icon(Icons.arrow_downward,
                            color: const Color.fromARGB(255, 255, 254, 254),
                            size: MediaQuery.of(context).size.width * 0.055),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.025),

                // Comment button
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => CommentThreadPage(
                          postId: post.id, subreddit: post.subreddit),
                      transition: Transition.rightToLeft,
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
                            _formatNumber(post.numComments),
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
                    showPostOptionsBottomSheet(context, postUrl: post.url);
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
                            post.shares != null
                                ? _formatNumber(post.shares!)
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
