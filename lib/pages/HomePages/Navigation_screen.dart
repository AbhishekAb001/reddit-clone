import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/HomePages/answers_screen.dart';
import 'package:reddit/pages/HomePages/chat_screen.dart';
import 'package:reddit/pages/HomePages/inbox_screen.dart';
import 'package:reddit/pages/AuthPages/login_screen.dart';
import 'package:reddit/controller/profile_controller.dart';
import 'package:reddit/controller/community_controller.dart';
import 'package:reddit/pages/HomePages/home_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:reddit/widgets/search_screen.dart';
import 'package:reddit/pages/CommunityPages/name_screen.dart';
import 'package:reddit/pages/CommunityPages/details_screen_new.dart';
import 'package:reddit/pages/CommunityPages/user_detail_screen.dart';
import 'package:reddit/pages/Drawer/profile_drawer_page.dart';
import 'package:reddit/pages/Drawer/saved_drawer_page.dart';
import 'package:reddit/pages/Drawer/history_drawer_page.dart';
import 'package:reddit/pages/Drawer/premium_drawer_page.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:reddit/pages/Drawer/create_avatar_page.dart';
import 'package:reddit/pages/HomePages/create_post_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProfileController _profileController = Get.put(ProfileController());
  final CommunityController _communityController =
      Get.put(CommunityController());

  // Animation controllers for app bar and bottom nav
  late AnimationController _appBarController;
  late AnimationController _bottomNavController;
  late Animation<Offset> _appBarAnimation;
  late Animation<Offset> _bottomNavAnimation;

  // Value notifier to control visibility
  final ValueNotifier<bool> _showBars = ValueNotifier<bool>(true);

  // List of pages to show in the body
  final List<Widget> _pages = [
    HomeScreen(
      showBarsNotifier: ValueNotifier<bool>(true),
    ),
    const AnswersScreen(),
    const SizedBox(),
    const ChatScreen(),
    const InboxScreen(),
  ];
  final List<String> _titles = const [
    'Home',
    'Answers',
    'Create',
    'Chat',
    'Inbox',
  ];

  // List of bottom navigation bar items
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined,
          size: MediaQuery.of(Get.context!).size.width * 0.06),
      activeIcon: Icon(Icons.home_filled,
          color: Color(0xFFFF4500),
          size: MediaQuery.of(Get.context!).size.width * 0.06),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(FontAwesomeIcons.solidCompass,
          size: MediaQuery.of(Get.context!).size.width * 0.055),
      activeIcon: Icon(FontAwesomeIcons.solidCompass,
          color: Color(0xFFFF4500),
          size: MediaQuery.of(Get.context!).size.width * 0.055),
      label: 'Answers',
    ),
    BottomNavigationBarItem(
      icon:
          Icon(Icons.add, size: MediaQuery.of(Get.context!).size.width * 0.06),
      activeIcon: Icon(Icons.add,
          color: Color(0xFFFF4500),
          size: MediaQuery.of(Get.context!).size.width * 0.06),
      label: 'Create',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline,
          size: MediaQuery.of(Get.context!).size.width * 0.06),
      activeIcon: Icon(Icons.chat_bubble,
          color: Color(0xFFFF4500),
          size: MediaQuery.of(Get.context!).size.width * 0.06),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: badges.Badge(
        position: badges.BadgePosition.topEnd(
            top: -MediaQuery.of(Get.context!).size.width * 0.02,
            end: -MediaQuery.of(Get.context!).size.width * 0.01),
        badgeContent: Text(
          '1',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(Get.context!).size.width * 0.02,
          ),
        ),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Colors.red,
          padding:
              EdgeInsets.all(MediaQuery.of(Get.context!).size.width * 0.01),
        ),
        child: Icon(Icons.notifications_outlined,
            size: MediaQuery.of(Get.context!).size.width * 0.06),
      ),
      activeIcon: badges.Badge(
        position: badges.BadgePosition.topEnd(
            top: -MediaQuery.of(Get.context!).size.width * 0.02,
            end: -MediaQuery.of(Get.context!).size.width * 0.01),
        badgeContent: Text(
          '1',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(Get.context!).size.width * 0.02,
          ),
        ),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Colors.red,
          padding:
              EdgeInsets.all(MediaQuery.of(Get.context!).size.width * 0.01),
        ),
        child: Icon(Icons.notifications,
            color: Color(0xFFFF4500),
            size: MediaQuery.of(Get.context!).size.width * 0.06),
      ),
      label: 'Inbox',
    ),
  ];

  Future<void> _logout() async {
    await _profileController.clearUserData();
    Get.offAll(() => const LoginScreen());
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        // Navigate to the new CreatePostScreen
        Get.to(
          () => const CreatePostScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
        return;
      }
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Listen to visibility changes from the home screen
    (_pages[0] as HomeScreen).showBarsNotifier.addListener(() {
      final show = (_pages[0] as HomeScreen).showBarsNotifier.value;
      if (_showBars.value != show) {
        _showBars.value = show;
      }
    });
  }

  void _initializeAnimations() {
    _appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _appBarAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.fastOutSlowIn,
    ));

    _bottomNavAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _bottomNavController,
      curve: Curves.fastOutSlowIn,
    ));

    // Listen to visibility changes
    _showBars.addListener(() {
      if (_showBars.value) {
        _appBarController.reverse();
        _bottomNavController.reverse();
      } else {
        _appBarController.forward();
        _bottomNavController.forward();
      }
    });
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _bottomNavController.dispose();
    _showBars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final communityController = Get.find<CommunityController>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      // Left drawer for communities
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Your Communities',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              trailing:
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: Text(
                'Create a community',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              onTap: () {
                Get.back(); // Close drawer first
                Get.to(
                  () => const NameScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
            // Display user's communities
            Obx(() => Column(
                  children: communityController.userCommunities
                      .map((community) => _buildCommunityTile(
                            community.name,
                            onTap: () {
                              Get.back(); // Close drawer first
                              communityController
                                  .visitCommunity(community.name);
                              Get.to(
                                () => UserDetailScreen(
                                    communityName: community.name),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                          ))
                      .toList(),
                )),
            const Divider(color: Colors.grey),
            // Display recently visited communities
            ListTile(
              title: Text(
                'Recently Visited',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              trailing: const Icon(Icons.history, color: Colors.grey),
            ),
            Obx(() {
              final recentlyVisited =
                  _communityController.recentlyVisitedCommunities;
              return Column(
                children: recentlyVisited
                    .map((communityName) => _buildCommunityTile(
                          communityName,
                          onTap: () => _handleCommunityTap(communityName),
                        ))
                    .toList(),
              );
            }),
            const Divider(color: Colors.grey),
            // Display user's interests as communities
            Obx(() => Column(
                  children: _profileController.interests
                      .map((interest) => _buildCommunityTile(
                            'r/${interest.replaceAll(' ', '_')}',
                            onTap: () {
                              Get.back(); // Close drawer first
                              final communityName =
                                  'r/${interest.replaceAll(' ', '_')}';
                              communityController.visitCommunity(communityName);
                              Get.to(
                                () =>
                                    DetailsScreen(communityName: communityName),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                          ))
                      .toList(),
                )),
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Colors.grey),
              title: Text('All', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
      // Right drawer for user profile and settings
      endDrawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    label: const Text('Create Avatar',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.white)),
                    onPressed: () {
                      Get.to(() => const CreateAvatarPage(),
                          transition: Transition.rightToLeft);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Obx(() => AvatarPlus(
                    _profileController.photoUrl.value.isNotEmpty
                        ? _profileController.photoUrl.value
                        : (_profileController.username.value.isNotEmpty
                            ? _profileController.username.value
                            : 'Redditor'),
                    height: 96,
                    width: 96,
                  )),
            ),
            SizedBox(height: 12),
            Center(
              child: Obx(() => Text(
                    'u/${_profileController.username.value}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  )),
            ),
            SizedBox(height: 6),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.greenAccent, size: 12),
                    SizedBox(width: 6),
                    Text('Online Status: On',
                        style:
                            TextStyle(color: Colors.greenAccent, fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 18, color: Colors.orangeAccent),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon!',
                      'Detailed karma breakdown and achievements will be available in a future update.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue[800],
                      colorText: Colors.white,
                    );
                  },
                  child: Obx(() => Text(
                      '${_profileController.karma.value} Karma',
                      style: TextStyle(fontSize: 14, color: Colors.white))),
                ),
                SizedBox(width: 16),
                Icon(Icons.calendar_today,
                    size: 18, color: Colors.lightBlueAccent),
                SizedBox(width: 4),
                Obx(() => Text(
                    '${_profileController.redditAge.value} Reddit age',
                    style: TextStyle(fontSize: 14, color: Colors.white))),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.amberAccent, size: 18),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon!',
                      'User achievements tracking and display will be available in a future update.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue[800],
                      colorText: Colors.white,
                    );
                  },
                  child: Row(
                    children: [
                      Text('5 Achievements',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                      Icon(Icons.chevron_right,
                          color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey[800]),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.white),
              title: Text('Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              onTap: () {
                Get.to(() => const ProfileDrawerPage(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: Colors.white),
              title: Text('Create a community',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const NameScreen(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              leading: Icon(Icons.workspace_premium, color: Colors.amberAccent),
              title: Text('Reddit Premium',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              subtitle: Text('Ads-free browsing',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              onTap: () {
                Get.to(() => const PremiumDrawerPage(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.emoji_events_outlined, color: Colors.amberAccent),
              title: Text('Contributor Program',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              subtitle: Text('0 gold earned',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              onTap: () {
                // Show coming soon notification
                Get.snackbar(
                  'Coming Soon!',
                  'Contributor program achievements and karma display functionality will be available in a future update.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue[800],
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark_border, color: Colors.white),
              title: Text('Saved',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              onTap: () {
                Get.to(() => const SavedDrawerPage(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.white),
              title: Text('History',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              onTap: () {
                Get.to(() => const HistoryDrawerPage(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white)),
              onTap: () {},
            ),
            SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: _appBarAnimation,
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.bars,
                  color: Colors.white, size: screenWidth * 0.05),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: _selectedIndex == 0
                ? Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFFF4500),
                        radius: screenWidth * 0.04,
                        child: Image.network(
                          'https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png',
                          width: screenWidth * 0.05,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'reddit',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF4500),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: Colors.white, size: screenWidth * 0.06),
                    ],
                  )
                : Text(
                    _titles[_selectedIndex],
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
            actions: [
              if (_selectedIndex == 0)
                IconButton(
                  icon: Icon(Icons.search,
                      color: Colors.white, size: screenWidth * 0.05),
                  onPressed: () {
                    Get.to(
                      () => const SearchScreen(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
              IconButton(
                icon: Stack(
                  children: [
                    Obx(() {
                      final url = _profileController.photoUrl.value;
                      try {
                        return AvatarPlus(
                          url.isNotEmpty
                              ? url
                              : (_profileController.username.value.isNotEmpty
                                  ? _profileController.username.value
                                  : 'Redditor'),
                          height: screenWidth * 0.08,
                          width: screenWidth * 0.08,
                        );
                      } catch (e) {
                        return CircleAvatar(
                          radius: screenWidth * 0.04,
                          backgroundColor: Colors.grey[800],
                          child: Icon(FontAwesomeIcons.user,
                              color: Colors.white, size: screenWidth * 0.04),
                        );
                      }
                    }),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: screenWidth * 0.018,
                        height: screenWidth * 0.018,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SlideTransition(
        position: _bottomNavAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(
                color: Colors.grey[900]!,
                width: screenWidth * 0.001,
              ),
            ),
          ),
          child: BottomNavigationBar(
            items: _bottomNavItems,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: const Color(0xFFFF4500),
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: screenWidth * 0.028,
            unselectedFontSize: screenWidth * 0.028,
            showUnselectedLabels: true,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _handleCommunityTap(String communityName) {
    // Remove 'r/' prefix if present
    final cleanName = communityName.startsWith('r/')
        ? communityName.substring(2)
        : communityName;

    // Check if this is a user-created community
    final isUserCreated = _communityController.userCommunities
        .any((community) => community.name == cleanName);

    // Close drawer
    Get.back();

    // Add to recently visited with the full name (including r/ if it was present)
    _communityController.visitCommunity(communityName);

    // Navigate to appropriate screen
    if (isUserCreated) {
      Get.to(
        () => UserDetailScreen(communityName: cleanName),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      Get.to(
        () => DetailsScreen(communityName: cleanName),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget _buildCommunityTile(String communityName, {VoidCallback? onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.groups, color: Colors.grey[400]),
      ),
      title: Text(
        communityName,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap ?? () => _handleCommunityTap(communityName),
    );
  }
}
