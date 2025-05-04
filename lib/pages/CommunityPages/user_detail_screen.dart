import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';
import 'package:reddit/model/Community.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reddit/pages/HomePages/create_post_screen.dart';
import 'package:reddit/pages/PostPages/post_comment_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final String communityName;

  const UserDetailScreen({
    super.key,
    required this.communityName,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Community? _communityInfo;
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _fetchCommunityInfo();
    _fetchPosts();
  }

  Future<void> _fetchCommunityInfo() async {
    try {
      // Query for document where name matches community name
      final querySnapshot = await _firestore
          .collection('communities')
          .where('name', isEqualTo: widget.communityName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final communityDoc = querySnapshot.docs.first;
        final data = communityDoc.data();
        setState(() {
          _communityInfo = Community(
            id: communityDoc.id,
            name: data['name'] ?? widget.communityName,
            title: data['title'] ?? widget.communityName,
            description: data['description'],
            publicDescription: data['publicDescription'],
            memberCount: data['memberCount'] ?? 0,
            onlineCount: data['onlineCount'] ?? 0,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch)
                  .toInt(),
            ),
            type: data['type'] ?? 'public',
            isMature: data['isMature'] ?? false,
            createdBy: data['createdBy'] ?? '',
            topics: List<String>.from(data['topics'] ?? []),
            over18: data['over18'] ?? false,
            subredditType: data['subredditType'] ?? 'public',
            iconImg: data['icon_img'] ?? data['iconImg'],
            bannerImg: data['banner_img'] ?? data['bannerImg'],
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      log('Error fetching community info from Firebase: $e');
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

      String? docId = await _findCommunityDocumentId(subreddit);
      // Fetch posts from Firebase
      final postsSnapshot = await _firestore
          .collection('communities')
          .doc(docId)
          .collection('posts')
          .get();

      log('Fetched ${postsSnapshot.docs.length} posts for $subreddit');

      setState(() {
        _posts = postsSnapshot.docs.map((doc) => doc.data()).toList();
        _isLoadingPosts = false;
      });
    } catch (e) {
      log('Error fetching posts: $e');
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<String?> _findCommunityDocumentId(String communityName) async {
    try {
      // Clean community name
      final String cleanName = communityName.startsWith('r/')
          ? communityName.substring(2)
          : communityName;
      log('Finding community document ID for: $cleanName');
      // Query Firestore to find the community document ID
      final querySnapshot = await _firestore
          .collection('communities')
          .where('name', isEqualTo: "r/$cleanName")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        log('Community not found: $communityName');
        return null;
      }
    } catch (e) {
      log('Error finding community document ID: $e');
      return null;
    }
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
            expandedHeight: screenHeight * 0.13,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => CreatePostScreen(
              preSelectedCommunity: widget.communityName.startsWith('r/')
                  ? widget.communityName.substring(2)
                  : widget.communityName,
            ),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        },
        backgroundColor: const Color(0xFFFF4500),
        child: const Icon(Icons.add),
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
        return GestureDetector(
          onTap: () {
            Get.to(
              () => PostCommentScreen(
                postId: post['id'],
                postTitle: post['title'],
                subreddit: widget.communityName,
                postThumbnail: post['mediaUrl'],
              ),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Container(
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
                        '• ${_formatTimeAgo(post['createdAt']?.toString())}',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: screenWidth * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                // Post title
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
                // Post content
                if (post['content'] != null && post['content'].isNotEmpty) ...[
                  SizedBox(height: screenWidth * 0.02),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Text(
                      post['content'],
                      style: GoogleFonts.inter(
                        color: Colors.grey[300],
                        fontSize: screenWidth * 0.032,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                // Media content
                if (post['mediaUrl'] != null &&
                    post['mediaUrl'].isNotEmpty) ...[
                  SizedBox(height: screenWidth * 0.02),
                  Container(
                    width: double.infinity,
                    height: screenWidth * 0.6,
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      color: Colors.grey[800],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      child: Image.network(
                        post['mediaUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: screenWidth * 0.1),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SizedBox(height: screenWidth * 0.02),
                // Post actions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    children: [
                      // Vote buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_upward,
                                  size: screenWidth * 0.04,
                                  color: post['userVote'] == 1
                                      ? Colors.orange
                                      : Colors.grey[400]),
                              onPressed: () {
                                // Handle upvote
                              },
                            ),
                            Text(
                              _formatCount(post['upvotes'] ?? 0),
                              style: GoogleFonts.inter(
                                color: post['userVote'] == 1
                                    ? Colors.orange
                                    : post['userVote'] == -1
                                        ? Colors.blue
                                        : Colors.grey[400],
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_downward,
                                  size: screenWidth * 0.04,
                                  color: post['userVote'] == -1
                                      ? Colors.blue
                                      : Colors.grey[400]),
                              onPressed: () {
                                // Handle downvote
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      // Comments button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(
                              () => PostCommentScreen(
                                postId: post['id'],
                                postTitle: post['title'],
                                subreddit: widget.communityName,
                                postThumbnail: post['mediaUrl'],
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenWidth * 0.02),
                            child: Row(
                              children: [
                                Icon(Icons.comment_outlined,
                                    size: screenWidth * 0.04,
                                    color: Colors.grey[400]),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  '${post['commentCount'] ?? 0}',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[400],
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      // Share button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.share_outlined,
                              size: screenWidth * 0.04,
                              color: Colors.grey[400]),
                          onPressed: () {
                            // Handle share
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Divider(color: Colors.grey[800], thickness: 1),
              ],
            ),
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
    String parsedString = text
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
