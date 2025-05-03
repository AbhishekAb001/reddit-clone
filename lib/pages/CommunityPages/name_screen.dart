import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/CommunityPages/style_screen.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _communityNameError;

  @override
  void dispose() {
    _communityNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateCommunityName(String value) {
    if (value.isEmpty) {
      setState(() => _communityNameError = 'Community name is required');
    } else if (!value.startsWith('r/')) {
      setState(() => _communityNameError = 'Community name must start with r/');
    } else if (value.length < 3) {
      setState(() => _communityNameError = 'Community name is too short');
    } else {
      setState(() => _communityNameError = null);
    }
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
          onPressed: () => Get.offAll(() => const NavigationScreen()),
        ),
        title: Text(
          '1 of 4',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _communityNameError == null &&
                    _communityNameController.text.isNotEmpty
                ? () {
                    Get.to(
                      () => StyleScreen(
                        communityName: _communityNameController.text,
                        description: _descriptionController.text,
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  }
                : null,
            child: Text(
              'Next',
              style: GoogleFonts.inter(
                color: _communityNameError == null &&
                        _communityNameController.text.isNotEmpty
                    ? Colors.blue
                    : Colors.grey,
                fontSize: MediaQuery.of(context).size.width * 0.035,
                fontWeight: FontWeight.bold,
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
              'Tell us about your community',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'A name and description help people understand what your community is all about',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Text(
              'Community Name *',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            TextField(
              controller: _communityNameController,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'r/community_name',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.02),
                  borderSide: BorderSide.none,
                ),
                errorText: _communityNameError,
                errorStyle: GoogleFonts.inter(
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                ),
              ),
              onChanged: _validateCommunityName,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              'Description',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            TextField(
              controller: _descriptionController,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
              maxLines: 4,
              maxLength: 480,
              decoration: InputDecoration(
                hintText: 'Tell people what your community is about',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.02),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
