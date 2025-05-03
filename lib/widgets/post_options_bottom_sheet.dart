import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void showPostOptionsBottomSheet(BuildContext context, {String? postUrl}) {
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
      return Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + screenHeight * 0.03,
          top: screenHeight * 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: Text(
                'Share via',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context: context,
                  icon: FontAwesomeIcons.whatsapp,
                  backgroundColor: Colors.green,
                  label: 'WhatsApp',
                  onTap: () async {
                    Navigator.pop(context);
                    // Direct WhatsApp sharing
                    _shareDirectlyToWhatsApp(context, url);
                  },
                ),
                _buildShareOption(
                  context: context,
                  icon: Icons.chat_bubble,
                  backgroundColor: Colors.blue,
                  label: 'SMS',
                  onTap: () async {
                    Navigator.pop(context);
                    // Direct SMS sharing
                    _shareDirectlyToSms(context, url);
                  },
                ),
                _buildShareOption(
                  context: context,
                  icon: Icons.email_outlined,
                  backgroundColor: Colors.white,
                  iconColor: Colors.black,
                  label: 'Email',
                  onTap: () async {
                    Navigator.pop(context);
                    // Direct Email sharing
                    _shareDirectlyToEmail(context, url);
                  },
                ),
                _buildShareOption(
                  context: context,
                  icon: Icons.more_horiz,
                  backgroundColor: Colors.grey.shade800,
                  label: 'More',
                  onTap: () async {
                    Navigator.pop(context);
                    // General share sheet
                    try {
                      await Share.share(
                        url,
                        subject: 'Check out this Reddit post',
                      );
                    } catch (e) {
                      log('Share error: ${e.toString()}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error sharing content')),
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'Your username stays hidden when you share outside of Reddit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildShareOption({
  required BuildContext context,
  required IconData icon,
  required Color backgroundColor,
  required String label,
  required VoidCallback onTap,
  Color iconColor = Colors.white,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: screenWidth * 0.14,
          height: screenWidth * 0.14,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: screenWidth * 0.065,
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

// Direct app-specific sharing functions
void _shareDirectlyToWhatsApp(BuildContext context, String url) async {
  try {
    // WhatsApp direct sharing
    final encodedText = Uri.encodeComponent('Check out this post: $url');
    final whatsappUrl = 'whatsapp://send?text=$encodedText';
    final uri = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback to general share if WhatsApp not installed
      await Share.share(
        'Check out this post: $url',
        subject: 'Reddit post via WhatsApp',
      );
    }
  } catch (e) {
    log('WhatsApp share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing to WhatsApp')),
    );
  }
}

void _shareDirectlyToSms(BuildContext context, String url) async {
  try {
    // SMS direct sharing
    final message = 'Check out this Reddit post: $url';

    // Platform-specific SMS URLs
    final smsUrl = Platform.isIOS ? 'sms:&body=$message' : 'sms:?body=$message';

    final uri = Uri.parse(smsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback
      await Share.share(
        message,
        subject: 'Reddit post',
      );
    }
  } catch (e) {
    log('SMS share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing via SMS')),
    );
  }
}

void _shareDirectlyToEmail(BuildContext context, String url) async {
  try {
    // Email direct sharing
    final subject = Uri.encodeComponent('Interesting Reddit Post to Check Out');
    final body = Uri.encodeComponent(
        'I found this interesting Reddit post that I thought you might enjoy:\n\n$url\n\nCheck it out when you have time!');

    final emailUrl = 'mailto:?subject=$subject&body=$body';
    final uri = Uri.parse(emailUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback
      await Share.share(
        'I found this interesting Reddit post that I thought you might enjoy:\n\n$url\n\nCheck it out when you have time!',
        subject: 'Interesting Reddit Post to Check Out',
      );
    }
  } catch (e) {
    log('Email share error: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing via Email')),
    );
  }
}
