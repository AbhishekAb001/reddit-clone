import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:reddit/controller/profile_controller.dart';

class PremiumDrawerPage extends StatelessWidget {
  const PremiumDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final ProfileController _profileController = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: screenHeight * 0.06, bottom: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF00AEEF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Center(
                  child: Obx(() => AvatarPlus(
                        _profileController.photoUrl.value.isNotEmpty
                            ? _profileController.photoUrl.value
                            : (_profileController.username.value.isNotEmpty
                                ? _profileController.username.value
                                : 'Redditor'),
                        height: screenWidth * 0.18,
                        width: screenWidth * 0.18,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {},
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber[700],
                            size: 32,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reddit Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'The best Reddit experience, with monthly Coins',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: screenWidth * 0.04,
                    crossAxisSpacing: screenWidth * 0.04,
                    children: [
                      _buildFeature(
                        Icons.star,
                        'Ad-free browsing',
                        'No more ads in your feed',
                        screenWidth,
                      ),
                      _buildFeature(
                        Icons.emoji_events,
                        'Premium Awards',
                        'Give special awards to posts',
                        screenWidth,
                      ),
                      _buildFeature(
                        Icons.face,
                        'Custom Avatar',
                        'Stand out with a unique look',
                        screenWidth,
                      ),
                      _buildFeature(
                        Icons.help_outline,
                        'Premium Support',
                        'Get help from our team',
                        screenWidth,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Try Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
      IconData icon, String title, String subtitle, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF181A20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.amber[700], size: screenWidth * 0.12),
          SizedBox(height: screenWidth * 0.02),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: screenWidth * 0.035,
              ),
            ),
        ],
      ),
    );
  }
}
