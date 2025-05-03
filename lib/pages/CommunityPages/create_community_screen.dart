import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedTopics = [];
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

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Get.back();
    }
  }

  Widget _buildTopicChip(String topic, {bool selected = false}) {
    return FilterChip(
      selected: selected,
      label: Text(
        topic,
        style: GoogleFonts.inter(
          color: selected ? Colors.white : Colors.grey[300],
        ),
      ),
      backgroundColor: Colors.grey[900],
      selectedColor: Colors.blue,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            if (_selectedTopics.length < 3) {
              _selectedTopics.add(topic);
            }
          } else {
            _selectedTopics.remove(topic);
          }
        });
      },
    );
  }

  Widget _buildCommunityNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about your community',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A name and description help people understand what your community is all about',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Community Name *',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _communityNameController,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'r/community_name',
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorText: _communityNameError,
          ),
          onChanged: _validateCommunityName,
        ),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          style: GoogleFonts.inter(color: Colors.white),
          maxLines: 4,
          maxLength: 480,
          decoration: InputDecoration(
            hintText: 'Tell people what your community is about',
            hintStyle: GoogleFonts.inter(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style your community',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A banner and avatar attract members and establish your community\'s culture',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate,
                  color: Colors.grey[600], size: 48),
              const SizedBox(height: 8),
              Text(
                'Add Banner Image',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[900],
                child:
                    Icon(Icons.camera_alt, color: Colors.grey[600], size: 32),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsStep() {
    final topics = [
      'Gaming',
      'Sports',
      'Technology',
      'Movies',
      'Music',
      'Art',
      'Food',
      'Science',
      'Politics',
      'News',
      'Memes',
      'Photography',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose community topics',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 3 topics to help interested redditors find your community',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Topics ${_selectedTopics.length}/3',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics
              .map((topic) => _buildTopicChip(topic,
                  selected: _selectedTopics.contains(topic)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review your community',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _communityNameController.text,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '1 member • 1 online',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _descriptionController.text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTopics
                    .map((topic) => Chip(
                          label: Text(
                            topic,
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
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
          onPressed: _previousStep,
        ),
        title: Text(
          '$_currentStep of $_totalSteps',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _currentStep == _totalSteps
                ? () {
                    // TODO: Implement community creation
                    Get.back();
                  }
                : _nextStep,
            child: Text(
              _currentStep == _totalSteps ? 'Create' : 'Next',
              style: GoogleFonts.inter(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 1) _buildCommunityNameStep(),
            if (_currentStep == 2) _buildStyleStep(),
            if (_currentStep == 3) _buildTopicsStep(),
            if (_currentStep == 4) _buildReviewStep(),
          ],
        ),
      ),
    );
  }
}
