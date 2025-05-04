import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/model/reddit_post.dart';

void showPostMenuBottomSheet(
  BuildContext context, {
  RedditPost? postDetails,
  String? postId,
  String? subreddit,
  String? postTitle,
  String? postUrl,
  String? postThumbnail,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final profileController = Get.find<ProfileController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + screenHeight * 0.02,
            top: screenHeight * 0.02,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Text(
                  'Post options',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.comment_outlined,
                label: 'View comments',
                onTap: () {
                  Navigator.pop(context);
                  if (postId != null) {
                    // Navigate to comments page
                    Get.to(
                      () => PostCommentScreen(
                        postId: postId,
                        postDetails: postDetails,
                        postTitle: postTitle,
                        postUrl: postUrl,
                        postThumbnail: postThumbnail,
                        subreddit: subreddit,
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.notifications_outlined,
                label: 'Follow post',
                onTap: () {
                  // Follow post implementation
                  Navigator.pop(context);
                  Get.snackbar(
                    'Coming Soon',
                    'Follow post functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              Obx(() {
                final isSaved = postId != null
                    ? profileController.isPostSaved(postId)
                    : false;
                return _buildMenuItem(
                  context: context,
                  icon:
                      isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                  label: isSaved ? 'Unsave' : 'Save',
                  onTap: () {
                    if (postId != null) {
                      profileController.toggleSavePost(postId);
                    }
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isSaved ? 'Post unsaved' : 'Post saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              }),
              _buildMenuItem(
                context: context,
                icon: Icons.person_off_outlined,
                label: 'Block account',
                onTap: () {
                  // Block account implementation
                  Navigator.pop(context);
                  Get.snackbar(
                    'Coming Soon',
                    'Block account functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: () {
                  // Report implementation
                  Navigator.pop(context);
                  Get.snackbar(
                    'Coming Soon',
                    'Report functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.visibility_off_outlined,
                label: 'Hide',
                onTap: () {
                  // Hide implementation
                  Navigator.pop(context);
                  Get.snackbar(
                    'Coming Soon',
                    'Hide post functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.content_copy_outlined,
                label: 'Copy text',
                onTap: () {
                  // Copy text implementation
                  Navigator.pop(context);

                  // Create a comprehensive text to copy, including title and content
                  String textToCopy = '';

                  if (postTitle != null && postTitle!.isNotEmpty) {
                    textToCopy += postTitle!;
                  }

                  if (postDetails?.selfText != null &&
                      postDetails!.selfText.isNotEmpty) {
                    if (textToCopy.isNotEmpty) {
                      textToCopy += '\n\n';
                    }
                    textToCopy += postDetails!.selfText;
                  }

                  // If we have a URL but no other content, include the URL
                  if (textToCopy.isEmpty &&
                      postUrl != null &&
                      postUrl!.isNotEmpty) {
                    textToCopy = postUrl!;
                  }

                  if (textToCopy.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    Get.snackbar(
                      'Success',
                      'Post content copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: Duration(seconds: 2),
                    );
                  } else {
                    // If no text content could be found at all
                    Get.snackbar(
                      'Note',
                      'This post has no text content to copy',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: Duration(seconds: 2),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.share_outlined,
                label: 'Crosspost to community',
                onTap: () {
                  // Crosspost implementation
                  Navigator.pop(context);
                  Get.snackbar(
                    'Coming Soon',
                    'Crosspost functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  // Open the enhanced share bottom sheet
                  showShareBottomSheet(
                    context,
                    postUrl: postUrl,
                    postTitle: postTitle,
                    postDetails: postDetails,
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showShareBottomSheet(
  BuildContext context, {
  String? postUrl,
  String? postTitle,
  RedditPost? postDetails,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Default post URL if none provided
  final url = postUrl ?? 'https://reddit.com/';

  // Automatically copy URL to clipboard for convenience
  Clipboard.setData(ClipboardData(text: url));

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
    ),
    builder: (context) {
      // Show snackbar after bottom sheet is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Copied',
          'Post URL copied to clipboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      });

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + screenHeight * 0.02,
            top: screenHeight * 0.02,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Text(
                  'Share options',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Social media direct sharing row
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialShareOption(
                      context: context,
                      icon: FontAwesomeIcons.facebook,
                      backgroundColor: Color(0xFF1877F2),
                      label: 'Facebook',
                      onTap: () {
                        Navigator.pop(context);
                        _shareToFacebook(context, url);
                      },
                    ),
                    _buildSocialShareOption(
                      context: context,
                      icon: FontAwesomeIcons.twitter,
                      backgroundColor: Color(0xFF1DA1F2),
                      label: 'Twitter',
                      onTap: () {
                        Navigator.pop(context);
                        _shareToTwitter(context, url);
                      },
                    ),
                    _buildSocialShareOption(
                      context: context,
                      icon: FontAwesomeIcons.instagram,
                      backgroundColor: Color(0xFFE1306C),
                      label: 'Instagram',
                      onTap: () {
                        Navigator.pop(context);
                        _shareToInstagram(context, url);
                      },
                    ),
                    _buildSocialShareOption(
                      context: context,
                      icon: FontAwesomeIcons.linkedinIn,
                      backgroundColor: Color(0xFF0A66C2),
                      label: 'LinkedIn',
                      onTap: () {
                        Navigator.pop(context);
                        _shareToLinkedIn(context, url);
                      },
                    ),
                  ],
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.link_outlined,
                label: 'Copy link',
                onTap: () {
                  // Copy link implementation with Clipboard
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  Get.snackbar(
                    'Success',
                    'Link copied to clipboard again',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.content_copy_outlined,
                label: 'Copy post content',
                onTap: () {
                  // Copy text implementation
                  Navigator.pop(context);

                  // Create a comprehensive text to copy, including title and content
                  String textToCopy = '';

                  if (postTitle != null && postTitle!.isNotEmpty) {
                    textToCopy += postTitle!;
                  }

                  if (postDetails?.selfText != null &&
                      postDetails!.selfText.isNotEmpty) {
                    if (textToCopy.isNotEmpty) {
                      textToCopy += '\n\n';
                    }
                    textToCopy += postDetails!.selfText;
                  }

                  // If we have a URL but no other content, include the URL
                  if (textToCopy.isEmpty) {
                    textToCopy = url;
                  } else {
                    // Add URL at the end if we have other content
                    textToCopy += '\n\n' + url;
                  }

                  Clipboard.setData(ClipboardData(text: textToCopy));
                  Get.snackbar(
                    'Success',
                    'Post content copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.message_outlined,
                label: 'Send in chat',
                onTap: () {
                  Navigator.pop(context);
                  // Would navigate to chat screen with pre-filled message
                  Get.snackbar(
                    'Coming Soon',
                    'Chat functionality will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                  // Navigation code would go here
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.ios_share_outlined,
                label: 'Share with note',
                onTap: () async {
                  // Close bottom sheet first
                  Navigator.pop(context);

                  // Then show share dialog with option to add note
                  try {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => _buildAddNoteDialog(context, url),
                    );

                    if (result != null && result is String) {
                      await Share.share(
                        '$result\n\n$url',
                        subject: 'Reddit post with my note',
                      );
                      Get.snackbar(
                        'Success',
                        'Post shared with your note',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.withOpacity(0.7),
                        colorText: Colors.white,
                        duration: Duration(seconds: 2),
                      );
                    }
                  } catch (e) {
                    log('Share with note error: ${e.toString()}');
                    Get.snackbar(
                      'Error',
                      'Failed to share with note',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: Duration(seconds: 2),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Dialog to add a note to the shared content
Widget _buildAddNoteDialog(BuildContext context, String url) {
  final TextEditingController noteController = TextEditingController();
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return AlertDialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenWidth * 0.03),
    ),
    title: Text(
      'Add a note',
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: screenWidth * 0.045,
        fontWeight: FontWeight.w600,
      ),
    ),
    content: Container(
      width: screenWidth * 0.8,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: TextField(
        controller: noteController,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: screenWidth * 0.035,
        ),
        decoration: InputDecoration(
          hintText: 'Write a note to add to your share...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: screenWidth * 0.035,
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
        maxLines: 3,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancel',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, noteController.text),
        child: Text(
          'Share',
          style: GoogleFonts.inter(
            color: Colors.blue,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Widget _buildMenuItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
          SizedBox(width: screenWidth * 0.05),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

// Social media sharing widget builder
Widget _buildSocialShareOption({
  required BuildContext context,
  required IconData icon,
  required Color backgroundColor,
  required String label,
  required VoidCallback onTap,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: screenWidth * 0.12,
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: screenWidth * 0.025,
          ),
        ),
      ],
    ),
  );
}

// Social media direct sharing functions
void _shareToFacebook(BuildContext context, String url) async {
  try {
    final encodedUrl = Uri.encodeComponent(url);
    final facebookUrl =
        'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl';
    final uri = Uri.parse(facebookUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      Get.snackbar(
        'Success',
        'Opening Facebook to share post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      // Fallback
      await Share.share('Check out this post: $url');
      Get.snackbar(
        'Success',
        'Shared using system share',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  } catch (e) {
    log('Facebook share error: ${e.toString()}');
    Get.snackbar(
      'Error',
      'Failed to share to Facebook',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}

void _shareToTwitter(BuildContext context, String url) async {
  try {
    final text = 'Check out this Reddit post';
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = Uri.encodeComponent(url);
    final twitterUrl =
        'https://twitter.com/intent/tweet?text=$encodedText&url=$encodedUrl';
    final uri = Uri.parse(twitterUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      Get.snackbar(
        'Success',
        'Opening Twitter to share post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      // Fallback
      await Share.share('$text: $url');
      Get.snackbar(
        'Success',
        'Shared using system share',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  } catch (e) {
    log('Twitter share error: ${e.toString()}');
    Get.snackbar(
      'Error',
      'Failed to share to Twitter',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}

void _shareToInstagram(BuildContext context, String url) async {
  // Instagram doesn't support direct URL sharing through intents
  // but we can try to launch the app and then suggest copying the URL
  try {
    final instagramUrl = 'instagram://';
    final uri = Uri.parse(instagramUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Show guidance for the user
      Get.snackbar(
        'Instagram Opened',
        'URL copied to clipboard for sharing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      // Copy URL to clipboard for easier sharing
      await Clipboard.setData(ClipboardData(text: url));
    } else {
      // Fallback
      await Share.share('Check out this post: $url');
      Get.snackbar(
        'Success',
        'Shared using system share',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  } catch (e) {
    log('Instagram share error: ${e.toString()}');
    Get.snackbar(
      'Error',
      'Failed to share to Instagram',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}

void _shareToLinkedIn(BuildContext context, String url) async {
  try {
    final encodedUrl = Uri.encodeComponent(url);
    final linkedInUrl =
        'https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl';
    final uri = Uri.parse(linkedInUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      Get.snackbar(
        'Success',
        'Opening LinkedIn to share post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      // Fallback
      await Share.share('Check out this interesting post: $url');
      Get.snackbar(
        'Success',
        'Shared using system share',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  } catch (e) {
    log('LinkedIn share error: ${e.toString()}');
    Get.snackbar(
      'Error',
      'Failed to share to LinkedIn',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}
