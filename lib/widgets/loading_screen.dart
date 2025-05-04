import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/controller/feed_controller.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  FeedController feedController = Get.find<FeedController>();
  CommunityController communityController = Get.find<CommunityController>();
  @override
  void initState() {
    super.initState();
    _fetchPostsAndCommunities();
  }

  void _fetchPostsAndCommunities() async {
    feedController.fetchPostsFromInterests();

    Get.offAll(() => const NavigationScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/logo.json',
          width: size.width * 0.3,
          height: size.width * 0.3,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
