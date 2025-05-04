import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:image_picker/image_picker.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/model/Community.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';
import 'package:reddit/services/firebase_post_service.dart';
import 'package:reddit/services/reddit_post_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String? preSelectedCommunity;

  const CreatePostScreen({
    Key? key,
    this.preSelectedCommunity,
  }) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(text: 'Option 1'),
    TextEditingController(text: 'Option 2')
  ];

  // Content type flags
  bool _isTextPost = true;
  bool _isImagePost = false;
  bool _isVideoPost = false;
  bool _isPollPost = false;
  bool _isLinkPost = false;

  // Media content
  File? _selectedImage;
  File? _selectedVideo;
  String? _videoThumbnail;
  String? _linkUrl;

  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _selectedCommunity;

  // Get controllers
  final CommunityController _communityController =
      Get.find<CommunityController>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final RedditPostService _redditPostService = RedditPostService();
  final FirebasePostService _firebasePostService = FirebasePostService();

  @override
  void initState() {
    super.initState();
    _selectedCommunity = widget.preSelectedCommunity;
    _titleController.addListener(_updateButtonState);

    // Call update once at initialization to set initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonState();
    });

    // Fetch communities if not already loaded
    _fetchCommunities();
  }

  Future<void> _fetchCommunities() async {
    try {
      await _communityController.fetchUserCommunities();
      await _communityController.fetchCreatedCommunities();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch communities: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateButtonState() {
    if (!mounted) return;

    final bool shouldBeEnabled =
        _titleController.text.isNotEmpty && !_isLoading;

    if (_isButtonEnabled != shouldBeEnabled) {
      setState(() {
        _isButtonEnabled = shouldBeEnabled;
      });
    }
  }

  Future<void> _createPost() async {
    dev.log('Starting _createPost method');
    if (_titleController.text.isEmpty) {
      dev.log('Title is empty, returning early');
      return;
    }

    // Store whether we auto-selected a community
    bool didAutoSelectCommunity = false;

    // If no community selected, use a default or suggest one
    if (_selectedCommunity == null) {
      dev.log('No community selected, attempting auto-selection');
      didAutoSelectCommunity = true;
      // Auto-select the first community from the user's communities if available
      if (_communityController.userCommunities.isNotEmpty) {
        _selectedCommunity = _communityController.userCommunities.first.name;
        dev.log(
            'Auto-selected community from userCommunities: $_selectedCommunity');
      } else if (_communityController.createdCommunities.isNotEmpty) {
        _selectedCommunity = _communityController.createdCommunities.first.name;
        dev.log(
            'Auto-selected community from createdCommunities: $_selectedCommunity');
      } else {
        // If no communities available, use a default community
        _selectedCommunity = "reddit"; // Default community
        dev.log('No communities available, using default community: reddit');
      }
    }

    setState(() {
      _isLoading = true;
      _isButtonEnabled = false;
    });
    dev.log('Set loading state to true');

    try {
      // Prepare additional data based on post type
      Map<String, dynamic>? additionalData = {};
      dev.log(
          'Post type flags - isPoll: $_isPollPost, isLink: $_isLinkPost, isImage: $_isImagePost, isVideo: $_isVideoPost');

      // Handle poll content
      if (_isPollPost) {
        dev.log('Processing poll content');
        final pollOptions = _pollOptionControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
        dev.log('Poll options count: ${pollOptions.length}');

        if (pollOptions.length < 2) {
          dev.log('Error: Insufficient poll options');
          Get.snackbar(
            'Error',
            'Poll requires at least 2 options',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            _isLoading = false;
            _updateButtonState();
          });
          return;
        }

        additionalData['poll'] = {
          'options': pollOptions,
          'voted': -1,
          'votes': List.filled(pollOptions.length, 0),
        };
        dev.log('Poll data prepared: ${additionalData['poll']}');
      }

      // Handle link content
      if (_isLinkPost && _linkUrl != null && _linkUrl!.isNotEmpty) {
        additionalData['link'] = _linkUrl;
        dev.log('Link URL added: $_linkUrl');
      }

      dev.log('Attempting to create post in community: $_selectedCommunity');
      // Create the post using Firebase
      final result = await _firebasePostService.createPost(
        title: _titleController.text,
        subreddit: _selectedCommunity!,
        content: _bodyController.text,
        imageFile: _selectedImage,
        videoFile: _selectedVideo,
        flair: _tagsController.text.isNotEmpty ? _tagsController.text : null,
        additionalData: additionalData.isEmpty ? null : additionalData,
      );
      dev.log('Firebase createPost result: $result');

      if (result['success']) {
        dev.log('Post created successfully');
        // Make sure we visit the community to update recently visited
        _communityController.visitCommunity(_selectedCommunity!);
        dev.log('Updated recently visited communities');

        Get.to(() => const NavigationScreen(), transition: Transition.rightToLeft);

        String message = 'Your post has been created successfully';
        if (didAutoSelectCommunity) {
          message += ' in ' +
              (_selectedCommunity!.startsWith('r/')
                  ? _selectedCommunity!
                  : 'r/$_selectedCommunity');
        }
        dev.log('Success message: $message');

        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        dev.log('Post creation failed with error: ${result['error']}');
        Get.snackbar(
          'Error',
          'Failed to create post: ${result['error']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      dev.log('Exception during post creation',
          error: e, stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to create post: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateButtonState();
        });
        dev.log('Reset loading state');
      }
    }
  }

  void _showCommunitySelectionDialog() {
    final Size size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(size.width * 0.05),
        ),
      ),
      builder: (context) {
        return Container(
          height: size.height * 0.7,
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a community',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              // Search bar for communities
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: size.width * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search communities',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: size.width * 0.04,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Your Communities',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: size.width * 0.045,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Expanded(
                child: Obx(() {
                  // Combine user communities and created communities
                  final List<Community> allCommunities = [
                    ..._communityController.userCommunities,
                    ..._communityController.createdCommunities.where(
                      (c) => !_communityController.userCommunities
                          .any((uc) => uc.name == c.name),
                    ),
                  ];

                  if (allCommunities.isEmpty) {
                    return Center(
                      child: Text(
                        'No communities found. Join or create communities first.',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: size.width * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: allCommunities.length,
                    itemBuilder: (context, index) {
                      final community = allCommunities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          backgroundImage: community.iconImg != null
                              ? NetworkImage(community.iconImg!)
                              : null,
                          child: community.iconImg == null
                              ? Text(
                                  community.name.isNotEmpty
                                      ? community.name[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          community.name.startsWith('r/')
                              ? community.name
                              : 'r/${community.name}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        subtitle: Text(
                          '${community.memberCount} members',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: size.width * 0.035,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCommunity = community.name;
                            _updateButtonState();
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: size.height * 0.02),
              // Popular Communities section (could be added in a future update)
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isImagePost = true;
          // Clear video if selected
          _selectedVideo = null;
          _isVideoPost = false;
          // Polls are exclusive, so disable poll if image is selected
          if (_isPollPost) {
            _isPollPost = false;
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
          _videoThumbnail = 'video_thumbnail';
          _isVideoPost = true;
          // Clear image if selected
          _selectedImage = null;
          _isImagePost = false;
          // Polls are exclusive, so disable poll if video is selected
          if (_isPollPost) {
            _isPollPost = false;
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _addPollOption() {
    setState(() {
      _pollOptionControllers.add(TextEditingController(
          text: 'Option ${_pollOptionControllers.length + 1}'));
    });
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length <= 2) {
      Get.snackbar(
        'Cannot Remove',
        'Poll requires at least 2 options',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _pollOptionControllers[index].dispose();
      _pollOptionControllers.removeAt(index);
    });
  }

  void _switchToLinkPost() {
    setState(() {
      _isLinkPost = !_isLinkPost; // Toggle link post type
    });
  }

  void _switchToPollPost() {
    setState(() {
      // Polls are mutually exclusive with other content
      _isTextPost = false;
      _isImagePost = false;
      _isVideoPost = false;
      _isPollPost = !_isPollPost; // Toggle poll post type
      _isLinkPost = false;
    });
  }

  void _switchToTextPost() {
    setState(() {
      _isTextPost = !_isTextPost; // Toggle text post type
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _isButtonEnabled ? _createPost : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      _isButtonEnabled ? Colors.grey[900] : Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Post',
                        style: GoogleFonts.inter(
                          color: _isButtonEnabled
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community selector
              GestureDetector(
                onTap: _showCommunitySelectionDialog,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        radius: size.width * 0.035,
                        child: Icon(
                          Icons.people_alt_outlined,
                          color: Colors.white,
                          size: size.width * 0.04,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        _selectedCommunity != null
                            ? (_selectedCommunity!.startsWith('r/')
                                ? _selectedCommunity!
                                : 'r/$_selectedCommunity')
                            : 'Select a community',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: size.width * 0.06,
                      ),
                    ],
                  ),
                ),
              ),

              // Title field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Text(
                  'Title',
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: size.width * 0.06,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.01,
                ),
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: size.width * 0.045,
                  ),
                  onChanged: (text) {
                    // Directly update button state when text changes
                    _updateButtonState();
                  },
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: size.width * 0.045,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Tags field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _tagsController,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: size.width * 0.04,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add tags & flair (optional)',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: size.width * 0.04,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              // Content sections - show all selected types

              // Text content
              if (_isTextPost)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: TextField(
                    controller: _bodyController,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: size.width * 0.04,
                    ),
                    decoration: InputDecoration(
                      hintText: 'body text (optional)',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: size.width * 0.04,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    minLines: 3,
                    maxLines: 10,
                  ),
                ),

              // Image content - show if image is selected
              if (_isImagePost && _selectedImage != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              height: size.height * 0.3,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                  _isImagePost = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: size.width * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),

              // Video content - show if video is selected
              if (_isVideoPost && _selectedVideo != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: size.height * 0.3,
                              width: double.infinity,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: size.width * 0.15,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVideo = null;
                                  _isVideoPost = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: size.width * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),

              // Poll content - show if poll is selected
              if (_isPollPost)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poll Options',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pollOptionControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                EdgeInsets.only(bottom: size.height * 0.01),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04,
                                      vertical: size.height * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: _pollOptionControllers[index],
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: size.width * 0.04,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Option ${index + 1}',
                                        hintStyle: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: size.width * 0.04,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                GestureDetector(
                                  onTap: () => _removePollOption(index),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                    size: size.width * 0.05,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: size.height * 0.01),
                      GestureDetector(
                        onTap: _addPollOption,
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.blue,
                              size: size.width * 0.05,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              'Add Option',
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontSize: size.width * 0.04,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Link content - show if link is selected
              if (_isLinkPost)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link URL',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: size.width * 0.04,
                          ),
                          decoration: InputDecoration(
                            hintText: 'https://',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: size.width * 0.04,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            _linkUrl = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Caption field (shows if image or video is selected)
              if (_isImagePost || _isVideoPost)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Caption',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      TextField(
                        controller: _bodyController,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a caption (optional)',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: size.width * 0.04,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

              // Bottom toolbar
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  top: size.height * 0.2, // Push to bottom but with less space
                  bottom: size.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildToolbarButton(
                      Icons.link,
                      'Link',
                      isSelected: _isLinkPost,
                      onTap: _switchToLinkPost,
                    ),
                    _buildToolbarButton(
                      Icons.image,
                      'Image',
                      isSelected: _isImagePost,
                      onTap: _pickImage,
                    ),
                    _buildToolbarButton(
                      Icons.play_circle_outline,
                      'Video',
                      isSelected: _isVideoPost,
                      onTap: _pickVideo,
                    ),
                    _buildToolbarButton(
                      Icons.format_list_bulleted,
                      'Poll',
                      isSelected: _isPollPost,
                      onTap: _switchToPollPost,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildToolbarButton(IconData icon, String tooltip,
      {required bool isSelected, required VoidCallback onTap}) {
    final Size size = MediaQuery.of(context).size;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          // Show a message if trying to add image when video is selected or vice versa
          if (tooltip == 'Image' && _isVideoPost) {
            Get.snackbar(
              'Cannot Select Both',
              'Please remove the video before adding an image',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.grey[800],
              colorText: Colors.white,
              duration: const Duration(seconds: 1),
            );
            return;
          } else if (tooltip == 'Video' && _isImagePost) {
            Get.snackbar(
              'Cannot Select Both',
              'Please remove the image before adding a video',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.grey[800],
              colorText: Colors.white,
              duration: const Duration(seconds: 1),
            );
            return;
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(size.width * 0.05),
        child: Container(
          padding: EdgeInsets.all(size.width * 0.025),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(size.width * 0.05),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey[500],
            size: size.width * 0.06,
          ),
        ),
      ),
    );
  }
}
