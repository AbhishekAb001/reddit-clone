import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/HomePages/response_screen.dart';

class SlideUpTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve ?? Curves.easeOut,
        )),
        child: child,
      ),
    );
  }
}

class AnswersScreen extends StatefulWidget {
  const AnswersScreen({super.key});

  @override
  State<AnswersScreen> createState() => _AnswersScreenState();
}

class _AnswersScreenState extends State<AnswersScreen> {
  late double screenWidth;
  late double screenHeight;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  Future<void> _askQuestion(String question) async {
    if (!_recentSearches.contains(question)) {
      setState(() {
        _recentSearches.insert(0, question);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    // Navigate to response screen
    Get.to(
      () => ResponseScreen(
        question: question,
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            children: [
              // Logo and Title
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green, Colors.orange],
                      ),
                    ),
                  ),
                  const Icon(FontAwesomeIcons.reddit,
                      color: Colors.white, size: 28),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                'AI Answers',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF4500),
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Powered by Google Gemini AI',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.032,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask Gemini AI anything...',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.035,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: screenWidth * 0.045,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: Colors.grey,
                            size: screenWidth * 0.045,
                          ),
                          onPressed: () {
                            // TODO: Implement voice input
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: const Color(0xFFFF4500),
                            size: screenWidth * 0.045,
                          ),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              _askQuestion(_searchController.text);
                              _searchController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Recent Searches
              if (_recentSearches.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Searches',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.008),
                Wrap(
                  spacing: screenWidth * 0.015,
                  runSpacing: screenHeight * 0.008,
                  children: _recentSearches
                      .map((search) => _buildRecentSearch(search))
                      .toList(),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],

              // AI Capabilities
              Text(
                'What can Gemini AI help you with?',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Wrap(
                spacing: screenWidth * 0.015,
                runSpacing: screenHeight * 0.01,
                children: [
                  _buildAICapability('📝 Write content'),
                  _buildAICapability('🔍 Research topics'),
                  _buildAICapability('💡 Generate ideas'),
                  _buildAICapability('📊 Analyze data'),
                  _buildAICapability('🎨 Creative writing'),
                  _buildAICapability('📚 Learn new things'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearch(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _askQuestion(text);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[850]!,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: Colors.grey, size: screenWidth * 0.032),
            SizedBox(width: screenWidth * 0.01),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.032,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAICapability(String text) {
    return GestureDetector(
      onTap: () => _askQuestion(text),
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[850]!,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.split(' ')[0], // Emoji
              style: TextStyle(fontSize: screenWidth * 0.032),
            ),
            SizedBox(width: screenWidth * 0.01),
            Flexible(
              child: Text(
                text.substring(text.indexOf(' ') + 1), // Text without emoji
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.032,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
