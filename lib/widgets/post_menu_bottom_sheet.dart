import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/PostPages/comment_thread_page.dart';

void showPostMenuBottomSheet(BuildContext context,
    {String? postUrl, String? postId, String? subreddit}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

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
                      () => CommentThreadPage(
                          postId: postId, subreddit: subreddit),
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
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.bookmark_border_outlined,
                label: 'Save',
                onTap: () {
                  // Save post implementation
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.person_off_outlined,
                label: 'Block account',
                onTap: () {
                  // Block account implementation
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: () {
                  // Report implementation
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.visibility_off_outlined,
                label: 'Hide',
                onTap: () {
                  // Hide implementation
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.content_copy_outlined,
                label: 'Copy text',
                onTap: () {
                  // Copy text implementation
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.share_outlined,
                label: 'Crosspost to community',
                onTap: () {
                  // Crosspost implementation
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showShareBottomSheet(BuildContext context, {String? postUrl}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Default post URL if none provided
  final url = postUrl ?? 'https://reddit.com/';

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.message_outlined,
                label: 'Send in chat',
                onTap: () {
                  Navigator.pop(context);
                  // Would navigate to chat screen with pre-filled message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening chat with link...'),
                      duration: Duration(seconds: 2),
                    ),
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
                    }
                  } catch (e) {
                    log('Share with note error: ${e.toString()}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sharing with note')),
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

  return AlertDialog(
    title: Text('Add a note'),
    content: TextField(
      controller: noteController,
      decoration: InputDecoration(
        hintText: 'Write a note to add to your share...',
      ),
      maxLines: 3,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, noteController.text),
        child: Text('Share'),
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
    } else {
      // Fallback
      await Share.share('Check out this post: $url');
    }
  } catch (e) {
    log('Facebook share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing to Facebook')),
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
    } else {
      // Fallback
      await Share.share('$text: $url');
    }
  } catch (e) {
    log('Twitter share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing to Twitter')),
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
      Future.delayed(Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please paste the link in Instagram. URL copied to clipboard.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
      // Copy URL to clipboard for easier sharing
      await Clipboard.setData(ClipboardData(text: url));
    } else {
      // Fallback
      await Share.share('Check out this post: $url');
    }
  } catch (e) {
    log('Instagram share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing to Instagram')),
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
    } else {
      // Fallback
      await Share.share('Check out this interesting post: $url');
    }
  } catch (e) {
    log('LinkedIn share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing to LinkedIn')),
    );
  }
}
