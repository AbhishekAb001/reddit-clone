import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostScreen extends StatefulWidget {
  final String communityName;

  const CreatePostScreen({
    super.key,
    required this.communityName,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = 'Text';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildTypeOption('Text', Icons.text_fields),
        _buildTypeOption('Image', Icons.image),
        _buildTypeOption('Link', Icons.link),
        _buildTypeOption('Poll', Icons.poll),
      ],
    );
  }

  Widget _buildTypeOption(String type, IconData icon) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get MediaQuery data for responsive layout
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final paddingTop = mediaQuery.padding.top;
    final paddingBottom = mediaQuery.padding.bottom;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a post',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 18,
              ),
            ),
            Text(
              widget.communityName,
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement post creation
              Get.back();
            },
            child: Text(
              'Post',
              style: GoogleFonts.inter(
                color: Colors.blue,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (_selectedType == 'Text')
                    TextField(
                      controller: _contentController,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      maxLines: null,
                      minLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Text (optional)',
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                    )
                  else if (_selectedType == 'Image')
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              color: Colors.grey[600],
                              size: screenWidth * 0.12),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Add Image',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_selectedType == 'Link')
                    TextField(
                      controller: _contentController,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'URL',
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                    )
                  else if (_selectedType == 'Poll')
                    Column(
                      children: [
                        TextField(
                          controller: _contentController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Option 1',
                            hintStyle: GoogleFonts.inter(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextField(
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Option 2',
                            hintStyle: GoogleFonts.inter(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Add more poll options
                          },
                          icon: const Icon(Icons.add, color: Colors.blue),
                          label: Text(
                            'Add Option',
                            style: GoogleFonts.inter(
                              color: Colors.blue,
                              fontSize: isSmallScreen ? 13 : 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
