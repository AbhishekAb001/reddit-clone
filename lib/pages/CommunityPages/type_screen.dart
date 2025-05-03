import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/pages/CommunityPages/details_screen_new.dart';
import 'dart:io';

class CommunityType {
  final String title;
  final String description;
  final IconData icon;
  final bool isMature;

  const CommunityType({
    required this.title,
    required this.description,
    required this.icon,
    this.isMature = false,
  });
}

class TypeScreen extends StatefulWidget {
  final String communityName;
  final String description;
  final List<String> topics;
  final File? bannerImage;
  final File? avatarImage;

  const TypeScreen({
    super.key,
    required this.communityName,
    required this.description,
    required this.topics,
    this.bannerImage,
    this.avatarImage,
  });

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  String _selectedType = 'Public';
  bool _isMature = false;
  final CommunityController _communityController =
      Get.find<CommunityController>();

  final List<CommunityType> _types = const [
    CommunityType(
      title: 'Public',
      description: 'Anyone can search for, view, and contribute',
      icon: Icons.public,
    ),
    CommunityType(
      title: 'Restricted',
      description: 'Anyone can view, but restrict who can contribute',
      icon: Icons.remove_red_eye_outlined,
    ),
    CommunityType(
      title: 'Private',
      description: 'Only approved members can view and contribute',
      icon: Icons.lock_outline,
    ),
  ];

  Widget _buildTypeOption(CommunityType type) {
    final bool isSelected = _selectedType == type.title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type.title;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.015),
        child: Row(
          children: [
            Icon(
              type.icon,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.06,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    type.description,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.06,
              height: MediaQuery.of(context).size.width * 0.06,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[600]!,
                  width: MediaQuery.of(context).size.width * 0.005,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.005),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '4 of 4',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.04),
            child: TextButton(
              onPressed: () async {
                try {
                  // Show loading indicator
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                    barrierDismissible: false,
                  );

                  // Create community
                  await _communityController.createCommunity(
                    name: widget.communityName,
                    description: widget.description,
                    type: _selectedType.toLowerCase(),
                    isMature: _isMature,
                    topics: widget.topics,
                    bannerImage: widget.bannerImage,
                    avatarImage: widget.avatarImage,
                  );

                  // Close loading dialog
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }

                  // Show success message
                  Get.snackbar(
                    'Success',
                    'Community created successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );

                  // Navigate to community details screen
                  Get.offAll(() => DetailsScreen(
                        communityName: widget.communityName,
                      ));
                } catch (e) {
                  // Close loading dialog if it's open
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }

                  // Show error message
                  Get.snackbar(
                    'Error',
                    'Failed to create community: ${e.toString()}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text(
                'Create',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select community type',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Decide who can view and contribute in your community. Only public communities show up in search. ',
                  ),
                  TextSpan(
                    text: 'Important:',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' Once set, you can only change your community type with Reddit\'s approval.',
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ..._types.map(_buildTypeOption).toList(),
            const Divider(
              color: Colors.grey,
              height: 32,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              title: Text(
                'Mature (18+)',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Users must be over 18 to view and contribute',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
              ),
              trailing: Transform.scale(
                scale: MediaQuery.of(context).size.width * 0.003,
                child: Switch(
                  value: _isMature,
                  onChanged: (value) {
                    setState(() {
                      _isMature = value;
                    });
                  },
                  activeColor: Colors.blue,
                  activeTrackColor: Colors.blue.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
