import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/CommunityPages/style_screen.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';
import 'package:reddit/pages/CommunityPages/create_post_screen.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/model/Community.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:reddit/services/reddit_post_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shimmer/shimmer.dart';

class DetailsScreen extends StatefulWidget {
  final String communityName;

  const DetailsScreen({
    super.key,
    required this.communityName,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final CommunityController _communityController =
      Get.find<CommunityController>();
  final RedditPostService _redditPostService = RedditPostService();
  Community? _communityInfo;
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = false;
  Map<String, VideoPlayerController> _videoControllers = {};
  Map<String, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchCommunityInfo();
    _fetchPosts();
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchCommunityInfo() async {
    try {
      final info =
          await _communityController.fetchCommunityInfo(widget.communityName);
      if (info != null) {
        setState(() {
          _communityInfo = info;
          _isLoading = false;
        });
        log('Community Info: ${info.toJson()}'); // Debug print
      } else {
        log('Community not found: ${widget.communityName}'); // Debug print
        setState(() => _isLoading = false);
      }
    } catch (e) {
      log('Error fetching community info: $e'); // Debug print
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() => _isLoadingPosts = true);
      // Remove 'r/' prefix if present
      final subreddit = widget.communityName.startsWith('r/')
          ? widget.communityName.substring(2)
          : widget.communityName;
      final posts = await _redditPostService.fetchHotPosts(subreddit);
      log('PostsCommunity: $posts');
      setState(() {
        _posts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      log('Error fetching posts: $e');
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _initializeVideo(String postId, String videoUrl) async {
    if (_videoControllers.containsKey(postId)) return;

    final videoController = VideoPlayerController.network(videoUrl);
    await videoController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: false,
      looping: false,
      aspectRatio: videoController.value.aspectRatio,
      placeholder: Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: Icon(Icons.error_outline,
                color: Colors.grey[400],
                size: MediaQuery.of(context).size.width * 0.1),
          ),
        );
      },
    );

    setState(() {
      _videoControllers[postId] = videoController;
      _chewieControllers[postId] = chewieController;
    });
  }

  Widget _buildShimmerLoading() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: screenHeight * 0.13,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[900]!,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      color: Colors.grey[900],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: screenWidth * 0.07),
              onPressed: () => Get.offAll(() => const NavigationScreen()),
            ),
          ),
        ],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community info section
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: CircleAvatar(
                            radius: screenWidth * 0.07,
                            backgroundColor: Colors.grey[900],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[900]!,
                                highlightColor: Colors.grey[800]!,
                                child: Container(
                                  width: screenWidth * 0.4,
                                  height: screenWidth * 0.045,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Shimmer.fromColors(
                                baseColor: Colors.grey[900]!,
                                highlightColor: Colors.grey[800]!,
                                child: Container(
                                  width: screenWidth * 0.3,
                                  height: screenWidth * 0.032,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[900]!,
                      highlightColor: Colors.grey[800]!,
                      child: Container(
                        width: double.infinity,
                        height: screenWidth * 0.034,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[900]!,
                      highlightColor: Colors.grey[800]!,
                      child: Container(
                        width: double.infinity,
                        height: screenWidth * 0.034,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[800], thickness: 1),
              // Posts section
              ...List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: double.infinity,
                          height: screenWidth * 0.035,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: double.infinity,
                          height: screenWidth * 0.032,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: double.infinity,
                          height: screenWidth * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    // Display name (fix double r/)
    String displayName = widget.communityName.startsWith('r/')
        ? widget.communityName
        : 'r/${widget.communityName}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: screenHeight * 0.13, // Responsive height
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    (_communityInfo?.bannerImg != null &&
                            _communityInfo!.bannerImg!.isNotEmpty)
                        ? _communityInfo!.bannerImg!
                        : 'https://www.redditstatic.com/desktop2x/img/id-cards/banner@2x.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey, size: screenWidth * 0.08),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: screenWidth * 0.07),
              onPressed: () => Get.offAll(() => const NavigationScreen()),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, size: screenWidth * 0.07),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share, size: screenWidth * 0.07),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, size: screenWidth * 0.07),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.07,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: (_communityInfo?.iconImg != null &&
                                  _communityInfo!.iconImg!.isNotEmpty &&
                                  _communityInfo!.iconImg!.startsWith('http'))
                              ? NetworkImage(_communityInfo!.iconImg!)
                              : null,
                          child: (_communityInfo?.iconImg == null ||
                                  _communityInfo!.iconImg!.isEmpty ||
                                  !_communityInfo!.iconImg!.startsWith('http'))
                              ? Icon(Icons.groups,
                                  size: screenWidth * 0.045, color: Colors.grey)
                              : null,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _formatCount(
                                        _communityInfo?.memberCount ?? 0),
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[400],
                                      fontSize: screenWidth * 0.032,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.01),
                                    width: screenWidth * 0.012,
                                    height: screenWidth * 0.012,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: screenWidth * 0.018,
                                        height: screenWidth * 0.018,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.012),
                                      Text(
                                        '${_formatOnlineCount(_communityInfo?.onlineCount ?? 0)} online',
                                        style: GoogleFonts.inter(
                                          color: Colors.green,
                                          fontSize: screenWidth * 0.032,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize:
                                Size(screenWidth * 0.18, screenWidth * 0.08),
                          ),
                          child: Text(
                            'Joined',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: screenWidth * 0.032,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Show descriptions
                  if (_communityInfo?.publicDescription != null &&
                          _communityInfo!.publicDescription!.isNotEmpty ||
                      _communityInfo?.description != null &&
                          _communityInfo!.description!.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_communityInfo?.publicDescription != null &&
                              _communityInfo!.publicDescription!.isNotEmpty)
                            Text(
                              _formatDescription(
                                  _communityInfo!.publicDescription!),
                              style: GoogleFonts.inter(
                                color: Colors.grey[300],
                                fontSize: screenWidth * 0.034,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (_communityInfo?.description != null &&
                              _communityInfo!.description!.isNotEmpty)
                            Text(
                              _formatDescription(_communityInfo!.description!),
                              style: GoogleFonts.inter(
                                color: Colors.grey[300],
                                fontSize: screenWidth * 0.034,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          SizedBox(height: screenWidth * 0.04),
                          Divider(color: Colors.grey[800], thickness: 1),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        body: _buildPostsList(screenWidth),
      ),
    );
  }

  Widget _buildPostsList(double screenWidth) {
    if (_isLoadingPosts) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5, // Show 5 shimmer posts while loading
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[900],
            margin: EdgeInsets.only(bottom: screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post header
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: CircleAvatar(
                          radius: screenWidth * 0.02,
                          backgroundColor: Colors.grey[900],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.028,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Post title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[900]!,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      width: double.infinity,
                      height: screenWidth * 0.035,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Post content
                SizedBox(height: screenWidth * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[900]!,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      width: double.infinity,
                      height: screenWidth * 0.032,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Post media
                SizedBox(height: screenWidth * 0.02),
                Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[800]!,
                  child: Container(
                    width: double.infinity,
                    height: screenWidth * 0.6,
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Post actions
                SizedBox(height: screenWidth * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Divider(color: Colors.grey[800], thickness: 1),
              ],
            ),
          );
        },
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Text(
          'No posts yet',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: screenWidth * 0.04,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Container(
          color: Colors.grey[900],
          margin: EdgeInsets.only(bottom: screenWidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.02,
                      backgroundColor: Colors.grey[800],
                      child: Icon(Icons.person,
                          size: screenWidth * 0.03, color: Colors.grey[400]),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'u/${post['author'] ?? 'deleted'}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '• ${_formatTimeAgo(post['created_utc']?.toString())}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: screenWidth * 0.028,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  post['title'] ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (post['selftext'] != null && post['selftext'].isNotEmpty) ...[
                SizedBox(height: screenWidth * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    post['selftext'],
                    style: GoogleFonts.inter(
                      color: Colors.grey[300],
                      fontSize: screenWidth * 0.032,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              // Add media content
              if (post['url'] != null && post['url'].isNotEmpty) ...[
                SizedBox(height: screenWidth * 0.02),
                if (post['is_video'] == true &&
                    post['media']?['reddit_video']?['fallback_url'] != null)
                  Container(
                    width: double.infinity,
                    height: screenWidth * 0.6,
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: FutureBuilder(
                      future: _initializeVideo(
                        post['id'],
                        post['media']['reddit_video']['fallback_url'],
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final chewieController = _chewieControllers[post['id']];
                        if (chewieController != null) {
                          return Chewie(controller: chewieController);
                        }

                        return Container(
                          color: Colors.grey[800],
                          child: Icon(Icons.play_circle_outline,
                              color: Colors.grey[400], size: screenWidth * 0.1),
                        );
                      },
                    ),
                  )
                else if (post['preview']?['images'] != null &&
                    post['preview']['images'].isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: screenWidth * 0.6,
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Image.network(
                      post['preview']['images'][0]['source']['url']
                              ?.replaceAll(RegExp(r'&amp;'), '&') ??
                          '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[400], size: screenWidth * 0.1),
                        );
                      },
                    ),
                  )
                else if (post['url'].startsWith('http') &&
                    (post['url'].endsWith('.jpg') ||
                        post['url'].endsWith('.jpeg') ||
                        post['url'].endsWith('.png') ||
                        post['url'].endsWith('.gif')))
                  Container(
                    width: double.infinity,
                    height: screenWidth * 0.6,
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Image.network(
                      post['url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[400], size: screenWidth * 0.1),
                        );
                      },
                    ),
                  ),
              ],
              SizedBox(height: screenWidth * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward,
                        size: screenWidth * 0.04, color: Colors.grey[400]),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      _formatCount(post['ups'] ?? 0),
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Icon(Icons.comment_outlined,
                        size: screenWidth * 0.04, color: Colors.grey[400]),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '${post['num_comments'] ?? 0} comments',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Divider(color: Colors.grey[800], thickness: 1),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        (double.parse(timestamp) * 1000).toInt(),
      );
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatOnlineCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDescription(String text) {
    // Remove HTML tags and decode HTML entities
    final document = html_parser.parse(text);
    String parsedString = document.body?.text ?? '';

    // Clean up the text
    parsedString = parsedString
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#x200B;'), '') // Remove zero-width spaces
        .replaceAll(
            RegExp(r'\n{2,}'), ' ') // Replace multiple newlines with space
        .replaceAll(RegExp(r'---\s*'), '') // Remove horizontal lines
        .replaceAll(RegExp(r'###.*?\n'), '') // Remove markdown headers
        .replaceAll(RegExp(r'\|\s*\|'), '') // Remove table separators
        .replaceAll(RegExp(r'-\|-'), '') // Remove table row separators
        .replaceAll(
            RegExp(r'Browse categories:'), '') // Remove browse categories text
        .replaceAll(RegExp(r'[^\w\s.,!?-]'),
            '') // Remove special characters except basic punctuation
        .replaceAll(
            RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();

    // Split into lines and take first three
    List<String> lines = parsedString.split('\n');
    if (lines.length > 3) {
      return '${lines.take(3).join('\n')}...';
    }
    return parsedString;
  }
}
