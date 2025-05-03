import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reddit/pages/CommunityPages/type_screen.dart';
import 'dart:io';

class TopicCategory {
  final String title;
  final IconData icon;
  final List<String> topics;

  const TopicCategory({
    required this.title,
    required this.icon,
    required this.topics,
  });
}

class TopicsScreen extends StatefulWidget {
  final String communityName;
  final String description;
  final File? bannerImage;
  final File? avatarImage;

  const TopicsScreen({
    super.key,
    required this.communityName,
    required this.description,
    this.bannerImage,
    this.avatarImage,
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final List<String> _selectedTopics = [];

  final List<TopicCategory> categories = [
    TopicCategory(
      title: 'Anime & Cosplay',
      icon: FontAwesomeIcons.mask,
      topics: ['Anime & Manga', 'Cosplay'],
    ),
    TopicCategory(
      title: 'Art',
      icon: FontAwesomeIcons.paintbrush,
      topics: [
        'Performing Arts',
        'Architecture',
        'Design',
        'Art',
        'Filmmaking',
        'Digital Art',
        'Photography'
      ],
    ),
    TopicCategory(
      title: 'Business & Finance',
      icon: FontAwesomeIcons.chartLine,
      topics: [
        'Personal Finance',
        'Crypto',
        'Economics',
        'Startups',
        'Business News & Discussion',
        'Deals & Marketplace'
      ],
    ),
    TopicCategory(
      title: 'Collectibles & Other Hobbies',
      icon: FontAwesomeIcons.dice,
      topics: ['Model Building', 'Collectibles', 'Other Hobbies', 'Toys'],
    ),
    TopicCategory(
      title: 'Education & Career',
      icon: FontAwesomeIcons.graduationCap,
      topics: ['Education', 'Career'],
    ),
  ];

  Widget _buildTopicChip(String topic) {
    final bool selected = _selectedTopics.contains(topic);
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(
        topic,
        style: GoogleFonts.inter(
          color: selected ? Colors.blue : Colors.black,
          fontSize: MediaQuery.of(context).size.width * 0.035,
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.white,
      side: BorderSide(
        color: selected ? Colors.blue : Colors.grey[300]!,
        width: MediaQuery.of(context).size.width * 0.002,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      onSelected: (bool selected) {
        setState(() {
          if (selected && _selectedTopics.length < 3) {
            _selectedTopics.add(topic);
          } else {
            _selectedTopics.remove(topic);
          }
        });
      },
    );
  }

  Widget _buildCategorySection(TopicCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon,
                size: MediaQuery.of(context).size.width * 0.05,
                color: Colors.white),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Text(
              category.title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Wrap(
          spacing: MediaQuery.of(context).size.width * 0.02,
          runSpacing: MediaQuery.of(context).size.height * 0.015,
          children: category.topics.map(_buildTopicChip).toList(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          '3 of 4',
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
              onPressed: _selectedTopics.isNotEmpty
                  ? () {
                      Get.to(
                        () => TypeScreen(
                          communityName: widget.communityName,
                          description: widget.description,
                          bannerImage: widget.bannerImage,
                          avatarImage: widget.avatarImage,
                          topics: _selectedTopics,
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    _selectedTopics.isNotEmpty ? Colors.blue : Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.05),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
              ),
              child: Text(
                'Next',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  fontWeight: FontWeight.w500,
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
              'Choose community topics',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'Add up to 3 topics to help interested redditors find your community',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              'Topics ${_selectedTopics.length}/3',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ...categories.map(_buildCategorySection).toList(),
          ],
        ),
      ),
    );
  }
}
