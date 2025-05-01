import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnswersScreen extends StatelessWidget {
  const AnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Reddit Answers',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey[800],
            child: Icon(FontAwesomeIcons.user, color: Colors.white, size: 15),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo and Title
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green, Colors.orange],
                      ),
                    ),
                  ),
                  Icon(FontAwesomeIcons.reddit, color: Colors.white, size: 40),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'reddit answers',
                style: GoogleFonts.inter(
                  color: Color(0xFFFF4500),
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Real answers from real people',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: 24),

              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ask a question',
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Trending Topics
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  _buildTrendingTopic('👑 most successful real housewife'),
                  _buildTrendingTopic('🍖 meatloaf recipe'),
                  _buildTrendingTopic('🪑 wooden data centers benefits'),
                  _buildTrendingTopic('🎮 best xbox games 2025'),
                  _buildTrendingTopic(
                    '👨‍🍳 recipes for classic african dishes',
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Learn More Link
              TextButton(
                onPressed: () {},
                child: Text(
                  'Learn how Reddit Answers works >',
                  style: GoogleFonts.inter(
                    color: Colors.blue,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTopic(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: GoogleFonts.inter(color: Colors.white)),
    );
  }
}
