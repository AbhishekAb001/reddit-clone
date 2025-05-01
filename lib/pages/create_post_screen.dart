import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Post',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
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
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1B),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Select a community',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),

          // Title Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.inter(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          // Tags Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add tags & flair (optional)',
                hintStyle: GoogleFonts.inter(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          // Body Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'body text (optional)',
                hintStyle: GoogleFonts.inter(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          Spacer(),

          // Bottom Tools
          Divider(color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.link, color: Colors.grey),
                Icon(Icons.image, color: Colors.grey),
                Icon(Icons.play_circle_outline, color: Colors.grey),
                Icon(Icons.format_list_bulleted, color: Colors.grey),
                Icon(Icons.refresh, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}