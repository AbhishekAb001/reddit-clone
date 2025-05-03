import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late double screenWidth;
  late double screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: screenWidth * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Post',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Community Selector
          Container(
            margin: EdgeInsets.all(screenWidth * 0.02),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1B),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(Icons.people,
                    color: Colors.white, size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Select a community',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down,
                    color: Colors.white, size: screenWidth * 0.06),
              ],
            ),
          ),

          // Title Field
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: TextField(
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.04,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          // Tags Field
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: TextField(
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'Add tags & flair (optional)',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.04,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          // Body Field
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: TextField(
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'body text (optional)',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.04,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          Spacer(),

          // Bottom Tools
          Divider(color: Colors.grey[800]),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.link, color: Colors.grey, size: screenWidth * 0.06),
                Icon(Icons.image, color: Colors.grey, size: screenWidth * 0.06),
                Icon(Icons.play_circle_outline,
                    color: Colors.grey, size: screenWidth * 0.06),
                Icon(Icons.format_list_bulleted,
                    color: Colors.grey, size: screenWidth * 0.06),
                Icon(Icons.refresh,
                    color: Colors.grey, size: screenWidth * 0.06),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
