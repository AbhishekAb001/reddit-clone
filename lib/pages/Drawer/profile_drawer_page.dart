import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:reddit/controller/profile_controller.dart';

class ProfileDrawerPage extends StatelessWidget {
  const ProfileDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController _profileController = Get.find<ProfileController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.22,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A237E), Colors.black],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      bottom: 0,
                      child: Obx(() => AvatarPlus(
                            _profileController.photoUrl.value.isNotEmpty
                                ? _profileController.photoUrl.value
                                : (_profileController.username.value.isNotEmpty
                                    ? _profileController.username.value
                                    : 'Redditor'),
                            height: screenWidth * 0.22,
                            width: screenWidth * 0.22,
                          )),
                    ),
                    Positioned(
                      left: 24 + screenWidth * 0.16,
                      bottom: screenWidth * 0.04,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                        ),
                        onPressed: () {},
                        child: const Text('Edit',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 16, right: 24),
                child: Obx(() => Text(
                      _profileController.username.value,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 8, right: 24),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events,
                        color: Colors.amberAccent, size: 22),
                    SizedBox(width: 6),
                    Text('5 achievements',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 8, right: 24),
                child: Obx(() => Text(
                      'u/${_profileController.username.value} • ${_profileController.karma.value} karma • ${DateTime.now().year} Gold',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 15),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 4, right: 24),
                child: Text('0 Gold',
                    style:
                        GoogleFonts.inter(color: Colors.white70, fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 12, right: 24),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add social link',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.orange,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Comments'),
                  Tab(text: 'About'),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.45,
                child: const TabBarView(
                  children: [
                    Center(
                        child: Text('NEW POSTS',
                            style: TextStyle(color: Colors.white54))),
                    Center(
                        child: Text('No Comments',
                            style: TextStyle(color: Colors.white54))),
                    Center(
                        child: Text('No About Info',
                            style: TextStyle(color: Colors.white54))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
